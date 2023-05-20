local COMMON = require "libs.common"
local LEVEL_LINE = require "world.balance.def.level_line"
local ECS = require 'libs.ecs'

---@class DebugRotateRoadSegments:ECSSystem
local System = ECS.system()
System.name = "DebugRotateRoadSegments"

function System:init()
	self.delta = 0
end

function System:update(dt)
	if (COMMON.INPUT.PRESSED_KEYS[COMMON.HASHES.INPUT.W]) then
		self.delta = self.delta + dt
	end

	if (COMMON.INPUT.PRESSED_KEYS[COMMON.HASHES.INPUT.S]) then
		self.delta = math.max(0,self.delta - dt)
	end

	local sectors = self.world.game_world.game.level_creator.sectors
	for i = 1, #sectors do
		local s1 = sectors[i]
		for j, plane in ipairs(s1.segment_data.planes) do
			local angle = plane.normal
			local rotation

			rotation = s1.planes[j].rotation * vmath.quat_axis_angle(angle+s1.dir,self.delta * math.pi / 12)
		--	go.set_rotation(rotation, s1.planes[j].root)
		end

	end

end

return System