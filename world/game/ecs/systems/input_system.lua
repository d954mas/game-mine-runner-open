local ECS = require 'libs.ecs'
local COMMON = require "libs.common"

---@class InputSystem:ECSSystem
local System = ECS.system()
System.name = "InputSystem"

function System:init()
	self.movement = vmath.vector4(0) --up/down/left/right
end

function System:check_movement_input()
	local hashes = COMMON.HASHES.INPUT
	local PRESSED = COMMON.INPUT.PRESSED_KEYS
	self.movement.w = (PRESSED[hashes.ARROW_LEFT] or PRESSED[hashes.A]) and 1 or 0
	self.movement.z = (PRESSED[hashes.ARROW_RIGHT] or PRESSED[hashes.D]) and 1 or 0

	if (COMMON.INPUT.TOUCH[1]) then
		local dx = COMMON.INPUT.TOUCH[1].x / 960
		self.movement.w = dx <= 0.5 and 1 or 0
		self.movement.z = dx > 0.5 and 1 or 0
	end
	local multi = COMMON.INPUT.TOUCH_MULTI[#COMMON.INPUT.TOUCH_MULTI]
	if (multi) then
		local dx = multi.x / 960
		self.movement.w = dx <= 0.5 and 1 or 0
		self.movement.z = dx > 0.5 and 1 or 0
	end
end


function System:update()
	self:check_movement_input()
	local player = self.world.game_world.game.level_creator.player
	--	player.input_direction.x = self.movement.z - self.movement.w
	--player.input_direction.y = self.movement.x - self.movement.y
	player.movement.direction.x = self.movement.z - self.movement.w
	player.movement.direction.y = self.movement.x - self.movement.y
	if(player.tunnel_movement.distance<=COMMON.CONSTANTS.START_RUN_CAMERA)then
		player.movement.direction.x=0
		player.movement.direction.y=0
	end
end

return System