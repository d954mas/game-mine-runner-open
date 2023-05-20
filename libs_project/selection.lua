local COMMON = require "libs.common"
local CTXS = COMMON.CONTEXT
local TAG = "[SELECTION]"

---@class SelectionElement
local SelectionElement = COMMON.class("SelectionElement")
function SelectionElement:initialize(config)
	self.selected = false
	self.config = config
end

function SelectionElement:select()
	self.selected = true
end
function SelectionElement:hide()
	self.selected = false
end

function SelectionElement:can_select()
	return true
end

function SelectionElement:press()

end

function SelectionElement:position_get()
	return vmath.vector3(0)
end

function SelectionElement:is_on_hover(x, y)
	return false
end

--return id if need custom movement
function SelectionElement:move_left()
	return self.config.move_left
end
function SelectionElement:move_right()
	return self.config.move_right
end
function SelectionElement:move_top()
	return self.config.move_top
end
function SelectionElement:move_bottom()
	return self.config.move_bottom
end

local SelectionElementReference = COMMON.class("SelectionElementReference", SelectionElement)
function SelectionElementReference:initialize(config)
	SelectionElement.initialize(self, config)
	assert(self.config.element)
end

function SelectionElementReference:select()
	self.config.element:select()
	return self.config.element
end
function SelectionElementReference:hide()
	SelectionElement.hide(self)
end

function SelectionElementReference:can_select()
	local can_select = self.config.element:can_select()
	return can_select
end

function SelectionElementReference:press()
end

function SelectionElementReference:position_get()
	local pos = vmath.vector3(999, 999, 999)
	return pos
end

---@class SelectionElementContext:SelectionElement
local SelectionElementContext = COMMON.class("SelectionElementContext", SelectionElement)
function SelectionElementContext:initialize(config)
	SelectionElement.initialize(self, config)
	assert(self.config.context)
	assert(self.config.context_data)
end

function SelectionElementContext:select()
	COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " select", TAG)
	SelectionElement.select(self)
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		ctx.data:selection_select(self.config.context_data())
		ctx:remove()
	end
	return self
end
function SelectionElementContext:hide()
	COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " hide", TAG)
	SelectionElement.hide(self)
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		ctx.data:selection_hide(self.config.context_data())
		ctx:remove()
	end
end

function SelectionElementContext:hide_scene()
	COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " hide_scene", TAG)
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		ctx.data:selection_hide_scene()
		ctx:remove()
	end
end

function SelectionElementContext:can_select()
	local can_select = false
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		can_select = ctx.data:selection_can_select(self.config.context_data())
		COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " can_select:" .. tostring(can_select), TAG)
		ctx:remove()
	end
	return can_select
end

function SelectionElementContext:press()
	COMMON.i("SelectionElementContext " .. (self.config.name or "unknown") .. " press")
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		ctx.data:selection_press(self.config.context_data())
		ctx:remove()
	end
end

function SelectionElementContext:position_get()
	local pos = vmath.vector3()
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		local view = ctx.data:selection_get_view(self.config.context_data())
		if (view) then
			pos = gui.get_screen_position(view)
		end
		ctx:remove()
	end
	return pos
end

function SelectionElementContext:is_on_hover(x, y)
	if (COMMON.CONTEXT:exist(self.config.context)) then
		local ctx = COMMON.CONTEXT:set_context_top_by_name(self.config.context)
		local view = ctx.data:selection_get_view(self.config.context_data())
		if (view) then
			return gui.pick_node(view, x, y)
		end
		ctx:remove()
	end
	return false
end

local SelectionLine = COMMON.class("SelectionLine")
function SelectionLine:initialize(elements, config)
	self.elements = assert(elements)
	self.config = config
end

--В каждый момент времени, активна одна selection scene
---@class SelectionScene
local SelectionScene = COMMON.class("SelectionScene")

