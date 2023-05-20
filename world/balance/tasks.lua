local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"
local TASKS = DEFS.TASKS


local TASKS_RUN_TYPES = {
	[TASKS.TYPE.COLLECT_COINS_RUN] = true,
	[TASKS.TYPE.RUN_POINTS_RUN] = true,
}

---@class Tasks
local Tasks = COMMON.class("Tasks")

---@param game GameWorld
function Tasks:initialize(game)
	checks("?", "class:GameWorld")
	self.game = game
	self.storage = self.game.world.storage
	self.run_data = {
		gems = 0,
		points = 0
	}
end

function Tasks:get_def_list()
	local list_idx = self.storage.data.tasks.tasks_idx
	local def_list
	local max_list_idx = #DEFS.TASKS.MISSION_LIST
	if (list_idx > max_list_idx) then
		def_list = DEFS.TASKS.MISSION_LIST[max_list_idx]
	else
		def_list = DEFS.TASKS.MISSION_LIST[list_idx]
	end
	return def_list
end

function Tasks:get_def(idx)
	return self:get_def_list()[idx]
end

function Tasks:is_completed(idx)
	return self.storage.tasks:is_completed(idx)
end

function Tasks:start_run()
	self.run_data.gems = 0
	self.run_data.points = 0
	self:add_value_to_type(TASKS.TYPE.PLAY_RUN, 1)
end

function Tasks:finish_run()
	self.run_data.gems = 0
	self.run_data.points = 0
end

function Tasks:run_add_gems(gems)
	self.run_data.gems = self.run_data.gems + gems
	self:check_run_value_to_type(TASKS.TYPE.COLLECT_COINS_RUN, self.run_data.gems)
	--self:add_gems(gems)
end

function Tasks:run_add_points(points)
	self.run_data.points = self.run_data.points + points
	self:check_run_value_to_type(TASKS.TYPE.RUN_POINTS_RUN, self.run_data.points)
	self:add_value_to_type(TASKS.TYPE.RUN_POINTS_TOTAL, points)
end

function Tasks:add_gems(gems)
	self:add_value_to_type(TASKS.TYPE.COLLECT_COINS_TOTAL, gems)
end

function Tasks:powerup_collected(type)
	self:add_value_to_type(TASKS.TYPE.COLLECT_POWER_UPS_TOTAL, 1)
	if (type == DEFS.POWERUPS.RUN.id) then
		self:add_value_to_type(TASKS.TYPE.COLLECT_POWER_UPS_SPEED_TOTAL, 1)
	elseif (type == DEFS.POWERUPS.MAGNET.id) then
		self:add_value_to_type(TASKS.TYPE.COLLECT_POWER_UPS_MAGNET_TOTAL, 1)
	elseif (type == DEFS.POWERUPS.STAR.id) then
		self:add_value_to_type(TASKS.TYPE.COLLECT_POWER_UPS_X2_TOTAL, 1)
	end
end

function Tasks:skin_changed()
	self:add_value_to_type(TASKS.TYPE.CHANGE_SKIN, 1)
end

function Tasks:complete_tutorial()
	self:add_value_to_type(TASKS.TYPE.COMPLETE_TUTORIAL, 1)
end

function Tasks:daily_gems_completed()
	self:add_value_to_type(TASKS.TYPE.COMPLETE_DAILY_GEMS, 1)
end

function Tasks:add_value(idx, add)
	local tutorial_completed = self.storage.game:is_tutorial_completed() or idx == DEFS.TASKS.TYPE.COMPLETE_TUTORIAL
	if (tutorial_completed and not self:is_completed(idx)) then
		local def = self:get_def(idx)
		local value = self.storage.tasks:get_value(idx)
		value = math.min(value + add, def.value)
		self.storage.tasks:set_value(idx, value)
		if (value >= def.value) then
			self.storage.tasks:set_completed(idx, true)
		end
	end
end

function Tasks:check_run_value_to_type(type, value)
	local def_list = self:get_def_list()
	for i = 1, 3 do
		local def = def_list[i]
		if not (self:is_completed(i)) then
			if (def.type == type) then
				if (value >= def.value) then
					self.storage.tasks:set_completed(i)
				end
			end
		end
	end
end

function Tasks:add_value_to_type(type, value)
	local def_list = self:get_def_list()
	for i = 1, 3 do
		local def = def_list[i]
		--if not (self:is_completed(i)) then
		if (def.type == type) then
			self:add_value(i, value)
		end
		--end
	end
end

function Tasks:get_value(idx)
	if (self:is_completed(idx)) then
		return self:get_max_value(idx)
	else
		if (self.game.state.state == ENUMS.GAME_STATE.MENU) then
			return self.storage.tasks:get_value(idx)
		else
			local def = self:get_def(idx)
			local type = def.type
			if (TASKS_RUN_TYPES[type]) then
				if (type == TASKS.TYPE.RUN_POINTS_RUN) then
					return self.run_data.points
				elseif (type == TASKS.TYPE.COLLECT_COINS_RUN) then
					return self.run_data.gems
				else
					error("unknow type:" .. type)
				end
			else
				return self.storage.tasks:get_value(idx)
			end
		end

	end
end

function Tasks:get_max_value(idx)
	local def = self:get_def(idx)
	return def.value
end

function Tasks:get_title(idx)
	local def = self:get_def(idx)
	local key = "task_" .. def.type
	local str = COMMON.LOCALIZATION[key]({ count = def.value})
	return str
end

return Tasks