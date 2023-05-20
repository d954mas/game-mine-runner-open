local COMMON = require "libs.common"
local ENUMS = require "world.enums.enums"
local StoragePart = require "world.storage.storage_part_base"

---@class TasksPartOptions:StoragePartBase
local Storage = COMMON.class("SkinsPartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.tasks = self.storage.data.tasks
end

function Storage:is_completed(idx)
	local task = assert(self.tasks.tasks[idx])
	return task.completed
end

function Storage:set_completed(idx)
	local task = assert(self.tasks.tasks[idx])
	task.completed = true
	COMMON.EVENT_BUS:event(COMMON.EVENTS.MISSION_COMPLETED,{idx = idx})
	self:save_and_changed()
end

function Storage:get_value(idx)
	local task = assert(self.tasks.tasks[idx])
	return task.value
end

function Storage:set_value(idx, value)
	local task = assert(self.tasks.tasks[idx])
	task.value = assert(value)
	--self:save_and_changed()
end

function Storage:collect_get_reward()
	local reward = {
		gems = math.min(200+(self.storage.game:stars_get()*50),1000),
		stars = 1
	}
	return reward
end

function Storage:collect_reward()
	local completed_all = true
	for i = 1, 3 do
		if not self.tasks.tasks[i].completed then
			completed_all = false
			break
		end
	end
	if (completed_all) then
		self.tasks.tasks_idx = self.tasks.tasks_idx + 1
		local reward = self:collect_get_reward()
		self.storage.game:gems_add(reward.gems,ENUMS.GEMS_ADD_TYPE.TASK_REWARD)
		self.storage.game:stars_add(reward.stars)

		for i = 1, 3 do
			self.tasks.tasks[i].completed = false
			self.tasks.tasks[i].value = 0
		end
	end
	self:save_and_changed()
end

return Storage