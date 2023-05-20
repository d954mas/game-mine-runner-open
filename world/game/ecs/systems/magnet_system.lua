local ECS = require 'libs.ecs'

local TEMP_V = vmath.vector3()
local HALF_NORMAL = vmath.vector3()
local PLAYER_POSITION = vmath.vector3()

---@class MagnetSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("magnet")
System.name = "MagnetSystem"

---@param e EntityGame
function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	xmath.mul(HALF_NORMAL, player.tunnel_movement.normal, 0.9)
	xmath.add(PLAYER_POSITION, player.tunnel_movement.position, HALF_NORMAL)

	for i = 1, #self.entities do
		local e = self.entities[i]
		e.magnet_speed = e.magnet_speed + 2*dt
		xmath.sub(TEMP_V, PLAYER_POSITION, e.position)
		local dist = vmath.length_sqr(TEMP_V)
		if(dist ~= 0)then
			xmath.normalize(TEMP_V, TEMP_V)
			local speed = player.tunnel_movement.speed
			if speed == 0 then speed = 5 end
			xmath.mul(TEMP_V, TEMP_V, speed * dt * e.magnet_speed)
			if(vmath.length_sqr(TEMP_V)>dist)then
				xmath.sub(TEMP_V, PLAYER_POSITION, e.position)
			end

			xmath.add(e.position, e.position, TEMP_V)
		end

	end

end

return System