function SelectionScene:initialize(lines, config)
	---@type SelectionElement[][]
	self.lines = assert(lines)
	self.by_id = {}
	for y, line in ipairs(self.lines) do
		for x, elem in ipairs(line.elements) do
			if (elem.config.name) then
				assert(not self.by_id[elem.config.name], "elem with name exist:" .. elem.config.name)
				self.by_id[elem.config.name] = { elem = elem, x = x, y = y }
			end
		end
	end
	self.element_pos = vmath.vector3(0, 0, 0)
	---@type SelectionElement
	self.selected = nil;
	self.config = assert(config)
	assert(self.config.name)
end

function SelectionScene:set_white_list(list)
	self.white_list = list
end

function SelectionScene:press()
	if (self.selected) then
		self.pressed_by_keyboard = true
		self.selected:press()
		self.pressed_by_keyboard = false
	end
end

function SelectionScene:move_mouse(action)
	--check current element first
	if (self.selected and self.selected:is_on_hover(action.x, action.y)) then
		self.selected_by_mouse = nil
		self.selected_by_mouse_time = nil
		return true
	else
		self.is_mouse_move = true
		for _, line in ipairs(self.lines) do
			for _, element in ipairs(line.elements) do
				if (element:can_select() and element:is_on_hover(action.x, action.y)) then
					if(self.selected_by_mouse ~= element)then
						self.selected_by_mouse = element
						self.selected_by_mouse_time = socket.gettime()
					end
					self.is_mouse_move = false
				--	self:select_elem_by_id(element.config.name)
					return true
				end
			end
		end
		self.is_mouse_move = false
	end
	return false
end

function SelectionScene:update(dt)
	if(self.selected_by_mouse)then
		local delta_time = socket.gettime()-self.selected_by_mouse_time
		if(delta_time>0.05)then
			self.is_mouse_select = true
			self:select_elem_by_id(self.selected_by_mouse.config.name)
			self.is_mouse_select = false
		end
	end
end

---@param self SelectionScene
---@return SelectionElement
local check_elem_can_select = function(self, y, x)
	local line = self.lines[y]
	local elem = line.elements[x]
	if (self:element_can_select(elem)) then
		return elem
	end
end

function SelectionScene:line_find_first_element(y, x, right)
	local line = self.lines[y]
	if (right) then
		for i = x, #line.elements do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
		for i = 1, x - 1 do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
	else
		for i = x, 1, -1 do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
		for i = #line.elements, x + 1, -1 do
			local elem = check_elem_can_select(self, y, i)
			if (elem) then
				return elem, i, y
			end
		end
	end
end

function SelectionScene:line_find_near_element(prev_view, y)
	local line = self.lines[y]
	local start_pos = prev_view:position_get()
	local result_view = nil
	local result_x = -1
	local dist_max = math.huge
	for x = 1, #line.elements do
		local elem = check_elem_can_select(self, y, x)
		if (elem) then
			local end_pos = elem:position_get()
			local dist = vmath.length(end_pos - start_pos)
			if (dist < dist_max) then
				dist_max = dist
				result_view = elem
				result_x = x
			end
		end
	end
	return result_view, result_x
end

---@param element SelectionElement
function SelectionScene:element_can_select(element)
	if (self.white_list) then
		local id = element.config.name
		return self.white_list[id] and element:can_select()
	else
		return element:can_select()
	end
end

function SelectionScene:focus_move_left()
	if (self.selected) then
		local ids_to_move = self.selected:move_left()
		if (ids_to_move) then
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(-1, 0)
end
function SelectionScene:focus_move_right()
	if (self.selected) then
		local ids_to_move = self.selected:move_right()
		if (ids_to_move) then
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(1, 0)
end
function SelectionScene:focus_move_up()
	if (self.selected) then
		local ids_to_move = self.selected:move_top()
		if (ids_to_move) then
			if (type(ids_to_move) == "function") then
				ids_to_move = ids_to_move()
			end
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(0, -1)
end
function SelectionScene:focus_move_down()
	if (self.selected) then
		local ids_to_move = self.selected:move_bottom()
		if (ids_to_move) then
			for _, id_to_move in ipairs(ids_to_move) do
				local elem = self.by_id[id_to_move]
				if (id_to_move and elem and self:element_can_select(elem.elem)) then
					return self:select_elem_by_id(id_to_move)
				end
			end
		end
	end
	return self:focus_move(0, 1)
