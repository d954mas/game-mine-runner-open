local ECS = require 'libs.ecs'

---@class PowerupTickSystem:ECSSystem
local System = ECS.system()
System.name = "PowerupTickSystem"

---@param e EntityGame
function System:update(dt)
	if (self.world.game_world.game.state.lose) then return end
	for powerup_id, powerup in pairs(self.world.game_world.game.state.powerups) do
		local active = powerup.duration >= 0
		powerup.duration = powerup.duration - dt
		local active2 = powerup.duration >= 0

		--powerup finished
		if (active and not active2) then
			self.world.game_world.game:powerup_finish(powerup_id)
		end
	end
end

return System