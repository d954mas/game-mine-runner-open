local COMMON = require "libs.common"
local ECS = require 'libs.ecs'

local P1 = vmath.vector3()
local P2 = vmath.vector3()

local PLANE_P1 = vmath.vector3()
local PLANE_P2 = vmath.vector3()
local PLANE_P3 = vmath.vector3()
local PLANE_P4 = vmath.vector3()

local NORMAL_1 = vmath.vector3()
local NORMAL_2 = vmath.vector3()

local MATH_FLOOR = math.floor
local MATH_ABS = math.abs
---@class PlayerMoveTunnelSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("tunnel_movement")
System.name = "PlayerMoveTunnelSystem"

---@param e EntityGame
function System:process(e, dt)

	local tm = e.tunnel_movement
	local tunnel_size = self.world.game_world.game.level_creator.tunnels[1].tunnel_size
	if (e.moving) then
		tm.distance = tm.distance + tm.speed / tunnel_size * dt
		if (e.player) then
			local add_points = (tm.speed / tunnel_size * dt) * self.world.game_world.game:score_mul_get()
			self.world.game_world.game:points_add(add_points)
		end
	end

	local tunnel, segment_idx, plane_dmove = self.world.game_world.game:get_tunnel_by_distance(tm.distance)
	if (not tunnel) then
		assert(not e.player, "no tunnel for player:" .. tm.distance)
		return --no movement for vagon if it outside of tunnels
	end
	local plane_id = MATH_FLOOR(tm.plane)
	local plane_x_pos = (tm.plane - plane_id)
	tm.tunnel_idx = tunnel.tunnel_idx
	tm.tunnel = tunnel

	local speed_x = tm.speed_x
	if (e.moving and e.movement and e.movement.direction.x ~= 0) then
		tm.plane = tm.plane + e.movement.direction.x * speed_x * dt
		if (tm.plane > tunnel.tunnel_angles) then
			tm.plane = tm.plane - tunnel.tunnel_angles + 0.00001
		end

		if (tm.plane <= 0) then
			tm.plane = (tunnel.tunnel_angles) + tm.plane
		end
	end

	tm.segment_idx = segment_idx
	tm.plane_idx = plane_id
	tm.plane_dmove = plane_dmove

	local plane_id_next = plane_id + 1
	if (plane_x_pos < 0.5) then
		plane_id_next = plane_id - 1
	end
	if (plane_id_next >= tunnel.tunnel_angles) then plane_id_next = 0
	elseif (plane_id_next < 0) then plane_id_next = tunnel.tunnel_angles - 1
	end

	--	local p1 = p1 + (p2 - p1) * plane_x_pos
	--local p2 = p3 + (p4 - p3) * plane_x_pos
	PLANE_P1.x, PLANE_P1.y, PLANE_P1.z = tunnel.tunnel:GetPlaneP1(segment_idx, plane_id)
	PLANE_P2.x, PLANE_P2.y, PLANE_P2.z = tunnel.tunnel:GetPlaneP2(segment_idx, plane_id)
	PLANE_P3.x, PLANE_P3.y, PLANE_P3.z = tunnel.tunnel:GetPlaneP3(segment_idx, plane_id)
	PLANE_P4.x, PLANE_P4.y, PLANE_P4.z = tunnel.tunnel:GetPlaneP4(segment_idx, plane_id)

	xmath.sub(P1, PLANE_P2, PLANE_P1)
	xmath.mul(P1, P1, plane_x_pos)
	xmath.add(P1, PLANE_P1, P1)

	xmath.sub(P2, PLANE_P4, PLANE_P3)
	xmath.mul(P2, P2, plane_x_pos)
	xmath.add(P2, PLANE_P3, P2)

	xmath.sub(tm.position, P2, P1)
	xmath.mul(tm.position, tm.position, tm.plane_dmove)
	xmath.add(tm.position, P1, tm.position)

	--local position = p1 + (p2 - p1) * plane_dmove

	local plane_normal_lerp = MATH_ABS(plane_x_pos * 2 - 1)

	--if(plane.normal.x~=plane.normal.x)then
	--pprint(plane)
	--pprint(tunnel.points)
	--end
	NORMAL_1.x, NORMAL_1.y, NORMAL_1.z = tunnel.tunnel:GetPlaneNormal(segment_idx, plane_id)
	NORMAL_1.z = 0
	xmath.normalize(NORMAL_1, NORMAL_1)
	NORMAL_2.x, NORMAL_2.y, NORMAL_2.z = tunnel.tunnel:GetPlaneNormal(segment_idx, plane_id_next)
	NORMAL_2.z = 0
	xmath.normalize(NORMAL_2, NORMAL_2)
	--local normal_mixed = nil
	local a
	if (plane_normal_lerp < 0) then
		a = -plane_normal_lerp / 2
	else
		a = plane_normal_lerp / 2
	end
	xmath.mul(NORMAL_1, NORMAL_1, 1 - a)
	xmath.mul(NORMAL_2, NORMAL_2, a)
	xmath.add(tm.normal, NORMAL_1, NORMAL_2)
	xmath.normalize(tm.normal, tm.normal)
	--normal_mixed = vmath.normalize(normal_1 * (1 - a) + normal_2 * a)
	--normal_mixed = vmath.normalize(normal_mixed)

	tm.dir.x, tm.dir.y, tm.dir.z = tunnel.tunnel:GetPlaneDir(segment_idx, plane_id)


end

return System