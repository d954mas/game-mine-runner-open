local CLASS = require "libs.middleclass"
local LUME = require "libs.lume"
local LOG = require "libs.log"
local Thread = require "libs.thread"

local TAG = "ThreadManager"
---@class ThreadManager:Thread
local ThreadManager = CLASS.class("ThreadManager", Thread)

function ThreadManager:initialize()
	Thread.initialize(self)
	---@type Thread[]
	self.childs = {}
end

---@return Thread
function ThreadManager:add(data)
	local thread
	if type(data) == "function" then thread = Thread(data)
	elseif type(data) == "table" and data.isInstanceOf and data:isInstanceOf(Thread) then
		thread = data
	end
	assert(thread, "unknown thread type for data:" .. tostring(data))

	if(self.updating)then
		LOG.warning("add thread in update", TAG)
		table.insert(self.childs, thread)
	else
		table.insert(self.childs, 1, thread)
	end
	return thread
end
function ThreadManager:remove(thread)
	local idx = LUME.findi(self.childs, thread)
	if idx then
		table.remove(self.childs, idx)
	else
		LOG.warning("Can't remove.No such thread", TAG)
	end
	if(self.updating)then
		LOG.warning("remove thread in update", TAG)
	end
end

function ThreadManager:clear()
	self.childs = {}
	if(self.updating)then
		LOG.warning("clear thread in update", TAG)
	end
end

function ThreadManager:is_empty()
	return #self.childs == 0
end

function ThreadManager:on_update(dt)
	self.updating = true
	for i = #self.childs, 1, -1 do
		local child = self.childs[i]
		child:update(dt)
		if child:is_finished() then
			table.remove(self.childs, i)
		end
	end
	self.updating = false
end

return ThreadManager