local ECS = require 'libs.ecs'

---@class VagonStartSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.requireAll("vagon")
System.name = "VagonStartSystem"

function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	local player_dist = player.tunnel_movement.distance
	for i = 1, #self.entities do
		local e = self.entities[i]
		local delta_dist = e.tunnel_movement.distance - player_dist
		e.moving = delta_dist < e.vagon_start_distance
	end
end


return System