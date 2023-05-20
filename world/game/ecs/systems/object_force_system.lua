local ECS = require 'libs.ecs'

local TEMP_V = vmath.vector3()

---@class ObjectForceSystem:ECSSystemProcessing
local System = ECS.processingSystem()
System.filter = ECS.filter("force_v")
System.name = "ObjectForceSystem"

---@param e EntityGame
function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	for i = 1, #self.entities do
		local e = self.entities[i]
		xmath.normalize(TEMP_V, e.force_v)
		local scale = e.vagon and 2 or 3
		xmath.mul(TEMP_V, TEMP_V, player.tunnel_movement.speed * dt * scale)
		xmath.add(e.position, e.position, TEMP_V)
	end

end

return System