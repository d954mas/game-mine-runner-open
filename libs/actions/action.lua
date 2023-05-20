local COMMON = require "libs.common"
local Thread = require "libs.thread"

---@class Action:Thread
local Action = COMMON.class("Action",Thread)
Action.__use_current_context = false

function Action:initialize(config)
	config = config or {}
	self.config = config
	Thread.initialize(self,function (dt)
		self:act(dt)
	end)
	self:config_check(self.config)
	if self.config.script_context or self.__use_current_context then
		self:context_use(self.config.script_context)
	end
end

function Action:config_check(config) end

function Action:act(dt)

end

function Action:reset()
	self.coroutine = coroutine.create(self.fun_init)
end

function Action:force_finish()

	while(not self:is_empty())do
		self:update(0.25)
	end
end

return Action