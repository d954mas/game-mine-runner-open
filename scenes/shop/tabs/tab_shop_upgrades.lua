local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local GUI = require "libs_project.gui.gui"
local DEFS = require "world.balance.def.defs"
local WORLD = require "world.world"
local Base = require "libs_project.base_tab"

local UpgradeCell = COMMON.class("UpgradeCell")

function UpgradeCell:initialize(root_name)
	self.vh = {
		root = gui.get_node(root_name .. "/root"),
		lbl_price = gui.get_node(root_name .. "/btn_upgrade/label"),
		max_level = gui.get_node(root_name .. "/max_level"),
		lbl_price_icon = gui.get_node(root_name .. "/btn_upgrade/icon"),
		lbl_title = gui.get_node(root_name .. "/lbl_title"),
		lbl_description = gui.get_node(root_name .. "/lbl_description"),
		lbl_level = gui.get_node(root_name .. "/lbl_level"),
		lbl_level_description = gui.get_node(root_name .. "/lbl_level_description"),
		icon = gui.get_node(root_name .. "/icon")
	}

	self.views = {
		btn_upgrade = GUI.ButtonScale(root_name .. "/btn_upgrade")
	}
	self.def = nil
	self.level = 1
	self.views.btn_upgrade:set_input_listener(function()
		WORLD.storage.upgrades:level_up(self.def.id)
	end)
end

function UpgradeCell:set_def(def)
	self.def = assert(def)
	gui.set_text(self.vh.lbl_title, COMMON.LOCALIZATION["upgrade_" .. self.def.id .. "_title"]())
	gui.set_text(self.vh.lbl_description, COMMON.LOCALIZATION["upgrade_" .. self.def.id .. "_description"]())
	gui.play_flipbook(self.vh.icon, self.def.icon)
	self:check_level()
end

function UpgradeCell:check_level()
	self.level = WORLD.storage.upgrades:get_level(self.def.id)
	local level_def = assert(self.def.levels[self.level])
	gui.set_text(self.vh.lbl_level, "LVL " .. self.level)
	if (self.def == DEFS.POWERUPS.MORE_GEMS) then
		gui.set_text(self.vh.lbl_level_description, COMMON.LOCALIZATION["upgrade_MORE_GEMS_description2"]({count = level_def.gems}))
	else
		gui.set_text(self.vh.lbl_level_description, COMMON.LOCALIZATION["upgrade_DURATION_description2"]({count = level_def.duration}))
	end
	local max_level = WORLD.storage.upgrades:is_max_level(self.def.id)
	self.views.btn_upgrade:set_enabled(not max_level)
	gui.set_enabled(self.vh.max_level, max_level)
	gui.set_text(self.vh.lbl_price, WORLD.storage.upgrades:get_price(self.def.id))
	GUI.set_nodes_to_center(self.vh.lbl_price, true, self.vh.lbl_price_icon, false, 3)
end

function UpgradeCell:on_input(action_id, action)
	return self.views.btn_upgrade:on_input(action_id, action)

end

---@class ShopUpgradesTab:GameTabBase
local Tab = COMMON.class("ShopUpgradesTab", Base)

function Tab:initialize(root_name)
	Base.initialize(self, root_name)
	self.actions = ACTIONS.Parallel()
	self.actions.drop_empty = false
end

function Tab:bind_vh()
	self.vh = {
		title = gui.get_node("tab_upgrades_tab/title")
	}

	self.views = {
		cells = {
			UpgradeCell("tab_upgrades/cell_1"),
			UpgradeCell("tab_upgrades/cell_2"),
			UpgradeCell("tab_upgrades/cell_3"),
			UpgradeCell("tab_upgrades/cell_4")
		}

	}
end

function Tab:init_gui()
	Base.init_gui(self)
	self.views.cells[1]:set_def(DEFS.POWERUPS.MAGNET)
	self.views.cells[2]:set_def(DEFS.POWERUPS.STAR)
	self.views.cells[3]:set_def(DEFS.POWERUPS.RUN)
	self.views.cells[4]:set_def(DEFS.POWERUPS.MORE_GEMS)
	gui.set_text(self.vh.title, COMMON.LOCALIZATION.upgrades_title())
end

function Tab:update(dt)
	Base.update(self, dt)
end

function Tab:on_storage_changed()
	Base.on_storage_changed(self)
	for _, cell in ipairs(self.views.cells) do
		cell:check_level()
	end
end

function Tab:on_input(action_id, action)
	if (self.ignore_input) then return false end
	for _, cell in ipairs(self.views.cells) do
		if (cell:on_input(action_id, action)) then return true end
	end
end

return Tab