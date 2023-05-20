local COMMON = require "libs.common"
local LEVEL_LINE = require "world.balance.def.level_line"
local ECS = require 'libs.ecs'

---@class DebugDrawRoad:ECSSystem
local System = ECS.system()
System.name = "DebugDrawRoad"

local V1 = vmath.vector3(0)
local V2 = vmath.vector3(0)

local HASH_DRAW_LINE = hash("draw_line")
local CENTER_COLOR = vmath.vector4(0, 1, 0, 1)
local POLYGON_COLOR = vmath.vector4(0, 0, 1, 1)
local VERTICES_COLOR = vmath.vector4(1, 0, 0, 1)

local NORMAL_DY_COLOR = vmath.vector4(1, 0, 0, 1)
local NORMAL_DX_COLOR = vmath.vector4(0, 1, 0.5, 1)
local NORMAL_DZ_COLOR = vmath.vector4(0, 0, 1, 1)

local MSD_DRAW_LINE = {
	start_point = V1,
	end_point = V2,
	color = CENTER_COLOR
}

---@param e EntityGame
function System:update(e, dt)
	for _, tunnel in ipairs(self.world.game_world.game.level_creator.tunnels) do
		MSD_DRAW_LINE.color = POLYGON_COLOR
		for i = 1, #tunnel.points - 1 do
			MSD_DRAW_LINE.start_point = tunnel.points[i]
			MSD_DRAW_LINE.end_point = tunnel.points[i + 1]
			msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
		end

		for i = 0, tunnel.tunnel_segments-2 do
			MSD_DRAW_LINE.start_point.x,MSD_DRAW_LINE.start_point.y,MSD_DRAW_LINE.start_point.z = tunnel.tunnel:GetSegmentCenter(i)
			MSD_DRAW_LINE.end_point.x,MSD_DRAW_LINE.end_point.y,MSD_DRAW_LINE.end_point.z = tunnel.tunnel:GetSegmentCenter(i+1)
			msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
		end
	end

end

return System