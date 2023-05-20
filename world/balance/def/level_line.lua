local LUME = require "libs.lume"
local COMMON = require "libs.common"
--local Curve = require "libs.curve"

local TABLE_INSERT = table.insert


--different lines
--first 2 point must look forward
--end points must look forward
local line_description = {
	vmath.vector3(0, 0, 0),
	vmath.vector3(0, 0, -5),
	--vmath.vector3(-10, -10, -20),

	vmath.vector3(5, -1, -40),
	vmath.vector3(2, -2, -60),
	vmath.vector3(0, 0, -80),
	vmath.vector3(2, 0, -90),
	vmath.vector3(5, -5, -120),
	vmath.vector3(6, 2, -140),
	vmath.vector3(4, 1, -190),
	vmath.vector3(4, 1, -200),
}

local line_description_2 = {
	vmath.vector3(0, 0, 0),
	vmath.vector3(0, 0, -10),
	--vmath.vector3(-10, -10, -20),
	vmath.vector3(-5, -1, -40),
	vmath.vector3(-2, -2, -60),
	vmath.vector3(0, 0, -80),
	vmath.vector3(-2, 0, -90),
	vmath.vector3(-5, -5, -120),
	vmath.vector3(-6, 2, -140),
	vmath.vector3(-6, 2, -140),
	vmath.vector3(-4, 1, -190),
	vmath.vector3(-4, 1, -200),
}

local LINES = {
	line_description,
	--line_description_2
}

local M = {}

M.base_points = {}

for _, line in ipairs(LINES) do
	local result = {}
	for _, point in ipairs(line) do
		--[[if (type(point) == "table") then
			if (point.type == "curve") then
				local curve_result = Curve {
					points = point.points,
					tension = point.tension,
					segments = point.segments,
				}
				for _, p2 in ipairs(curve_result.points_calculated) do
					table.insert(M.result, p2)
				end
			end
		else--]]
			table.insert(result, point)
		--end
	end
	table.insert(M.base_points, result)

end

M.segment_size = 2

--recalculate point to segment_size points
M.points = {}

for _, points in ipairs(M.base_points) do
	local result = { points[1] }
	local point_current = points[1]
	local point_next = points[1]
	local point_next_idx = 1

	while (point_next) do
		local dir = point_next - point_current
		local dir_len = vmath.length(dir)
		if (dir_len == 0) then
			dir = vmath.vector3(0, 0, -1)
			vmath.length(dir)
		end

		while (M.segment_size - dir_len > 0.001) do
			dir = point_next - point_current
			dir_len = vmath.length(dir)
			point_next_idx = point_next_idx + 1
			local point_next_2 = points[point_next_idx]
			if (not point_next_2) then
				if (dir_len == 0) then
					break
				end
				point_next_2 = point_current + vmath.normalize(dir) * M.segment_size
			end
			--skip point
			point_next = point_next_2
			dir = point_next - point_current
			dir_len = vmath.length(dir)
		end

		if (dir_len >= M.segment_size) then
			point_next = point_current + M.segment_size * vmath.normalize(dir)
			dir_len = M.segment_size
		end

		dir = point_next - point_current
		dir_len = vmath.length(dir)
		if (dir_len == 0) then
			break
		end
		if (LUME.equals_float(dir_len, M.segment_size) and dir_len ~= M.segment_size) then
			point_next = point_current + dir
			dir = point_next - point_current
			dir_len = vmath.length(dir)
		end
		assert(LUME.equals_float(dir_len, M.segment_size), "bad size:" .. dir_len)
		table.insert(result, point_next)
		point_current = point_next
		point_next = points[point_next_idx]
	end

	table.insert(M.points, result)
end

local points_per_tunnel = COMMON.CONSTANTS.TUNNEL_POINTS
M.tunnels_points = {}

