local COMMON = require "libs.common"
local WORLD = require "world.world"
local SelectionView = require "libs_project.selection_view"

local GuiScriptBase = require "libs_project.scripts.base_gui_script"

local Script = COMMON.CLASS("SelectionGuiScript", GuiScriptBase)

function Script:init(...)
	GuiScriptBase.init(self, ...)
	self.__selection_view = SelectionView("__selection_view")
	self.selection = nil
end

--region selection
function Script:selection_select(data)
	if (not self.__selection_view) then

	end

	--Not play sound for first selection.
	--only when player change selection
	if(self.selection ~= nil)then
		if(self.selection == data)then
			WORLD.sounds:play_sound(WORLD.sounds.sounds.item_stayfocus_1)
		else
			WORLD.sounds:ui_item_select_sound()
		end

	end
	self.selection = data

	if (type(data) == "table") then
		--class
		if (data.initialize) then
			if (data.selection_select) then
				data:selection_select(self.__selection_view)
				return true
			end
		end
	end
	local view = self:selection_get_view(data)
	if (view) then
		self.__selection_view:select_view_size_by_view(view)
	else
		COMMON.w("no cell in view for select")
	end
end

function Script:selection_press(data)
	assert(self.__selection_view, "no selection view.")
	if (type(data) == "table") then
		--class
		if (data.initialize) then
			if (data.selection_press) then
				data:selection_press(self.__selection_view)
				return true
			end
		end

		local pos = gui.get_screen_position(self.__selection_view.vh.root)

		local absolute_x = pos.x / COMMON.RENDER.screen_size.w
		local absolute_y = pos.y / COMMON.RENDER.screen_size.h
		local new_pos = vmath.vector3(pos)
		new_pos.x = absolute_x * COMMON.CONSTANTS.GAME_SIZE.width
		new_pos.y = absolute_y * COMMON.CONSTANTS.GAME_SIZE.height
		print(string.format("selection pressed:(%f %f)(%f %f)", pos.x, pos.y, new_pos.x, new_pos.y))
		self:on_input(COMMON.HASHES.INPUT.TOUCH, { x = new_pos.x, y = new_pos.y, pressed = true })
		local current = lua_script_instance.Get()
		COMMON.APPLICATION.THREAD:add(function()
			COMMON.coroutine_wait(0.1)
			local id = COMMON.CONTEXT:set_context_top_by_instance(current)
			local success, error = pcall(function()
				self:on_input(COMMON.HASHES.INPUT.TOUCH, { x = new_pos.x, y = new_pos.y, released = true })
			end)
			if not success then print(error) end
			COMMON.CONTEXT:remove_context_top(id)
		end)

	end
end

function Script:selection_hide(data)
	assert(self.__selection_view, "no selection view.")

	if (type(data) == "table") then
		--class
		if (data.initialize) then
			if (data.selection_hide) then
				data:selection_hide(self.__selection_view)
				return
			end
		end
	end

	self.__selection_view:hide()
end

function Script:selection_hide_scene()
	self.selection = nil
end

function Script:selection_can_select(data)
	if (type(data) == "table") then
		--class
		if (data.initialize) then
			if (data.selection_can_select) then
				return data:selection_can_select(self.__selection_view)
			end
		end
	end

	local view = self:selection_get_view(data)
	if (view) then
		local enabled = gui.is_enabled(view)
		local parent = gui.get_parent(view)
		while (enabled and parent) do
			enabled = gui.is_enabled(parent)
			parent = gui.get_parent(parent)
		end
		return enabled
	else
		return false
	end
end

function Script:selection_get_view(data)
	if (data.vh) then
		local cell = data.vh.selection_select_cell or data.vh.root
		if (not cell) then
			COMMON.w("no cell in view for select")
			return nil
		end
		return cell
	elseif type(data.root) == "userdata" then
		return data.root
	elseif (type(data) == "userdata") then
		return data
	end
	return nil
end
--endregion

return Script