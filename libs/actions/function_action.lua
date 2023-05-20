local COMMON = require "libs.common"
local BaseAction = require "libs.actions.action"

---@class FunctionAction:Action
local Action = COMMON.class("FunctionAction", BaseAction)

function Action:config_check(config)
    assert(self.config.fun, "need function")
end

function Action:act(dt)
    self.config.fun()
end
return Action