local ECS = require 'libs.ecs'
local R = require "scene3d.render.render3d"

---@class DirectionalLightSystem:ECSSystem
local System = ECS.system()
System.name = "DirectionalLightSystem"

---@param e EntityGame
function System:onAddToWorld()

end

return System