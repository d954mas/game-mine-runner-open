local ECS = require 'libs.ecs'
---@class ActionsUpdateSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("actions")
System.name = "ActionsUpdateSystem"

---@param e EntityGame
function System:process(e, dt)
    local i=1
    local len = #e.actions
    while(i<=len)do
        local action = e.actions[i]
        action:update(dt)
        if(action:is_finished())then
            table.remove(e.actions,i)
            i=i-1
            len = len-1
        end
        i = i + 1
    end

end

return System