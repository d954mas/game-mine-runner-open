local _ = require "libs.checks"

reqf = _G.require -- to fix cyclic dependencies

local M = {}

--region log
M.LOG = require "libs.log"
function M.init_log()
    M.LOG.toggle_print()
    if(M.LOG.is_debug)then
        M.LOG.override_print()
    end
    M.LOG.add_to_blacklist("Sound")
    M.LOG.add_to_blacklist("States")
    M.LOG.add_to_blacklist("[SELECTION]")
    M.LOG.use_tag_blacklist = true

    local old_w = M.LOG.w
    M.LOG.w = function(message, tag, debug_level)
        old_w(message, tag, debug_level)
    end
end
M.init_log()
--endregion

M.GLOBAL = {
    time_init_start = socket.gettime()
}

M.Thread = require "libs.thread"
M.ThreadManager = require "libs.thread_manager"
M.EventBus = require "libs.event_bus"

M.HASHES = require "libs.hashes"
M.MSG = require "libs.msg_receiver"
M.CLASS = require "libs.middleclass"
M.LUME = require "libs.lume"
M.RX = require "libs.rx"
M.EVENTS = require "libs.events"
M.CONSTANTS = require "libs.constants"
M.COROUTINES = require "libs.coroutine"
M.CONTEXT = require "libs_project.contexts_manager"
M.JSON = require "libs.json"

M.LOCALIZATION = require "assets.localization.localization"

M.EVENT_BUS = M.EventBus() --global event_bus

M.N28S = require "libs.n28s"
---@type Render set inside render. Used to get buffers outside from render
M.RENDER = nil

M.APPLICATION = {
    THREAD = M.ThreadManager()
}

--region input
M.INPUT = require "libs.input_receiver"
function M.input_acquire(url)
    M.INPUT.acquire(url)
end

function M.input_release(url)
    M.INPUT.release(url)
end
--endregion



---@type Features
M.FEATURES = nil



function M.t(message, tag)
    M.LOG.t(message, tag, 2)
end

function M.trace(message, tag)
    M.LOG.trace(message, tag, 2)
end

function M.d(message, tag)
    M.LOG.d(message, tag, 2)
end

function M.debug(message, tag)
    M.LOG.debug(message, tag, 2)
end

function M.i(message, tag)
    M.LOG.i(message, tag, 2)
end

function M.info(message, tag)
    M.LOG.info(message, tag, 2)
end

-- WARNING
function M.w(message, tag)
    M.LOG.w(message, tag, 2)
end

function M.warning(message, tag)
    M.LOG.warning(message, tag, 2)
end

-- ERROR
function M.e(message, tag)
    M.LOG.e(message, tag, 2)
end

function M.error(message, tag)
    M.LOG.error(message, tag, 2)
end

--endregion


--region class
function M.class(name, super)
    return M.CLASS.class(name, super)
end

function M.new_n28s()
    return M.CLASS.class("NewN28S", M.N28S.Script)
end
--endregion

---@return coroutine|nil return coroutine if it can be resumed(no errors and not dead)
function M.coroutine_resume(cor, ...)
    return M.COROUTINES.coroutine_resume(cor, ...)
end

function M.coroutine_wait(time)
    M.COROUTINES.coroutine_wait(time)
end

--generate empty table for native extension.
--use it on system that not supported
function M.empty_ne(name, ignore_log)
    if not _G[name] then
        local t = {}
        local mt = {}
        local f = function()
        end
        function mt.__index(_, k)
            if not ignore_log then
                M.w("NE", "index empty ne:" .. k)
            end
            return f
        end
        function mt.__newindex(_, k, _)
            if not ignore_log then
                M.w("NE", "newindex empty ne:" .. k)
            end
            return
        end
        setmetatable(t, mt)
        _G[name] = t
    end
end

function M.is_class(data)
    if (type(data) == "table" and data.initialize) then
        return true
    end
    return false
end

function M.html5_is_mobile()
    if html5 then
        local value = html5.run('(typeof window.orientation !== \'undefined\') || (navigator.userAgent.indexOf(\'IEMobile\') !== -1);')
        return value == "true"
    else
        return false
    end
end

return M