for idx, points in ipairs(M.points) do
	--remove points if not enought for full tunnel
	local tunnels_points_result = {}
	for i = 1, math.floor(#points / points_per_tunnel) do
		--local start_idx = i==1 and 1 or 0
		local start_idx = i == 1 and 1 or 1
		local start_point = points[(i - 1) * (points_per_tunnel - 1) + (start_idx)]
		local result = { vmath.vector3(0, 0, 0) }
		for j = 1, points_per_tunnel - 1 do
			local p = points[(i - 1) * (points_per_tunnel - 1) + (j + start_idx)]
			if (not p) then
				break
			end
			table.insert(result, p - start_point)
		end
		table.insert(tunnels_points_result, result)
	end
	local last_points = tunnels_points_result[#tunnels_points_result]
	local last = last_points[#last_points - 1]
	local last_2 = last_points[#last_points]
	local dir = last_2 - last
	xmath.normalize(dir, dir)
	if (not COMMON.LUME.equals_float(dir.x, 0,0.01) or not COMMON.LUME.equals_float(dir.y, 0,0.01)
			or not COMMON.LUME.equals_float(dir.z, -1,0.01)) then
		COMMON.w("idx:" .. tostring(idx) .. "bad last dir:" .. tostring(dir))
		local i = math.floor(#points / points_per_tunnel)
		local p = points[(i - 1) * (points_per_tunnel - 1) + (COMMON.CONSTANTS.TUNNEL_POINTS)]
		COMMON.w("point:" .. tostring(p))

	end

	table.insert(M.tunnels_points, tunnels_points_result)
end

M.game_points_list = {}
M.game_points_current = {}
M.game_points_last = vmath.vector3(0)

function M.get_game_points_current()
	local points = table.remove(M.game_points_current, 1)
	if (not points) then
		M.game_points_current = table.remove(M.game_points_list)
		if (not M.game_points_current) then
			M.game_points_list = LUME.shuffle(M.tunnels_points)
			for i = 1, #M.game_points_list do
				M.game_points_list[i] = COMMON.LUME.clone_shallow(M.game_points_list[i])
			end
			M.game_points_current = table.remove(M.game_points_list)
		end
		points = table.remove(M.game_points_current, 1)
	end
	return points
end

function M.get_points(idx, tunnel_points)
	--reset on stars
	if (idx == 1) then
		M.game_points_list = {}
		M.game_points_current = {}
		M.game_points_last = vmath.vector3(0)
	end
	local points = M.get_game_points_current()
	for i, point in ipairs(tunnel_points) do
		xmath.add(point,M.game_points_last, points[i])
	end
	--[[print("*************")
	if(M.tunnels_last_points) then print(M.tunnels_last_points[#M.tunnels_last_points]) end
	print(last_point)
	print(#points)
	print(points[1])
	print(points[2])
	print(points[#points])--]]
	local last = tunnel_points[#tunnel_points]
	M.game_points_last.x, M.game_points_last.y, M.game_points_last.z = last.x, last.y, last.z

	return points
end

--[[
M.segments = {}
local n = 10
local size = 2
local angle = (2 * math.pi / n)
--local r_in = 1 / 2 * size * (1 / math.tan(math.pi / n))
local r_out = size / (2 * math.sin(math.pi / n))
local r = r_out

M.polygon_vertices = {}
M.polygon_angles = {}
for j = 1, n do
	local angle_vert = (j - 1) * angle
	local x = r * math.cos(angle_vert)
	local y = r * math.sin(angle_vert)
	table.insert(M.polygon_vertices, vmath.vector3(x, y, 0))
end
for j = 1, n do
	local v = M.polygon_vertices[j]
	local v2 = M.polygon_vertices[j + 1] or M.polygon_vertices[1]
	table.insert(M.polygon_angles, LUME.angle(v2.x, v2.y, v.x, v.y))
end



point_current = M.points[1]
for i = 2, #M.points do
	point_next = M.points[i]
	local dir = point_next-point_current
	local segment = {
		position = vmath.vector3(point_current),
		dir = vmath.normalize(point_next - point_current),
		planes = {}
	}
	
	table.insert(M.segments,segment)
	point_current = point_next
end


for i = 1, #M.segments - 1 do
	local s1 = M.segments[i]
	local s2 = M.segments[i + 1]
	s1.planes = {}
	for j = 1, #M.polygon_vertices do
		local v1 = s1.position + M.polygon_vertices[j]
		local v2 = s1.position + (M.polygon_vertices[j + 1] or M.polygon_vertices[1])
		local v1n = s2.position + M.polygon_vertices[j]
		local v2n = s2.position + (M.polygon_vertices[j + 1] or M.polygon_vertices[1])


		local plane_1 = v1
		local plane_2 = v2
		local plane_3 = v1n
		local plane_4 = v2n
		local center =  (plane_4 - plane_1) / 2
		--local center_2 = (plane_4-plane_2)/2
		--	print(center)
		--	print(center_2)
		local normal = vmath.normalize(vmath.cross(plane_2 - plane_1, plane_3 - plane_1))
		local normal_dz = vmath.normalize(plane_3-plane_1)
		local normal_dx = vmath.normalize(plane_2-plane_1)
		local normal_dy = normal
		local plane_angle = s1.dir-vmath.vector3(0,0,-1)
		if(vmath.length(plane_angle)==0)then
			plane_angle = vmath.quat_rotation_z(0)
		else
			plane_angle = vmath.quat_rotation_z(0)
		end

		table.insert(s1.planes,{
			p1 = plane_1,
			p2 = plane_2,
			p3 = plane_3,
			p4 = plane_4,
			center = center,
			normal = normal,
			normal_dx = normal_dx,
			normal_dy = normal_dy,
			normal_dz = normal_dz,
			plane_angle = plane_angle
		})

	end
end




pprint(M.points)
pprint(M.segments)
--]]
return M

