local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local GUI = require "libs_project.gui.gui"
local RENDER_3D = require "scene3d.render.render3d"
local DEFS = require "world.balance.def.defs"
local WORLD = require "world.world"
local Base = require "libs_project.base_tab"

local PARAMS = {
	LOCKED = {
		border_color = COMMON.LUME.color_parse_hex("#2A2A2A"),
		icon_color = COMMON.LUME.color_parse_hex("#222222")
	},
	SELECTED = {
		border_color = COMMON.LUME.color_parse_hex("#B9B9B9"),
		icon_color = COMMON.LUME.color_parse_hex("#ffffff")
	},
	AVAILABLE = {
		border_color = COMMON.LUME.color_parse_hex("#636363"),
		icon_color = COMMON.LUME.color_parse_hex("#ffffff")
	},
	CURRENT = {
		border_color = COMMON.LUME.color_parse_hex("#6BDCFF"),
		icon_color = COMMON.LUME.color_parse_hex("#ffffff")
	}
}

local PARTS = {
	ROOT = hash("/root"),
}

local SkinCell = COMMON.class("SkinCell", GUI.ButtonScale)

function SkinCell:initialize(root_name)
	GUI.ButtonScale.initialize(self, root_name)
	self.vh.icon = gui.get_node(root_name .. "/icon")
	self.vh.border = gui.get_node(root_name .. "/border")
	self.vh.accept = gui.get_node(root_name .. "/accept")
end

function SkinCell:set_def(def)
	self.def = assert(def)
	gui.play_flipbook(self.vh.icon, def.icon)
end

function SkinCell:set_border_color(border_color)
	gui.set_color(self.vh.border, border_color)
end

function SkinCell:set_icon_color(icon_color)
	gui.set_color(self.vh.icon, icon_color)
end

function SkinCell:set_accepted(accepted)
	gui.set_enabled(self.vh.accept, accepted)
end

---@class ShopSkinTab:GameTabBase
local Tab = COMMON.class("ShopSkinTab", Base)

function Tab:initialize(root_name)
	Base.initialize(self, root_name)
	self.actions = ACTIONS.Parallel()
	self.actions.drop_empty = false
end

function Tab:bind_vh()
	self.vh = {
		model_pos = gui.get_node("tab_skins/model_pos"),
		lbl_name = gui.get_node("tab_skins/lbl_name"),
		current_accept = gui.get_node("tab_skins/current_accept"),
		model_border = gui.get_node("tab_skins/model/border"),
		model_title_border = gui.get_node("tab_skins/model_title/border"),
		title = gui.get_node("tab_skins_tab/title"),
		btn_unlock_ads_lbl = gui.get_node("tab_skins/btn_unlock_ads/lbl"),
		btn_use_lbl = gui.get_node("tab_skins/btn_use/lbl")
	}
	self.model_go = {
		root = msg.url("shop_scene:/skin_go"),
		model = {
			root = nil,
			model = nil
		},
	}
	self.skin_position = vmath.vector3(0, 0, 0)
	self.skin_scale = vmath.vector3(0.001)
	self.base_scale = vmath.vector3(0.22)
	self.skin_alpha = 0
	self.skin_def = nil

	self.views = {
		cells = {},
		btn_use = GUI.ButtonScale("tab_skins/btn_use"),
		btn_buy = GUI.ButtonScale("tab_skins/btn_buy"),
		btn_ads = GUI.ButtonScale("tab_skins/btn_unlock_ads")
	}
	self.views.btn_buy.vh.lbl_price = gui.get_node("tab_skins/btn_buy/lbl_price")
	self.views.btn_buy.vh.icon = gui.get_node("tab_skins/btn_buy/icon")
	for i = 1, 12 do
		local cell = SkinCell("tab_skins/cell_" .. i)
		self.views.cells[i] = cell
		cell:set_input_listener(function()
			self:choose_skin(i)
		end)
		cell.input_on_pressed = true
		cell:set_def(DEFS.SKINS.SKIN_LIST[i])
	end

	self.views.btn_buy:set_input_listener(function()
		WORLD.storage.skins:skin_buy(self.skin_def.id)
		WORLD.storage.game:skin_set(self.skin_def.id)
		self:skin_update_state()
	end)

	self.views.btn_use:set_input_listener(function()
		WORLD.storage.game:skin_set(self.skin_def.id)
		self:skin_update_state()
	end)

	self.views.btn_ads:set_input_listener(function()
		WORLD.sdk:ads_rewarded(function(success)
			if success then
				WORLD.storage.skins:skin_buy(self.skin_def.id, true)
				WORLD.storage.game:skin_set(self.skin_def.id)
				self:skin_update_state()
			end
		end)
	end)
