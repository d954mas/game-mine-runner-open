local ECS = require 'libs.ecs'
local COMMON = require "libs.common"

---@class DrawTunnelSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("tunnel")
System.name = "DrawTunnelSystem"

---@param e EntityGame
function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	local player_dist = player.tunnel_movement.distance
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		local start_pos = (e.tunnel_idx - 1) * e.tunnel_segments
		local delta_dist = start_pos - player_dist
		e.visible = delta_dist < 50

		if (e.tunnel_go.config.visible ~= e.visible) then
		--	print("tunnel:" .. e.tunnel_idx .. " visible:" .. tostring(e.visible))
			e.tunnel_go.config.visible = e.visible
			msg.post(e.tunnel_go.root, e.visible and COMMON.HASHES.MSG.ENABLE or COMMON.HASHES.MSG.DISABLE)
		end
	end


end

return System