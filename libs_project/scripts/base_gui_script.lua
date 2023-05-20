local COMMON = require "libs.common"

---@class GuiScriptConfig
local ConfigTypeDef = {
    context_name = "?string",
    input = "?boolean" --true by default
}

---@class GuiScriptBase
local Script = COMMON.new_n28s()

function Script:bind_vh()
    self.vh = {}
    self.view = {}
end

function Script:init_gui()

end

---@param config GuiScriptConfig
function Script:init(config)
    checks("?",ConfigTypeDef)
    self.config = config or {}
    if(self.config.input == nil)then self.config.input = true end
    if(self.config.context_name) then COMMON.CONTEXT:register(self.config.context_name, self) end
    self:bind_vh()
    self.subscription = COMMON.RX.SubscriptionsStorage()
    self.scheduler = COMMON.RX.CooperativeScheduler.create()
    self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_CHANGED):go_distinct(self.scheduler):subscribe(function ()
        self:on_storage_changed()
    end))

    self:init_gui()
    self:on_storage_changed()
    if(self.config.input) then COMMON.input_acquire() end
end

function Script:update(dt)
    self.scheduler:update(dt)
end

function Script:on_storage_changed()

end

function Script:final()
    self.subscription:unsubscribe()
    if(self.config.context_name) then COMMON.CONTEXT:unregister(self.config.context_name) end
    if(self.config.input) then COMMON.input_release() end
end

return Script