end

function Tab:skin_update_state()
	local have = WORLD.storage.skins:skin_have(self.skin_def.id)
	local price = self.skin_def.price

	local is_current = self.skin_def.id == WORLD.storage.game:skin_get()



	if (not have) then
		local unlock_ads = DEFS.SKINS.SKINS_BY_ID[self.skin_def.id].unlock_by_ads
		self.views.btn_buy:set_enabled(not unlock_ads)
		self.views.btn_ads:set_enabled(unlock_ads)
		self.views.btn_use:set_enabled(false)
		gui.set_enabled(self.vh.current_accept,false)
		gui.set_color(self.vh.model_border,PARAMS.LOCKED.border_color)
		gui.set_color(self.vh.model_title_border,PARAMS.LOCKED.border_color)
	else
		self.views.btn_buy:set_enabled(false)
		self.views.btn_ads:set_enabled(false)
		self.views.btn_use:set_enabled(not is_current)
		gui.set_enabled(self.vh.current_accept,is_current)
		gui.set_color(self.vh.model_border,is_current and PARAMS.CURRENT.border_color or PARAMS.SELECTED.border_color)
		gui.set_color(self.vh.model_title_border,is_current and PARAMS.CURRENT.border_color or PARAMS.SELECTED.border_color)
	end



	gui.set_text(self.views.btn_buy.vh.lbl_price, price)
	GUI.set_nodes_to_center(self.views.btn_buy.vh.lbl_price, true, self.views.btn_buy.vh.icon, false, 3)
	gui.set_text(self.vh.lbl_name, COMMON.LOCALIZATION["name_" .. self.skin_def.name]())

	self:update_cells()
end

function Tab:choose_skin(i)
	local def = assert(DEFS.SKINS.SKIN_LIST[i])

	if (self.skin_def ~= def) then
		local ctx = COMMON.CONTEXT:set_context_top_shop()
		if (self.model_go.model.root ~= nil) then
			go.delete(self.model_go.model.root, true)
		end
		self.skin_def = def

		local factory_url = self.skin_def.factory_skin
		local collection = collectionfactory.create(factory_url, nil, vmath.quat_rotation_y(math.rad(25)), nil, vmath.vector3(0.001))
		self.model_go.model.root = msg.url(assert(collection[PARTS.ROOT]))
		self.model_go.model.model = COMMON.LUME.url_component_from_url(self.model_go.model.root, COMMON.HASHES.MODEL)
		go.set(self.model_go.model.model, COMMON.HASHES.TINT_W, 0)
		ctx:remove()

		self:skin_update_state()
	end

end

function Tab:update_cells()
	for _, cell in ipairs(self.views.cells) do
		local def = cell.def
		local have = WORLD.storage.skins:skin_have(def.id)
		local selected = self.skin_def.id == def.id
		local current = WORLD.storage.game:skin_get() == def.id
		if (selected) then
			cell:set_border_color(PARAMS.SELECTED.border_color)
		elseif (have) then
			cell:set_border_color(PARAMS.AVAILABLE.border_color)
		else
			cell:set_border_color(PARAMS.LOCKED.border_color)
		end

		cell:set_icon_color(have and PARAMS.AVAILABLE.icon_color or PARAMS.LOCKED.icon_color)
		cell:set_accepted(current)
	end
end

function Tab:init_gui()
	Base.init_gui(self)
	gui.set_text(self.vh.title,COMMON.LOCALIZATION.skins_title())
	gui.set_text(self.vh.btn_unlock_ads_lbl,COMMON.LOCALIZATION.btn_unlock_ads_lbl())
	gui.set_text(self.vh.btn_use_lbl,COMMON.LOCALIZATION.btn_skin_use_lbl())
end


-- Vectors used in calculations for public transform functions
local nv = vmath.vector4(0, 0, -1, 1)
local fv = vmath.vector4(0, 0, 1, 1)
local pv = vmath.vector4(0, 0, 0, 1)

function Tab:world_to_screen(pos, raw)
	local mat_view = RENDER_3D.camera_view()
	local mat_proj = RENDER_3D.camera_perspective(math.rad(50))
	local m = mat_proj * mat_view
	pv.x, pv.y, pv.z, pv.w = pos.x, pos.y, pos.z, 1

	pv = m * pv
	pv = pv * (1 / pv.w)
	pv.x = (pv.x / 2 + 0.5) * RENDER_3D.window_width
	pv.y = (pv.y / 2 + 0.5) * RENDER_3D.window_height

	if raw then return pv.x, pv.y, 0 end
