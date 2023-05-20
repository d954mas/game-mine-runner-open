local ECS = require 'libs.ecs'
local DEFS = require "world.balance.def.defs"

local MATH_ABS = math.abs
local HALF_NORMAL = vmath.vector3()
local PLAYER_POSITION = vmath.vector3()


---@class VagonCollideSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.requireAll("vagon")
System.name = "VagonCollideSystem"

function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	local player_dist = player.tunnel_movement.distance
	local state = self.world.game_world.game.state
	local powerup_run = state.powerups[DEFS.POWERUPS.RUN.id].duration > -0.5

	xmath.mul(HALF_NORMAL, player.tunnel_movement.normal, 0.5)
	xmath.add(PLAYER_POSITION, player.tunnel_movement.position, HALF_NORMAL)


	local entities = self.entities
	for i=1,#entities do
		local e = entities[i]
		if (e.visible and not (e.auto_destroy or e.auto_destroy_delay)) then
			local delta_dist = e.tunnel_movement.distance - player_dist
			local plane_dist = MATH_ABS(e.tunnel_movement.plane - player.tunnel_movement.plane)

			if (delta_dist > -0.5) then
				if (delta_dist < 1) then
					if (delta_dist < 0.5 and plane_dist < 0.66 and not state.lose) then
						if (powerup_run) then
							e.moving = false
							e.tunnel_movement.speed = 0
							e.force_v = vmath.vector3(e.tunnel_movement.position)
							e.force_v.y =PLAYER_POSITION.y
							xmath.sub(e.force_v, e.force_v, PLAYER_POSITION)
							xmath.add(e.force_v, e.force_v, e.tunnel_movement.normal * 0.5)
							e.position = vmath.vector3(e.tunnel_movement.position)
							e.auto_destroy_delay_2 = 1
							self.world:addEntity(e)

						else
							self.world.game_world.game:lose()
							e.moving = false
							e.tunnel_movement.speed = 0
							player.tunnel_movement.speed_x = 0
							player.tunnel_movement.speed = 0
						end
					end
				end
			else
				if (delta_dist < -10) then
					e.auto_destroy = true
					self.world:addEntity(e)
				end
			end
		end


	end
end

return System