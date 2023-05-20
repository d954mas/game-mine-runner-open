local ECS = require 'libs.ecs'

---@class AutoDestroySystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.filter("auto_destroy|auto_destroy_delay|auto_destroy_delay_2")
System.name = "AutoDestroySystem"

function System:init()

end

---@param e EntityGame
function System:process(e, dt)
    if e.auto_destroy_delay then
        e.auto_destroy_delay = e.auto_destroy_delay - dt
        if e.auto_destroy_delay <= 0 then
            e.auto_destroy = true
        end
    end
    if e.auto_destroy_delay_2 then
        e.auto_destroy_delay_2 = e.auto_destroy_delay_2 - 1/60
        if e.auto_destroy_delay_2 <= 0 then
            e.auto_destroy = true
        end
    end
    if e.auto_destroy then
        self.world:removeEntity(e)
    end
end

--delete all entities in current frame. By default entities cleared when update started.
--without that defold go will be alive additional frame.
function System:postProcess()
    self.world:refresh()
end

return System