end
-- Returns start and end points for a ray from the camera through the supplied screen coordinates
-- Start point is on the camera near plane, end point is on the far plane.
local QUAT_Z = vmath.quat_rotation_x(math.rad(0))
function Tab:screen_to_world_ray(x, y, raw)
	local plane_far = RENDER_3D.far
	RENDER_3D.far = 2
	local view_rotation = RENDER_3D.view_rotation
	local view_front = vmath.vector3(RENDER_3D.view_front)
	local view_right = vmath.vector3(RENDER_3D.view_right)
	local view_up = vmath.vector3(RENDER_3D.view_up)
	local view_position = RENDER_3D.view_position
	RENDER_3D.view_position = vmath.vector3(0, 0, 0)
	RENDER_3D.view_from_rotation(QUAT_Z)
	local mat_view = RENDER_3D.camera_view()
	local mat_proj = RENDER_3D.camera_perspective(math.rad(50))
	RENDER_3D.far = plane_far
	RENDER_3D.view_rotation = view_rotation
	RENDER_3D.view_front = view_front
	RENDER_3D.view_right = view_right
	RENDER_3D.view_up = view_up
	RENDER_3D.view_position = view_position

	local window_x = RENDER_3D.window_width
	local window_y = RENDER_3D.window_height
	local m = vmath.inv(mat_proj * mat_view)

	-- Remap coordinates to range -1 to 1
	local x1 = (x - window_x * 0.5) / window_x * 2
	local y1 = (y - window_y * 0.5) / window_y * 2

	nv.x, nv.y = x1, y1
	fv.x, fv.y = x1, y1
	local np = m * nv
	local fp = m * fv
	np = np * (1 / np.w)
	fp = fp * (1 / fp.w)

	if raw then return np.x, np.y, np.z, fp.x, fp.y, fp.z
	else return vmath.vector3(np.x, np.y, np.z), vmath.vector3(fp.x, fp.y, fp.z) end
end

local P1 = vmath.vector3()
local P2 = vmath.vector3()
function Tab:update_skin_go()
	local screen_pos = gui.get_screen_position(self.vh.model_pos)
	local aspect = COMMON.RENDER.screen_size.w / COMMON.RENDER.screen_size.h
	P1.x, P1.y, P1.z, P2.x, P2.y, P2.z = self:screen_to_world_ray(screen_pos.x, screen_pos.y, true)
	self.skin_position.x = P2.x
	self.skin_position.y = P2.y
	self.skin_position.z = P2.z

	if (aspect >= 16 / 9) then
		--	self.skin_position.z = -15
		--self.skin_position.y = -2
		self.skin_scale.x, self.skin_scale.y, self.skin_scale.z = self.base_scale.x, self.base_scale.y, self.base_scale.z
	else
		--self.skin_position.z = -15

		local delta_scale = aspect / (16 / 9)
		local scale = self.base_scale.x * delta_scale
		--self.skin_position.y = -2
		self.skin_scale.x, self.skin_scale.y, self.skin_scale.z = scale, scale, scale
	end

	xmath.mul(self.skin_scale, self.skin_scale, self.skin_def.scale.x)

	local ctx = COMMON.CONTEXT:set_context_top_shop()
	go.set_position(self.skin_position, self.model_go.model.root)
	go.set_scale(self.skin_scale, self.model_go.model.root)
	go.set(self.model_go.model.model, COMMON.HASHES.TINT_W, self.skin_alpha)
	ctx:remove()
end

function Tab:set_alpha(alpha)
	self.skin_alpha = alpha
end

function Tab:set_enabled(enabled)
	Base.set_enabled(self, enabled)
	if (enabled) then
		timer.delay(0, false, function()
			local skin_idx = COMMON.LUME.findi(DEFS.SKINS.SKIN_LIST, DEFS.SKINS.SKINS_BY_ID[WORLD.storage.game:skin_get()])
			self:choose_skin(skin_idx)
		end)
	end

	msg.post(self.model_go.root, enabled and COMMON.HASHES.MSG.ENABLE or COMMON.HASHES.MSG.DISABLE)
	if (self.model_go.model.root) then
		msg.post(self.model_go.model.root, enabled and COMMON.HASHES.MSG.ENABLE or COMMON.HASHES.MSG.DISABLE)
	end
end

function Tab:update(dt)
	Base.update(self, dt)
	self:update_skin_go()

end

function Tab:on_input(action_id, action)
	if (self.ignore_input) then return false end
	for _, cell in ipairs(self.views.cells) do
		if (cell:on_input(action_id, action)) then return true end
	end
	if (self.views.btn_use:on_input(action_id, action)) then return true end
	if (self.views.btn_buy:on_input(action_id, action)) then return true end
	if (self.views.btn_ads:on_input(action_id, action)) then return true end

end

return Tab