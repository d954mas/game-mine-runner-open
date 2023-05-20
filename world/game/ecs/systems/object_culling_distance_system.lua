local ECS = require 'libs.ecs'

---@class ObjectCullingDistanceSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("distance_culling")
System.name = "DistanceCullingSystem"

---@param e EntityGame
function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	local player_dist = player.tunnel_movement.distance

	for i = 1, #self.entities do
		local e = self.entities[i]
		local tunnel_pos = e.tunnel_movement and e.tunnel_movement.distance or e.tunnel_dist
		local delta_dist = tunnel_pos - player_dist
		e.visible = delta_dist < 50
	end

end

return System