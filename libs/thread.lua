local CLASS = require "libs.middleclass"
local COROUTINE = require "libs.coroutine"
local CONTEXT_MANAGER = require "libs_project.contexts_manager"
local LOG = require "libs.log"
local TAG = "Thread"

---@class Thread
local Thread = CLASS.class("Thread")

function Thread:initialize(fun)
	---@type thread
	self.coroutine = fun and coroutine.create(fun)
	self.fun_init = fun
	self.drop_empty = true
	self.speed = 1
	self.script_context = nil
    self.context_error = nil
end


function Thread:context_use(context)
	self.script_context = context or lua_script_instance.Get()
end

function Thread:is_empty()
	return not self.coroutine and true or false
end

function Thread:is_finished()
	return self:is_empty() and self.drop_empty
end

function Thread:is_running()
	return not self:is_finished()
end


function Thread:finish()
	while(not self:is_finished()) do self:update(1) end
end

function Thread:update_pre()
	if self.script_context then
		local no_error, ctx = pcall(CONTEXT_MANAGER.set_context_top_by_instance,CONTEXT_MANAGER,self.script_context)
		if(no_error)then
			self.old_context_id = ctx
			self.context_error = nil
		else
			self.context_error = ctx
			LOG.w("can't set context",TAG)
			pprint(ctx)
		end
	end
end

function Thread:update(dt)
	self:update_pre()
	dt = dt * self.speed
	self:on_update(dt)
	self:update_post()
end

function Thread:update_post()
	if self.old_context_id then
		CONTEXT_MANAGER:remove_context_top(self.old_context_id)
		self.old_context_id = nil
	end
	self.context_error = nil
end

function Thread:on_update(dt)
	if self.coroutine then
		self.coroutine = COROUTINE.coroutine_resume(self.coroutine, dt)
	end
end



return Thread