end

function SelectionScene:focus_move(dx, dy)
	self.selected_by_mouse_time = nil
	self.selected_by_mouse = nil

	self.element_start_search_pos = self.element_start_search_pos or vmath.vector3(self.element_pos)
	self.element_start_search_pos_counter_lines = self.element_start_search_pos_counter_lines or 0
	self.element_start_search_pos_counter = self.element_start_search_pos_counter or 0
	--fix infinity loop
	if (self.element_start_search_pos.x == 0 and self.element_start_search_pos.y == 0) then
		self.element_start_search_pos.x = dx
		self.element_start_search_pos.y = dy
	end
	local new_y = self.element_pos.y + dy
	local new_x = self.element_pos.x + dx

	--fixed infinity loop when no items are available for selection
	if (self.element_start_search_pos.x == new_x and self.element_start_search_pos.y == new_y) then
		self.element_start_search_pos_counter = self.element_start_search_pos_counter + 1
		if (self.element_start_search_pos_counter == 4) then
			COMMON.w("fixed infinity loop.Same item", TAG)

			self.element_start_search_pos = nil
			self.element_start_search_pos_counter = nil
			self.element_start_search_pos_counter_lines = nil
			return
		end
	end

	if (dy ~= 0 and self.element_start_search_pos.y == new_y) then
		self.element_start_search_pos_counter_lines = self.element_start_search_pos_counter_lines + 1
		if (self.element_start_search_pos_counter_lines == 4) then
			COMMON.w("fixed infinity loop.Same line", TAG)

			self.element_start_search_pos = nil
			self.element_start_search_pos_counter = nil
			self.element_start_search_pos_counter_lines = nil
			return
		end
	end

	if (dy ~= 0) then
		if (new_y < 1) then
			new_y = #self.lines;
		end
		if (new_y > #self.lines) then
			new_y = 1;
		end
		if (self.selected) then
			local near_elem, near_elem_x = self:line_find_near_element(self.selected, new_y)
			if (near_elem) then
				new_x = near_elem_x
			end
		end

		new_x = math.min(new_x, #self.lines[new_y].elements)
	end
	local line = self.lines[new_y]
	if (dx ~= 0) then
		if (new_x < 1) then
			if (line.config.new_line_on_end) then
				new_y = new_y - 1
				if (new_y < 1) then
					new_y = #self.lines
				end
				line = self.lines[new_y]
				return self:focus_move(#line.elements - self.element_pos.x, new_y - self.element_pos.y)
			end
			new_x = #line.elements
		end
		if (new_x > #line.elements) then
			if (line.config.new_line_on_end) then
				new_y = new_y + 1
				if (new_y > #self.lines) then
					new_y = 1
				end
				line = self.lines[new_y]
				return self:focus_move(1 - self.element_pos.x, new_y - self.element_pos.y)
			end
			new_x = 1
		end
	end
	--print("x:" .. new_x .. " y:" .. new_y)
	local element = self.lines[new_y].elements[new_x]
	local new_x_save, new_y_save = new_x, new_y
	--print(element.config.name)
	if (not self:element_can_select(element)) then
		if (dx > 0) then
			element, new_x, new_y = self:line_find_first_element(new_y, new_x, true)
			if (new_x and new_x <= self.element_pos.x and line.config.new_line_on_end) then
				return self:focus_move_down()
			end
		end
		if (dx < 0) then
			element, new_x, new_y = self:line_find_first_element(new_y, new_x, false)
			if (new_x and new_x >= self.element_pos.x and line.config.new_line_on_end) then
				return self:focus_move_down()
			end
		end
	end

	if (not element or not self:element_can_select(element)) then
		if (dy ~= 0) then
			self.element_pos.x = new_x_save
			self.element_pos.y = new_y_save
			if (self.element_start_search_pos.x == self.element_pos.x and self.element_start_search_pos.y == self.element_pos.y) then
				COMMON.w("no selection", TAG)
				return
			end
			return self:focus_move(0, dy < 0 and -1 or 1)
		end
	end
	if (new_x and new_y) then
		self.element_pos.x, self.element_pos.y = new_x, new_y

		if (self.selected) then
			self.selected:hide()
		end
		self.selected = self.lines[self.element_pos.y].elements[self.element_pos.x]
		self.selected = self.selected:select()
		self.element_pos.x, self.element_pos.y = self.by_id[self.selected.config.name].x, self.by_id[self.selected.config.name].y
	end

	self.element_start_search_pos = nil
	self.element_start_search_pos_counter = nil
	self.element_start_search_pos_counter_lines = nil
end

function SelectionScene:select_elem_by_id(id)
	local elem = self.by_id[id]
	if elem then
		self:hide(true)
		self:focus_move(elem.x, elem.y)
	else
		COMMON.w("no elem with id:" .. id, TAG)
	end
end

function SelectionScene:show()
	COMMON.i("SelectionScene " .. self.config.name .. " show", TAG)
	if (#self.lines == 0) then
		return
	end --empty scene
	if (not self.selected) then
		if (self.config.default) then
			local elem = self.by_id[self.config.default]
			if elem then
				self:focus_move(elem.x, elem.y)
			else
				COMMON.w("no default elem with id:" .. self.config.default, TAG)
				self:focus_move(1, 1)
			end
		else
			self:focus_move(1, 1)
		end
		--can't select element.find first available
		if (not self.selected) then
			COMMON.w("can't select element.find first available", TAG)
			for y, line in ipairs(self.lines) do
				for x, elem in ipairs(line.elements) do
					print("check elem:" .. tostring(elem.config.name) .. " " .. tostring(self:element_can_select(elem)))
					if (self:element_can_select(elem)) then
						self.element_pos.x, self.element_pos.y = 0, 0
						self:focus_move(x, y)
						return
					end
				end
			end
		end
	else
		self.selected = self.selected:select()
	end
end
function SelectionScene:hide(reset)
	COMMON.i("SelectionScene " .. self.config.name .. " hide", TAG)
	if (self.selected) then
		self.selected:hide()
	end
	if (reset) then
		self.selected = nil
		self.element_pos.x, self.element_pos.y = 0, 0
	end
end

function SelectionScene:hide_scene()
	if(self.selected and self.selected.hide_scene)then
		self.selected:hide_scene()
	end
end

local Selection = COMMON.class("Selection")

function Selection:initialize()
	---@type SelectionScene
	self.scene_active = nil
	self.working = not COMMON.html5_is_mobile()
end

function Selection:update(dt)
	if(self.scene_active)then
		self.scene_active:update(dt)
	end
end

function Selection:set_white_list(list)
	if (not self.working) then
		return
	end
	COMMON.i("set white list", TAG)
	self.white_list = nil
	if (list) then
		assert(#list > 0)
		self.white_list = {}
		for _, name in ipairs(list) do
			self.white_list[name] = true
		end
	end

	if (self.scene_active) then
		self.scene_active:set_white_list(self.white_list)
		local selection = self.scene_active.selected
		if (selection) then
			if (self.white_list and not self.white_list[selection.config.name]) then
				self.scene_active:select_elem_by_id(list[1])
			end
		end
	end
end

function Selection:set_active_scene(scene, config)
	if (not self.working) then
		return
	end
	config = config or {}
	if (self.scene_active) then
		self.scene_active:hide(config.prev_reset)
	end
	self.scene_active = scene
	self.scene_active:set_white_list(self.white_list)
	self.scene_active:show()
end

local SEC = function(name, ctx, f, config)
	return SelectionElementContext(COMMON.LUME.merge_table(config or {}, { context = ctx, context_data = f, name = name }))
end

local DEBUG = function(name, f)
	return SelectionElementContext({ context = CTXS.NAMES.DEBUG_GUI, context_data = f, name = name })
end

local CHOOSE_ITEM_CTX = assert(CTXS.NAMES.CHOOSE_ITEM_GUI)
---@return ChooseItemGuiScript
local CHOOSE_ITEM_DATA = function()
	return assert(CTXS:get(CHOOSE_ITEM_CTX).data)
end

local SEC_CHOOSE_ITEM = function(name, f, config)
	local item_config = { context = CHOOSE_ITEM_CTX, context_data = assert(f), name = name }
	if (config) then
		item_config = COMMON.LUME.merge(item_config, config)
	end
	return SelectionElementContext(item_config)
end

local CHEST_DATA = function()
	return assert(CTXS:get(CTXS.NAMES.CHEST_GUI).data)
end

local SEC_CHEST = function(name, f, config)
	local item_config = { context = CTXS.NAMES.CHEST_GUI, context_data = assert(f), name = name }
	if (config) then
		item_config = COMMON.LUME.merge(item_config, config)
	end
	return SelectionElementContext(item_config)
end

local PAUSE_DATA = function()
	return assert(CTXS:get(CTXS.NAMES.PAUSE_GUI).data)
end

local SEC_PAUSE = function(name, f, config)
	local item_config = { context = CTXS.NAMES.PAUSE_GUI, context_data = assert(f), name = name }
	if (config) then
		item_config = COMMON.LUME.merge(item_config, config)
	end
	return SelectionElementContext(item_config)
end

local LOSE_DATA = function()
	return assert(CTXS:get(CTXS.NAMES.LOSE_GUI).data)
end

local SEC_LOSE = function(name, f, config)
	local item_config = { context = CTXS.NAMES.LOSE_GUI, context_data = assert(f), name = name }
	if (config) then
		item_config = COMMON.LUME.merge(item_config, config)
	end
	return SelectionElementContext(item_config)
end

---@return SelectHeroSceneGuiScript
local SELECT_HERO_DATA = function()
	return assert(CTXS:get(CTXS.NAMES.SELECT_HERO_SCENE_GUI).data)
end

local SEC_SELECT_HERO = function(name, f, config)
	local item_config = { context = CTXS.NAMES.SELECT_HERO_SCENE_GUI, context_data = assert(f), name = name }
	if (config) then
		item_config = COMMON.LUME.merge(item_config, config)
	end
	return SelectionElementContext(item_config)
end

local SEC_SELECT_HERO_BUTTONS = function(name, f, config)
	local item_config = { context = CTXS.NAMES.SELECT_HERO_SCENE_GUI, context_data = assert(f), name = name,
						  move_top = function()
							  local data = SELECT_HERO_DATA()
							  return { "hero_" .. data.selected_hero_idx }
						  end, move_bottom = { name } }
	if (config) then
		item_config = COMMON.LUME.merge(item_config, config)
	end
	return SelectionElementContext(item_config)
end

local LINE_BREAK = function(line)
	return SelectionLine(line, { new_line_on_end = true })
end

local LINE_NO_BREAK = function(line)
	return SelectionLine(line, { new_line_on_end = false })
end

local M = {}

function M.init()
	M.SELECTION = Selection()
	M.SCENES = {
		ChooseItemScene = SelectionScene(COMMON.LUME.mix_table({ }, {
			LINE_NO_BREAK({ SEC_CHOOSE_ITEM("Item1", function()
				return assert(CHOOSE_ITEM_DATA()).views.cells[1]
			end), SEC_CHOOSE_ITEM("Item2", function()
				return assert(CHOOSE_ITEM_DATA()).views.cells[2]
			end), SEC_CHOOSE_ITEM("Item3", function()
				return assert(CHOOSE_ITEM_DATA()).views.cells[3]
			end), SEC_CHOOSE_ITEM("Item4", function()
				return assert(CHOOSE_ITEM_DATA()).views.cells[4]
			end) }),
			LINE_NO_BREAK({ SEC_CHOOSE_ITEM("BtnReroll", function()
				return assert(CHOOSE_ITEM_DATA()).views.btn_reroll
			end, { move_top = { "Item2" }, move_bottom = { "BtnReroll" }, move_left = { "Item1" }, move_right = { "Item4", "Item3" } }) })
		}), { name = "ChooseItemScene", default = "Item1" }),

		PauseScene = SelectionScene(COMMON.LUME.mix_table({ }, {
			LINE_NO_BREAK({
				SEC_PAUSE("btn_back", function() return assert(PAUSE_DATA()).views.btn_back
				end)
			}),
			LINE_NO_BREAK({
				SEC_PAUSE("btn_main_menu", function() return assert(PAUSE_DATA()).views.btn_main_menu
				end)
			}),
			LINE_NO_BREAK({
				SEC_PAUSE("btn_sound", function() return assert(PAUSE_DATA()).views.btn_sound
				end),
				SEC_PAUSE("btn_music", function() return assert(PAUSE_DATA()).views.btn_music
				end)
			}),
		}), { name = "PauseScene", default = "btn_back" }),

		ChestScene = SelectionScene(COMMON.LUME.mix_table({ }, {
			LINE_NO_BREAK({
				SEC_CHEST("btn_open", function() return assert(CHEST_DATA()).views.btn_open
				end),
				SEC_CHEST("btn_take", function() return assert(CHEST_DATA()).views.btn_take
				end),
				SEC_CHEST("btn_open_ads", function() return assert(CHEST_DATA()).views.btn_open_ads end) }),
			LINE_NO_BREAK({
				SEC_CHEST("btn_leave", function() return assert(CHEST_DATA()).views.btn_leave
				end) }),
		}), { name = "ChestScene", default = "btn_open" }),

		LoseScene = SelectionScene(COMMON.LUME.mix_table({ }, {
			LINE_NO_BREAK({
				SEC_LOSE("btn_ok", function() return assert(LOSE_DATA()).views.btn_ok
				end),
				SEC_LOSE("btn_revive", function() return assert(LOSE_DATA()).views.btn_revive
				end),
			})
		}), { name = "LoseScene", default = "btn_ok" }),

		SelectHeroScene = SelectionScene(COMMON.LUME.mix_table({ }, {
			LINE_NO_BREAK({
				SEC_SELECT_HERO("hero_1", function() return assert(SELECT_HERO_DATA()).views.cells[1]
				end),
				SEC_SELECT_HERO("hero_2", function() return assert(SELECT_HERO_DATA()).views.cells[2]
				end),
				SEC_SELECT_HERO("hero_3", function() return assert(SELECT_HERO_DATA()).views.cells[3]
				end),
				SEC_SELECT_HERO("hero_4", function() return assert(SELECT_HERO_DATA()).views.cells[4]
				end),
				SEC_SELECT_HERO("hero_5", function() return assert(SELECT_HERO_DATA()).views.cells[5]
				end),
			}),
			LINE_NO_BREAK({
				SEC_SELECT_HERO_BUTTONS("btn_unlock", function() return assert(SELECT_HERO_DATA()).views.btn_unlock
				end),
				SEC_SELECT_HERO_BUTTONS("btn_upgrade", function() return assert(SELECT_HERO_DATA()).views.btn_upgrade
				end),
				SEC_SELECT_HERO_BUTTONS("btn_play", function() return assert(SELECT_HERO_DATA()).views.btn_play end),
			}),
		}), { name = "SelectHeroScene", default = "btn_play" })
	}

	M.subscription = COMMON.RX.SubscriptionsStorage()
	M.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.SCENE_CHANGED):subscribe(function(data)
		local selection = M.SCENES[data.scene]
		if (selection) then
			M.SELECTION:set_active_scene(selection, { prev_reset = true })
		else
			if (M.SELECTION.scene_active) then
				M.SELECTION.scene_active:hide(true)
				M.SELECTION.scene_active = nil
			end
		end
	end)
end

return M


