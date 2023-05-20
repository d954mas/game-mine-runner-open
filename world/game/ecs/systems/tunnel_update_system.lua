local ECS = require 'libs.ecs'
local LEVEL_LINE = require "world.balance.def.level_line"
local LEVEL_BALANCE = require "world.balance.def.level_balance"

local TABLE_REMOVE = table.remove

---@class TunnelUpdateSystem:ECSSystem
local System = ECS.system()
System.filter = ECS.requireAll("tunnel")
System.name = "TunnelUpdateSystem"

function System:update(dt)
	local entities = self.entities
	local tm = self.world.game_world.game.level_creator.player.tunnel_movement
	for idx_e = 1, #entities do
		local e = entities[idx_e]

		local tunnel, segmets = self.world.game_world.game:get_tunnel_by_distance(tm.distance)
		local tunnel_need_update =  tunnel.tunnel_idx > e.tunnel_idx + 1 or (tm.tunnel_idx > e.tunnel_idx and
				segmets > 4)
		if (tunnel_need_update) then
			for _ = #e.game_objects, 1, -1 do
				self.world:removeEntity(TABLE_REMOVE(e.game_objects))
			end

			local lc = self.world.game_world.game.level_creator
			lc.tunnel_idx = lc.tunnel_idx + 1
			e.tunnel_go.config.content_version = -1
			e.tunnel_idx = lc.tunnel_idx
			LEVEL_LINE.get_points(lc.tunnel_idx, e.points)
			e.tunnel:SetPoints(e.points)
			self.world.game_world.game.ecs_game.entities:tunnel_init(e)

			LEVEL_BALANCE.balance_for_tunnel(self.world.game_world, e)
		end
	end
end

return System