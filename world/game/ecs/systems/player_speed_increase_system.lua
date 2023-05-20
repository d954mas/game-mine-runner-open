local ECS = require 'libs.ecs'
local DEFS = require "world.balance.def.defs"
local MATH_MIN = math.min
local MATH_MAX = math.max

---@class PlayerSpeedIncreaseSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("player")
System.name = "PlayerSpeedIncreaseSystem"
function System:init()
end

---@return number max_speed
---@return number acceleration
function System:get_data(level)
	local levels = DEFS.SPEED_LEVELS.BASE
	local data = levels[math.min(level,#levels)]
	return data.speed, data.acceleration
end

function System:get_speed_x(level)
	local levels = DEFS.SPEED_LEVELS.BASE
	local data = levels[math.min(level,#levels)]
	return data.speed_x
end

---@param e EntityGame
function System:process(e, dt)
	local state = self.world.game_world.game.state
	if (state.lose) then return end
	local tm = e.tunnel_movement
	local speed_level = self.world.game_world.game.state.speed_level
	local max_speed, acceleration = self:get_data(speed_level)
	local powerup_duration = self.world.game_world.game.state.powerups[DEFS.POWERUPS.RUN.id].duration
	if (powerup_duration > 0) then
		local scale = 1.5
		local delta_scale = 1
		if (powerup_duration < 0.5) then
			local a = powerup_duration / 0.5
			delta_scale = a
		end
		local add_speed = max_speed*scale-max_speed
		add_speed = math.min(add_speed,5) * delta_scale
		max_speed = max_speed + add_speed
		acceleration = acceleration * scale
	elseif (self.world.game_world.game.state.time - self.world.game_world.game.state.revive_time < 2) then
		if (max_speed > 15) then
			acceleration = acceleration * 3
		else
			acceleration = acceleration * 2
		end

	end

	if(state.speed_level_time>0.97)then
		max_speed = max_speed + 4
		acceleration = acceleration + 6
		tm.speed = max_speed
	end
	if(state.speed_level_time>0)then
		state.speed_level_time = state.speed_level_time-dt
	end

	if (tm.speed > max_speed) then
		tm.speed = MATH_MAX(tm.speed - (acceleration * 1.5) * dt, max_speed)
	else
		tm.speed = MATH_MIN(tm.speed + acceleration * dt, max_speed)
	end
	--pprint(tm.speed)
	--	tm.speed = tm.speed + acceleration * dt
	tm.speed_x = self:get_speed_x(speed_level)
end

return System