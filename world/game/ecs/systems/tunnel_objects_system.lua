local ECS = require 'libs.ecs'
local DEFS = require "world.balance.def.defs"

local MATH_ABS = math.abs
local DIST_V = vmath.vector3()
local TABLE_REMOVE = table.remove

local HALF_NORMAL = vmath.vector3()
local PLAYER_POSITION = vmath.vector3()

---@class TunnelObjectsSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.requireAll("tunnel")
System.name = "TunnelObjectsSystem"

function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	xmath.mul(HALF_NORMAL, player.tunnel_movement.normal, 0.5)
	xmath.add(PLAYER_POSITION, player.tunnel_movement.position, HALF_NORMAL)

	local player_dist = player.tunnel_movement.distance
	local state = self.world.game_world.game.state
	local entities = self.entities
	local magnet = state.powerups[DEFS.POWERUPS.MAGNET.id].duration > 0
	local powerup_run = state.powerups[DEFS.POWERUPS.RUN.id].duration > -0.5
	powerup_run = powerup_run or state.speed_level_time>0
	for idx_e = 1, #entities do
		local e = entities[idx_e]
		if (e.visible) then
			for i = #e.game_objects, 1, -1 do
				local object = e.game_objects[i]
				local delta_dist = object.tunnel_dist - player_dist
				local plane_dist = MATH_ABS(object.tunnel_position.plane + 0.5 - player.tunnel_movement.plane)
				local plane_dist_2
				if (object.tunnel_position.plane_2) then
					plane_dist_2 = MATH_ABS(object.tunnel_position.plane_2 + 0.5 - player.tunnel_movement.plane)
				end
				local dist_len
				if ((object.magnet or delta_dist > -0.5) and not (object.auto_destroy_delay or object.auto_destroy or object.auto_destroy_delay_2)) then
					if (magnet and object.gem and not object.magnet and delta_dist < 6) then
						xmath.sub(DIST_V, object.position, PLAYER_POSITION)
						dist_len = vmath.length(DIST_V)
						if (dist_len < 6) then
							object.magnet = true
							object.magnet_speed = 1.15
							self.world:addEntity(object)
						end
					end

					if (delta_dist < 1) then
						if not dist_len then
							xmath.sub(DIST_V, object.position, PLAYER_POSITION)
							dist_len = vmath.length(DIST_V)
						end
						if (object.gem and dist_len < (object.magnet and 1 or 1.25)) then
							if (object.gem_daily) then
								TABLE_REMOVE(e.game_objects, i)
								object.auto_destroy_delay = 0.3
								object.magnet = true
								object.magnet_speed = 1.25
								self.world:addEntity(object)
								self.world.game_world.game:gem_daily_take(object)
							else
								TABLE_REMOVE(e.game_objects, i)
								object.auto_destroy_delay = 0.3
								object.magnet = true
								object.magnet_speed = 1.25
								self.world:addEntity(object)
								self.world.game_world.game:gem_take(object)
							end
						elseif (object.box and delta_dist < (object.delta_dist or 0.5) and plane_dist < 0.66 and not state.lose) then
							if (powerup_run) then
								object.auto_destroy_delay_2 = 1
								object.force_v = vmath.vector3(DIST_V)
								self.world:addEntity(object)
								self.world.game_world.sounds:player_destroy_object()
							else
								self.world.game_world.game:lose()
								player.tunnel_movement.speed_x = 0
								player.tunnel_movement.speed = 0
							end
						elseif (object.column and delta_dist < 0.5 and (plane_dist < 0.75 or plane_dist_2 < 0.75) and not state.lose) then
							if (powerup_run) then
								object.auto_destroy_delay_2 = 1
								object.force_v = vmath.vector3(DIST_V)
								self.world:addEntity(object)
								self.world.game_world.sounds:player_destroy_object()
							else
								self.world.game_world.game:lose()
								player.tunnel_movement.speed_x = 0
								player.tunnel_movement.speed = 0
							end

						elseif (object.powerup and dist_len < 1.25) then
							TABLE_REMOVE(e.game_objects, i)
							object.auto_destroy = true
							self.world:addEntity(object)
							self.world.game_world.game:powerup_take(object.powerup_id)
						elseif(object.acceleration_arrow)then
							TABLE_REMOVE(e.game_objects, i)
							object.auto_destroy_delay = 1
							self.world:addEntity(object)
							self.world.game_world.game:acceleration_arrow_take(object)
						end
					end
				else
					local max = -4
					if(object.column)then
						max = -0.5
					end
					if (delta_dist < max and not object.magnet) then
						TABLE_REMOVE(e.game_objects, i)
						object.auto_destroy = true
						self.world:addEntity(object)
					end
				end
			end
		end
	end
end

return System