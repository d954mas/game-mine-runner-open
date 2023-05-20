local MATH_RANDOM = math.random
local LUME = require "libs.lume"
local POWERUPS_DEF = require "world.balance.def.powerups"

local TABLE_INSERT = table.insert
local TABLE_REMOVE = table.remove

local POWERUPS_LIST = {
	POWERUPS_DEF.RUN, POWERUPS_DEF.MAGNET, POWERUPS_DEF.STAR
}

local M = {}

---@type World
M.world = nil
---@type ENTITIES
M.entities = nil
M.gem_daily_types = {}

M.entities_new = {}

local function randomf()
	return MATH_RANDOM()
end

local function randomi(min, max)
	return MATH_RANDOM(min, max)
end

function M.spawn_gem(tunnel, segment, plane)
	plane = plane or math.random(0, 9)
	plane = M.plane_clamp(plane)
	if (M.gem_daily_can_spawn and randomf() > 0.95) then
		local type = LUME.randomchoice_remove(M.gem_daily_types)
		M.gem_daily_can_spawn = false
		M.gem_daily_last_distance = M.dist_start
		TABLE_INSERT(M.entities_new, M.entities:create_gem_daily(tunnel, segment, plane, type))
	elseif (M.dist_start - M.powerup_last_distance > 200) then
		local powerup_def = POWERUPS_DEF.STAR
		local rnd = randomf()
		if (rnd < 0.33) then
			powerup_def = POWERUPS_DEF.STAR
		elseif (rnd < 0.66) then
			powerup_def = POWERUPS_DEF.MAGNET
		else
			powerup_def = POWERUPS_DEF.RUN
		end
		M.spawn_powerup(tunnel, segment, plane, powerup_def)
	else
		TABLE_INSERT(M.entities_new, M.entities:create_gem(tunnel, segment, plane))
	end

end

function M.spawn_acceleration_arrow(tunnel, segment)
	for i = 0, 0 do
		TABLE_INSERT(M.entities_new, M.entities:create_acceleration_arrow(tunnel, segment, i))
	end

end

function M.spawn_powerup(tunnel, segment, plane, powerup_def)
	powerup_def = powerup_def or LUME.randomchoice(POWERUPS_LIST)
	M.powerup_last_distance = M.dist_start
	TABLE_INSERT(M.entities_new, M.entities:create_powerup(tunnel, segment, plane, powerup_def.id))

end

function M.plane_clamp(plane)
	if (plane > 9) then
		plane = (plane % 9)
	elseif (plane < 0) then
		while (plane < 0) do
			plane = plane + 10
		end
		assert(plane >= 0)
	end
	return plane
end

function M.spawn_box(tunnel, segment, plane)
	plane = plane or math.random(0, 9)
	plane = M.plane_clamp(plane)
	TABLE_INSERT(M.entities_new, M.entities:create_box(tunnel, segment, plane))
end

function M.spawn_column(tunnel, segment, plane)
	plane = M.plane_clamp(plane)
	local column = M.entities:create_column(tunnel, segment, plane)
	if column then
		TABLE_INSERT(M.entities_new, column)
	end

end

function M.gems_segment_line(tunnel, segment, plane_start, count)
	plane_start = M.plane_clamp(plane_start)
	for i = 0, count - 1 do
		local idx = plane_start + i
		if (idx >= 10) then idx = 0 end
		M.spawn_gem(tunnel, segment, idx)
	end
end

function M.gems_plane_line(tunnel, segment, count, plane, step)
	step = step or 1
	plane = M.plane_clamp(plane)
	for i = 0, count - 1, step do
		local idx = segment + i
		M.spawn_gem(tunnel, idx, plane)
	end
end
function M.gems_half_circle(tunnel, segment, plane)
	local idx = M.plane_clamp(plane)
	for i = 1, 5 do
		idx = idx + 1
		if (idx >= 10) then idx = 0 end
		M.spawn_gem(tunnel, segment, idx)
	end
end

function M.box_plane_line(tunnel, segment, count, plane)
	plane = M.plane_clamp(plane)
	for i = 0, count - 1 do
		local idx = segment + i
		M.spawn_box(tunnel, idx, plane)
	end
end

function M.box_half_circle(tunnel, segment, plane)
	local idx = M.plane_clamp(plane)
	M.spawn_column(tunnel, segment, idx)
	for i = 1, 4 do
		idx = idx + 1
		if (idx == 10) then idx = 0 end
		M.spawn_box(tunnel, segment, idx)
	end
end

function M.balance_tutorial(tunnel)
	tunnel.level_name = "balance_tutorial"
	M.spawn_box(tunnel, 11, 0)

	M.gems_plane_line(tunnel, 7, 3, 1)
	M.gems_plane_line(tunnel, 7, 3, 9)

	M.gems_plane_line(tunnel, 10, 3, 2)
	M.gems_plane_line(tunnel, 10, 3, 8)

	M.gems_plane_line(tunnel, 13, 3, 3)
	M.gems_plane_line(tunnel, 13, 3, 7)

	M.gems_plane_line(tunnel, 20, 3, 5)

	M.gems_segment_line(tunnel, 25, 4, 4)

	M.box_half_circle(tunnel, 25, 7)

	for i = 0, 9 do
		M.spawn_powerup(tunnel, 35, i, POWERUPS_DEF.RUN)
		M.spawn_box(tunnel, 40, i)
		M.gems_plane_line(tunnel, 41, 2, i)

		M.gems_plane_line(tunnel, 45, 2, i)
	end

	M.spawn_box(tunnel, 40, 3)
	M.spawn_box(tunnel, 40, 7)
end

function M.balance_start_1(tunnel)
	tunnel.level_name = "balance_start_1"
	M.gems_plane_line(tunnel, 10, 2, randomi(0, 9))
	M.gems_plane_line(tunnel, 16, 2, randomi(0, 9))
	M.gems_plane_line(tunnel, 22, 2, randomi(0, 9))

	--	M.spawn_column(tunnel,17,0)
	--M.spawn_column(tunnel,17,3)

	local v = randomf()
	if (v > 0.66) then
		local idx = randomi(0, 9)
		M.gems_plane_line(tunnel, 30, 2, idx)
		M.gems_plane_line(tunnel, 30, 3, idx + 1)
		M.gems_plane_line(tunnel, 30, 2, idx + 2)
	elseif (v > 0.33) then
		local idx = randomi(0, 9)
		M.gems_plane_line(tunnel, 26, 2, idx)
		M.gems_plane_line(tunnel, 28, 2, idx + 1)
		M.gems_plane_line(tunnel, 30, 2, idx + 2)
	else
		local idx = randomi(0, 9)
		M.gems_plane_line(tunnel, 25, 2, idx)
		M.gems_plane_line(tunnel, 25, 2, idx + 1)

		M.gems_plane_line(tunnel, 30, 2, idx + 2)
		M.gems_plane_line(tunnel, 30, 2, idx + 3)
	end

	M.spawn_box(tunnel, 35, 0)

	v = randomf()
	if (v > 0.7) then
		M.spawn_box(tunnel, 39, randomi(0, 9))
		M.spawn_box(tunnel, 37, randomi(0, 9))
	elseif (v > 0.4) then
		local idx = randomi(0, 9)
		M.spawn_box(tunnel, 38, idx)
		M.spawn_box(tunnel, 38, idx + 5)
	else
		M.spawn_box(tunnel, 38, randomi(0, 9))
	end

	if (randomf() > 0.5) then
		--	M.spawn_box(tunnel, 40, 3)
		--	if (randomf() > 0.4) then M.spawn_box(tunnel, 40, 6) end
		--	M.spawn_box(tunnel, 40, 1)

		M.spawn_gem(tunnel, 40, 5)
		M.spawn_gem(tunnel, 40, 7)

		--	M.spawn_box(tunnel, 44, randomi(1, 4))
		--	if (randomf() > 0.66) then M.spawn_box(tunnel, 44, 5) end
		--	M.spawn_box(tunnel, 44, randomi(5, 9))
	else
		--	M.spawn_box(tunnel, 40, 3)
		--	if (randomf() > 0.4) then M.spawn_box(tunnel, 44, 2) end
		--	M.spawn_box(tunnel, 41, 4)

		M.spawn_gem(tunnel, 42, 5)
		M.spawn_gem(tunnel, 43, 6)

	end
end

function M.balance_start_2(tunnel)
	tunnel.level_name = "balance_start_2"
	local idx = math.random(-2, 2)
	local count = randomi(1, 2)
	local delta = randomf() > 0.5 and 1 or -1
	M.gems_plane_line(tunnel, 10, count, idx)
	M.gems_plane_line(tunnel, 12, count, idx + delta)
	M.gems_plane_line(tunnel, 14, 2, idx + delta * 2)
	M.gems_plane_line(tunnel, 16, count, idx + delta * 3)
	M.gems_plane_line(tunnel, 18, count, idx + delta * 4)

	idx = idx + delta * 6 + math.random(-2, 2)
	count = randomi(1, 2)
	delta = randomf() > 0.5 and 1 or -1
	M.gems_plane_line(tunnel, 24, count, idx)
	M.gems_plane_line(tunnel, 26, count, idx + delta)
	M.gems_plane_line(tunnel, 28, count, idx + delta * 2)
	M.gems_plane_line(tunnel, 30, count, idx + delta * 3)


	--	M.spawn_column(tunnel,17,0)
	--M.spawn_column(tunnel,17,3)


	local v = randomf()
	if (v > 0.7) then
		M.spawn_box(tunnel, 39, randomi(0, 9))
		M.spawn_box(tunnel, 37, randomi(0, 9))
	elseif (v > 0.4) then
		idx = randomi(0, 9)
		M.spawn_box(tunnel, 38, idx)
		M.spawn_box(tunnel, 38, idx + 5)
	else
		M.spawn_box(tunnel, 38, randomi(0, 9))
	end

	if (randomf() > 0.5) then
		--	M.spawn_box(tunnel, 40, 3)
		--	if (randomf() > 0.4) then M.spawn_box(tunnel, 40, 6) end
		--	M.spawn_box(tunnel, 40, 1)

		M.spawn_gem(tunnel, 40, 5)
		M.spawn_gem(tunnel, 40, 7)

		--	M.spawn_box(tunnel, 44, randomi(1, 4))
		--	if (randomf() > 0.66) then M.spawn_box(tunnel, 44, 5) end
		--	M.spawn_box(tunnel, 44, randomi(5, 9))
	else
		--	M.spawn_box(tunnel, 40, 3)
		--	if (randomf() > 0.4) then M.spawn_box(tunnel, 44, 2) end
		--	M.spawn_box(tunnel, 41, 4)

		M.spawn_gem(tunnel, 42, 5)
		M.spawn_gem(tunnel, 43, 6)

	end
end

function M.balance_start(tunnel)
	local rnd = randomf()
	if (rnd > 0.5) then
		M.balance_start_1(tunnel)
	else
		M.balance_start_2(tunnel)
	end

end

function M.balance_0_49(tunnel)
	tunnel.level_name = "balance_0_49"
	local start_idx = randomf() > 0.5 and 0 or 1

	M.gems_plane_line(tunnel, 2, 1, start_idx)
	M.gems_plane_line(tunnel, 2, 1, start_idx + 2)
	M.gems_plane_line(tunnel, 2, 2, start_idx + 4)


	--	M.gems_plane_line(tunnel, 13, 1, start_idx+1)
	--M.gems_plane_line(tunnel, 13, 1, start_idx + 4)
	--M.gems_plane_line(tunnel, 13, 1, start_idx + 9)

	local points = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	M.spawn_box(tunnel, 5, LUME.randomchoice_remove(points))
	M.gems_plane_line(tunnel, 7, 2, LUME.randomchoice_remove(points))
	M.spawn_box(tunnel, 9, LUME.randomchoice_remove(points))
	M.gems_plane_line(tunnel, 11, 2, LUME.randomchoice_remove(points))
	M.spawn_box(tunnel, 13, LUME.randomchoice_remove(points))

	points = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	M.spawn_box(tunnel, 18, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 19, LUME.randomchoice_remove(points))
	M.spawn_box(tunnel, 20, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 20, LUME.randomchoice_remove(points))
	M.spawn_box(tunnel, 21, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 21, LUME.randomchoice_remove(points))
	M.spawn_box(tunnel, 22, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 22, LUME.randomchoice_remove(points))

	if (randomf() > 0.5) then
		M.gems_segment_line(tunnel, 28, 3, 2)
		M.gems_segment_line(tunnel, 28, 6, 2)
		M.gems_segment_line(tunnel, 28, 9, 2)
	else
		M.gems_segment_line(tunnel, 24, 2, 2)
		M.gems_segment_line(tunnel, 24, 3, 2)
		M.gems_segment_line(tunnel, 28, 5, 2)
		M.gems_segment_line(tunnel, 28, 6, 2)
	end

	points = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	M.spawn_box(tunnel, 32, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 33, LUME.randomchoice_remove(points))
	M.spawn_box(tunnel, 34, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 35, LUME.randomchoice_remove(points))
	M.spawn_box(tunnel, 36, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 37, LUME.randomchoice_remove(points))
	M.spawn_gem(tunnel, 38, LUME.randomchoice_remove(points))
	--	M.spawn_box(tunnel, 45, LUME.randomchoice_remove(points))

	if (randomf() > 0.5) then
		M.gems_plane_line(tunnel, 42, 2, 3)
		M.gems_plane_line(tunnel, 46, 2, 4)
	else
		M.gems_plane_line(tunnel, 42, 2, 6)
	end


end

function M.balance_50_99(tunnel)
	tunnel.level_name = "balance_50_99"
	if (randomf() > 0.5) then
		M.spawn_box(tunnel, 1, randomi(0, 9))
		M.spawn_box(tunnel, 3, randomi(0, 9))
		M.spawn_box(tunnel, 7, randomi(0, 9))
	else
		M.spawn_box(tunnel, 5, randomi(2, 6))
		M.spawn_box(tunnel, 7, randomi(2, 6))
		M.spawn_box(tunnel, 1, randomi(2, 6))
	end

	if (randomf() > 0.5) then
		M.spawn_gem(tunnel, 4, 3)
		M.spawn_gem(tunnel, 8, 7)
	else
		M.spawn_gem(tunnel, 6, 2)
		M.spawn_gem(tunnel, 2, 1)
	end

	M.gems_plane_line(tunnel, 10, 3, randomi(0, 9))
	M.gems_plane_line(tunnel, 20, 3, randomi(0, 9), 6)

	if (randomf() > 0.33) then
		M.spawn_box(tunnel, 28, 4)
	elseif (randomf() > 0.33) then
		M.spawn_box(tunnel, 30, 4)
		M.spawn_box(tunnel, 25, 7)
		M.spawn_box(tunnel, 30, 4)
		M.spawn_box(tunnel, 25, 1)
	else
		M.spawn_box(tunnel, 30, 1)
		M.spawn_box(tunnel, 32, 2)
		M.spawn_box(tunnel, 34, 3)
		M.spawn_box(tunnel, 36, 4)
	end

	M.spawn_gem(tunnel, 40, 3)
	if (randomf() > 0.4) then
		M.spawn_box(tunnel, 40, 6)
	end
	M.spawn_gem(tunnel, 40, 1)

	M.spawn_box(tunnel, 40, 5)
	M.spawn_gem(tunnel, 40, 7)

	M.spawn_box(tunnel, 44, 4)
	if (randomf() > 0.66) then
		M.spawn_box(tunnel, 44, 5)
	end
	M.spawn_gem(tunnel, 44, 1)

end

function M.balance_150_199(tunnel)
	tunnel.level_name = "balance_150_199"
	if (randomf() > 0.5) then
		M.spawn_box(tunnel, 5, 7)
		M.spawn_box(tunnel, 5, 9)
		M.gems_plane_line(tunnel, 5, 3, 5)
		M.gems_plane_line(tunnel, 5, 3, 0)
		M.gems_plane_line(tunnel, 10, 3, randomf() > 0.5 and 5 or 0)
	else
		local plane = randomi(0, 9)
		M.spawn_box(tunnel, 12, plane)
		M.spawn_box(tunnel, 6, plane + 2)
		M.spawn_box(tunnel, 2, plane + 1)

		M.gems_plane_line(tunnel, 5, 2, plane - 5)
		M.gems_plane_line(tunnel, 10, 2, plane - 3)
	end

	local idx = math.random(0, 9)
	M.gems_plane_line(tunnel, 15, 2, idx)
	M.gems_plane_line(tunnel, 15, 2, idx + 5)

	idx = math.random(0, 9)
	M.gems_plane_line(tunnel, 19, 2, idx)
	M.gems_plane_line(tunnel, 19, 2, idx + 5)

	if (randomf() > 0.5) then
		M.spawn_box(tunnel, 25, 1)
		M.spawn_box(tunnel, 26, 2)
		M.spawn_box(tunnel, 27, 3)
		M.spawn_box(tunnel, 28, 4)

		M.gems_plane_line(tunnel, 26, 2, 5)
		M.gems_plane_line(tunnel, 26, 2, 6)
		M.gems_plane_line(tunnel, 26, 2, 7)

		--	M.spawn_box(tunnel, 30, 5)

		--	M.spawn_box(tunnel, 30, 8)
		M.spawn_box(tunnel, 32, 7)
		M.spawn_box(tunnel, 34, 6)
		M.spawn_box(tunnel, 36, 5)
	else
		M.spawn_box(tunnel, 25, 1)
		M.spawn_box(tunnel, 26, 3)
		M.spawn_box(tunnel, 27, 5)
		M.spawn_box(tunnel, 28, 7)

		M.gems_plane_line(tunnel, 26, 4, 6)

		--	M.spawn_box(tunnel, 30, 1)

		--	M.spawn_box(tunnel, 30, 1)
		M.spawn_box(tunnel, 32, 2)
		M.spawn_box(tunnel, 34, 4)
		M.spawn_box(tunnel, 36, 5)
	end

	M.spawn_gem(tunnel, 40, 3)
	if (randomf() > 0.4) then
		M.spawn_box(tunnel, 40, 6)
	end
	M.spawn_gem(tunnel, 40, 1)

	M.spawn_box(tunnel, 40, 5)
	M.spawn_gem(tunnel, 40, 7)

	M.spawn_box(tunnel, 44, 4)
	if (randomf() > 0.66) then
		M.spawn_box(tunnel, 44, 5)
	end
	M.spawn_gem(tunnel, 44, 1)

end

function M.balance_hard_200(tunnel)
	tunnel.level_name = "balance_hard_200"
	local plane = randomi(0, 9)
	M.spawn_box(tunnel, 9, plane)
	M.spawn_box(tunnel, 8, plane + 1)
	M.spawn_box(tunnel, 7, plane + 2)
	M.spawn_box(tunnel, 10, plane - 1)

	M.gems_plane_line(tunnel, 13, 2, plane - 2)
	M.gems_plane_line(tunnel, 15, 2, plane - 1)
	M.gems_plane_line(tunnel, 17, 2, plane)
	M.gems_plane_line(tunnel, 17, 5, plane + 1)

	plane = plane + randomi(2, 5)--randomi(0,2)

	M.spawn_box(tunnel, 18, plane)
	M.spawn_box(tunnel, 19, plane + 1)
	M.spawn_box(tunnel, 20, plane + 2)
	M.spawn_box(tunnel, 21, plane + 3)
	--M.spawn_box(tunnel, 22, plane+4)

	--M.gems_plane_line(tunnel,19,4,plane)
	--	M.gems_plane_line(tunnel,20,4,plane+1)

	if (randomf() > 0.0033) then
		local rnd = randomi(0, 9) --rnd = rnd
		M.spawn_box(tunnel, 25, rnd)
		M.spawn_box(tunnel, 26, rnd + 1)
		M.spawn_box(tunnel, 27, rnd + 2)
		M.spawn_box(tunnel, 28, rnd + 3)

		M.gems_plane_line(tunnel, 25, 3, rnd - 1)
		--M.gems_plane_line(tunnel, 26, 3,rnd-2)
		M.gems_plane_line(tunnel, 27, 3, rnd - 3)

		M.spawn_box(tunnel, 31, randomi(0, 9))
		M.spawn_box(tunnel, 32, randomi(0, 9))
		M.spawn_box(tunnel, 35, randomi(0, 9))
		M.spawn_box(tunnel, 36, randomi(0, 9))
	else
		M.spawn_box(tunnel, 25, 1)
		M.spawn_box(tunnel, 26, 3)
		M.spawn_box(tunnel, 27, 5)
		M.spawn_box(tunnel, 28, 7)

		M.spawn_box(tunnel, 30, 1)

		M.spawn_box(tunnel, 30, 1)
		M.spawn_box(tunnel, 32, 2)
		M.spawn_box(tunnel, 34, 4)
		M.spawn_box(tunnel, 36, 5)
	end

	M.spawn_gem(tunnel, 40, 3)
	if (randomf() > 0.4) then
		M.spawn_box(tunnel, 40, 6)
	end
	M.spawn_gem(tunnel, 40, 1)

	M.spawn_box(tunnel, 40, 5)
	M.spawn_gem(tunnel, 40, 7)

	M.spawn_box(tunnel, 44, 4)
	if (randomf() > 0.66) then
		M.spawn_box(tunnel, 44, 5)
	end
	M.spawn_gem(tunnel, 44, 1)

end

function M.balance_hard_300(tunnel)
	tunnel.level_name = "balance_hard_300"
	local idx = randomi(0, 2)
	local idx2 = 3

	M.spawn_column(tunnel, 4, idx)
	M.spawn_column(tunnel, 4, idx2)
	M.gems_plane_line(tunnel, 2, 5, 9)
	M.gems_plane_line(tunnel, 2, 5, 4)

	M.spawn_gem(tunnel, 10, randomi(0, 2))
	M.spawn_gem(tunnel, 10, randomi(3, 4))
	M.spawn_gem(tunnel, 10, randomi(7, 8))
	M.spawn_gem(tunnel, 10, randomi(8, 9))

	M.spawn_box(tunnel, 16, randomi(0, 2))
	M.spawn_box(tunnel, 16, randomi(5, 6))
	M.spawn_box(tunnel, 16, randomi(7, 8))
	M.spawn_box(tunnel, 16, randomi(8, 9))

	M.gems_plane_line(tunnel, 18, 2, randomi(0, 2))
	M.gems_plane_line(tunnel, 19, 2, randomi(3, 4))
	M.gems_plane_line(tunnel, 20, 2, randomi(5, 6))
	M.gems_plane_line(tunnel, 21, 2, randomi(7, 8))

	if (randomf() > 0.33) then
		M.spawn_column(tunnel, 28, randomi(0, 2))
		M.gems_plane_line(tunnel, 28, 5, 3)

		M.spawn_gem(tunnel, 30, 4)
		M.spawn_gem(tunnel, 31, 4)
		M.spawn_gem(tunnel, 32, 4)
		M.spawn_box(tunnel, 30, 5)
		M.spawn_gem(tunnel, 30, 6)
		M.spawn_gem(tunnel, 31, 6)
		M.spawn_gem(tunnel, 32, 6)
		M.spawn_gem(tunnel, 33, 5)

		M.spawn_box(tunnel, 30, 8)
		M.spawn_box(tunnel, 32, 7)
		M.spawn_box(tunnel, 34, 6)
		M.spawn_box(tunnel, 36, 5)
	else
		M.spawn_box(tunnel, 27, 1)
		M.spawn_box(tunnel, 28, 3)
		M.spawn_box(tunnel, 29, 5)
		M.spawn_box(tunnel, 30, 7)

		M.spawn_box(tunnel, 30, 1)

		M.spawn_box(tunnel, 35, 1)
		M.spawn_box(tunnel, 36, 2)
	end

	M.spawn_gem(tunnel, 40, 3)
	if (randomf() > 0.4) then
		M.spawn_box(tunnel, 40, 6)
	end
	M.spawn_gem(tunnel, 40, 1)

	M.spawn_box(tunnel, 40, 5)
	M.spawn_gem(tunnel, 40, 7)

	M.spawn_box(tunnel, 44, 4)
	if (randomf() > 0.66) then
		M.spawn_box(tunnel, 44, 5)
	end
	M.gems_plane_line(tunnel, 44, 5, randomi(0, 3))
	M.gems_plane_line(tunnel, 44, 5, randomi(6, 9))

end

function M.balance_circles(tunnel)
	tunnel.level_name = "balance_hard_300"
	local idx = randomi(0, 2)
	M.box_half_circle(tunnel, 8, idx)
	if (randomf() > 0.5) then
		M.gems_plane_line(tunnel, 2, randomi(6, 10), idx - 1)
	end
	M.gems_plane_line(tunnel, 2, randomi(6, 10), idx - 2)
	local rnd = randomf()
	if (rnd <= 0.25) then
		M.box_half_circle(tunnel, 18, idx + 5)
		M.gems_plane_line(tunnel, 17, 7, idx + 2)

		M.box_half_circle(tunnel, 28, idx + 10)
		M.gems_plane_line(tunnel, 27, 7, idx + 9)

		M.box_half_circle(tunnel, 38, idx + 15)
		M.gems_plane_line(tunnel, 37, 11, idx + 11)
	elseif (rnd <= 0.5) then
		M.box_half_circle(tunnel, 16, idx + 3)
		M.gems_plane_line(tunnel, 15, 2, idx - 1)
		M.gems_plane_line(tunnel, 15, 2, idx)

		M.gems_plane_line(tunnel, 18, 2, idx)
		M.gems_plane_line(tunnel, 18, 2, idx + 1)
		M.gems_plane_line(tunnel, 21, 2, idx + 1)
		M.gems_plane_line(tunnel, 21, 2, idx + 2)
		M.gems_plane_line(tunnel, 23, 2, idx + 2)
		M.gems_plane_line(tunnel, 23, 2, idx + 3)
		M.box_half_circle(tunnel, 24, idx + 6)

		M.gems_plane_line(tunnel, 28, 3, idx + 8)
		M.gems_plane_line(tunnel, 28, 3, idx + 9)
		M.gems_plane_line(tunnel, 32, 4, idx + 8)

		M.box_half_circle(tunnel, 35, idx + 10)

		M.box_half_circle(tunnel, 40, idx + 12)
		M.gems_plane_line(tunnel, 39, 10, idx + 9)
	elseif (rnd <= 0.75) then
		M.gems_plane_line(tunnel, 15, 33, idx + 3, 2)
		M.gems_plane_line(tunnel, 17, 3, idx + 1)
		M.gems_plane_line(tunnel, 17, 3, idx)

		M.gems_plane_line(tunnel, 22, 5, idx + 4)
		M.gems_plane_line(tunnel, 22, 5, idx + 5)

		M.gems_plane_line(tunnel, 32, 5, idx + 2)
		M.gems_plane_line(tunnel, 32, 5, idx + 1)

		M.box_half_circle(tunnel, 18, idx + 4)
		M.box_half_circle(tunnel, 28, idx - 4)
		M.box_half_circle(tunnel, 38, idx + 7)
	else
		M.box_half_circle(tunnel, 15, idx + 4)
		M.gems_plane_line(tunnel, 16, 5, idx + 2)

		M.box_half_circle(tunnel, 24, idx + 6)
		M.gems_plane_line(tunnel, 24, 5, idx + 4)

		--	M.box_half_circle(tunnel, 33, idx + 9)
		M.gems_plane_line(tunnel, 32, 5, idx + 6)

		M.box_half_circle(tunnel, 40, idx + 12)

		M.gems_plane_line(tunnel, 42, 5, idx + 11)
	end


	--	M.gems_plane_line(tunnel, 2, 5, 9)
	--	M.gems_plane_line(tunnel, 2, 5, 4)
end

function M.balance_hard_600(tunnel)
	tunnel.level_name = "balance_hard_600"
	M.spawn_box(tunnel, 4, randomi(0, 2))
	M.spawn_box(tunnel, 4, randomi(3, 4))
	M.spawn_box(tunnel, 4, randomi(5, 6))
	--	M.spawn_box(tunnel, 4, randomi(7, 8))
	M.spawn_box(tunnel, 4, randomi(8, 9))

	M.spawn_gem(tunnel, 10, randomi(1, 2))
	M.spawn_gem(tunnel, 10, randomi(3, 4))
	--	M.spawn_gem(tunnel, 10, randomi(5, 6))
	--	M.spawn_gem(tunnel, 10, randomi(7, 8))
	M.spawn_gem(tunnel, 10, randomi(8, 9))

	--	M.spawn_box(tunnel, 16, randomi(1, 2))
	M.spawn_box(tunnel, 16, randomi(3, 4))
	M.spawn_box(tunnel, 16, randomi(5, 6))
	M.spawn_box(tunnel, 16, randomi(7, 8))
	M.spawn_box(tunnel, 16, randomi(8, 9))

	M.spawn_gem(tunnel, 22, randomi(0, 2))
	M.spawn_gem(tunnel, 22, randomi(3, 4))
	M.spawn_gem(tunnel, 22, randomi(5, 6))
	M.spawn_gem(tunnel, 22, randomi(7, 8))
	M.spawn_gem(tunnel, 22, randomi(8, 9))

	M.spawn_box(tunnel, 26 + randomi(1, 3), randomi(0, 2))
	M.spawn_box(tunnel, 26 + randomi(1, 3), randomi(3, 4))
	--	M.spawn_box(tunnel, 26+randomi(1,3), randomi(5, 6))
	--	M.spawn_box(tunnel, 26+randomi(1,3), randomi(7, 8))
	M.spawn_box(tunnel, 26 + randomi(1, 3), randomi(8, 9))

	M.spawn_box(tunnel, 30 + randomi(1, 3), randomi(0, 2))
	M.spawn_box(tunnel, 30 + randomi(1, 3), randomi(3, 4))
	M.spawn_box(tunnel, 30 + randomi(1, 3), randomi(5, 6))
	M.spawn_box(tunnel, 30 + randomi(1, 3), randomi(7, 8))
	--M.spawn_box(tunnel, 30+randomi(1,3), randomi(8, 9))


	M.spawn_gem(tunnel, 35, randomi(0, 2))
	M.spawn_gem(tunnel, 35, randomi(3, 4))
	M.spawn_gem(tunnel, 35, randomi(5, 6))
	M.spawn_gem(tunnel, 35, randomi(7, 8))
	M.spawn_gem(tunnel, 35, randomi(8, 9))

	if (randomf() > 0.33) then
		M.spawn_box(tunnel, 36, 1)
		--	M.spawn_box(tunnel, 37, 2)
		--	M.spawn_box(tunnel, 38, 3)
		M.spawn_box(tunnel, 40, 4)

		M.spawn_gem(tunnel, 36, 4)
		M.spawn_gem(tunnel, 37, 4)
		M.spawn_gem(tunnel, 38, 4)
		M.spawn_box(tunnel, 40, 5)
		M.spawn_gem(tunnel, 36, 6)
		M.spawn_gem(tunnel, 37, 6)
		M.spawn_gem(tunnel, 38, 6)
		M.spawn_gem(tunnel, 39, 5)

		M.spawn_box(tunnel, 40, 8)
		M.spawn_box(tunnel, 38, 7)
		M.spawn_box(tunnel, 37, 6)
		M.spawn_box(tunnel, 36, 5)
	else
		M.spawn_box(tunnel, 35, 1)
		--	M.spawn_box(tunnel, 36, 3)
		--	M.spawn_box(tunnel, 37, 5)
		M.spawn_box(tunnel, 38, 7)

		M.spawn_box(tunnel, 40, 1)

		M.spawn_box(tunnel, 40, 1)
		M.spawn_box(tunnel, 42, 2)
		M.spawn_box(tunnel, 44, 4)
		--	M.spawn_box(tunnel, 46, 5)
	end

end

function M.balance_columns_1(tunnel)
	tunnel.level_name = "balance_columns_1"
	local plane = randomi(0, 9)
	M.spawn_column(tunnel, 8, plane)
	M.gems_plane_line(tunnel, 1, 5, plane - 1)
	M.gems_plane_line(tunnel, 8, 5, plane + 1)

	M.spawn_column(tunnel, 16, plane + 3)
	M.gems_plane_line(tunnel, 18, 5, plane + 2)
	--M.gems_plane_line(tunnel, 18, 5,plane+4)


	--M.spawn_box(tunnel, 9, plane)
	--M.spawn_box(tunnel, 8, plane+1)
	--M.spawn_box(tunnel, 7, plane+2)
	--M.spawn_box(tunnel, 10, plane-1)


	--M.gems_plane_line(tunnel, 13, 2,plane-2)
	--M.gems_plane_line(tunnel, 15, 2,plane-1)
	--	M.gems_plane_line(tunnel, 17, 2,plane)
	--	M.gems_plane_line(tunnel, 17, 5,plane+1)

	plane = plane + (randomf() > 0.5 and 2 or -2)--randomi(0,2)

	M.spawn_box(tunnel, 22, plane + 1)
	M.spawn_box(tunnel, 23, plane + 2)

	M.spawn_box(tunnel, 24, plane + 8)

	if (randomf() > 0.0033) then
		local rnd = randomi(0, 9) --rnd = rnd


		M.gems_plane_line(tunnel, 25, 3, rnd - 1)
		--M.gems_plane_line(tunnel, 26, 3,rnd-2)
		M.gems_plane_line(tunnel, 27, 3, rnd - 3)

		local points = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
		M.spawn_box(tunnel, 31, LUME.randomchoice_remove(points))
		M.spawn_box(tunnel, 32, LUME.randomchoice_remove(points))
		M.spawn_box(tunnel, 35, LUME.randomchoice_remove(points))
		M.spawn_box(tunnel, 36, LUME.randomchoice_remove(points))

		M.spawn_gem(tunnel, 33, LUME.randomchoice_remove(points))
		M.spawn_gem(tunnel, 37, LUME.randomchoice_remove(points))
		M.spawn_gem(tunnel, 35, LUME.randomchoice_remove(points))
		M.spawn_gem(tunnel, 34, LUME.randomchoice_remove(points))
		M.spawn_gem(tunnel, 32, LUME.randomchoice_remove(points))

	else
		M.gems_plane_line(tunnel, 30, 3, 3)
		M.gems_plane_line(tunnel, 32, 6, 3)
		M.gems_plane_line(tunnel, 38, 3, 3)

		M.spawn_box(tunnel, 30, 1)

		M.spawn_box(tunnel, 30, 1)
		M.spawn_box(tunnel, 32, 2)
		M.spawn_box(tunnel, 34, 4)
		M.spawn_box(tunnel, 36, 5)
	end

	local idx = randomi(0, 9)
	M.spawn_column(tunnel, 40, idx)
	M.spawn_column(tunnel, 40, idx + randomi(1, 4))

	M.gems_plane_line(tunnel, 38, 5, idx + 1)
	M.gems_plane_line(tunnel, 44, 5, idx + 3)

end

---@param world World
---@param tunnel EntityGame
function M.balance_for_tunnel(world, tunnel)
	M.world = assert(world)
	M.entities = M.world.game.ecs_game.entities
	local segments_len = tunnel.tunnel_segments
	local idx = tunnel.tunnel_idx
	local dist_start = (tunnel.tunnel_idx - 1) * (segments_len + 1)
	if (dist_start == 0) then
		M.gem_daily_last_distance = 0
		M.powerup_last_distance = 0
		M.start_tutorial = false
	end
	if (M.start_tutorial) then
		dist_start = dist_start - 50
	end
	M.dist_start = dist_start

	M.gem_daily_can_spawn = world.storage.game:gems_daily_can_collect() and not world.game.state.gem_daily_take
			and M.dist_start > 200
			and (M.dist_start - M.gem_daily_last_distance) > 150
	if (M.gem_daily_can_spawn) then
		LUME.cleari(M.gem_daily_types)
		for i = 1, 3 do
			if (not world.storage.game:gems_daily_is_have(i)) then
				TABLE_INSERT(M.gem_daily_types, i)
			end
		end
		M.gem_daily_can_spawn = #M.gem_daily_types > 0
	end
	--print("can spawn daily gem:" .. tostring(M.gem_daily_can_spawn))

	if (idx == 2) then
		M.spawn_acceleration_arrow(tunnel, 0)
	elseif (idx == 5) then
		M.spawn_acceleration_arrow(tunnel, 0)
	elseif (idx == 9) then
		M.spawn_acceleration_arrow(tunnel, 0)
	elseif (idx == 14) then
		M.spawn_acceleration_arrow(tunnel, 0)
	elseif (idx == 20) then
		M.spawn_acceleration_arrow(tunnel, 0)
	end
	if (dist_start == 0) then
		if (M.world.storage.game:is_tutorial_completed()) then
			M.balance_start(tunnel)
			M.start_tutorial = false
			--M.balance_circles(tunnel)
			--M.balance_columns_1(tunnel)
			--M.box_half_circle(tunnel,30,3)
			--	M.balance_hard_300(tunnel)
			--M.spawn_powerup(tunnel,10,0,POWERUPS_DEF.RUN)
			--M.spawn_acceleration_arrow(tunnel,5)
			--	M.spawn_acceleration_arrow(tunnel,6)
			--	M.spawn_acceleration_arrow(tunnel,10)
			--M.spawn_acceleration_arrow(tunnel,11)
			--	M.spawn_acceleration_arrow(tunnel,12)
			--	M.spawn_acceleration_arrow(tunnel,15)
			--M.spawn_acceleration_arrow(tunnel,18)
			--M.balance_150_199(tunnel)
		else
			if (M.start_tutorial) then
				M.balance_start(tunnel)
			else
				M.start_tutorial = true
				M.balance_tutorial(tunnel)
			end
		end
	elseif (dist_start == 50) then
		local rnd = randomf()
		if (rnd < 0.9) then
			M.balance_0_49(tunnel)
		else
			M.balance_50_99(tunnel)
		end
	elseif (dist_start == 100) then
		M.balance_150_199(tunnel)
	elseif (dist_start == 150) then
		M.balance_150_199(tunnel)
	elseif (dist_start == 200) then
		M.balance_hard_200(tunnel)
	elseif (dist_start == 250) then
		local rnd = randomf()
		if (rnd < 0.1) then
			M.balance_0_49(tunnel)
		elseif (rnd < 0.5) then
			M.balance_150_199(tunnel)
		else
			M.balance_50_99(tunnel)
		end
	elseif (dist_start == 300) then
		M.balance_hard_200(tunnel)
	elseif (dist_start == 350) then
		M.balance_columns_1(tunnel)
	elseif (dist_start == 400) then
		local rnd = randomf()
		rnd = 1
		if (rnd < 0.1) then
			M.balance_0_49(tunnel)
		elseif (rnd < 0.5) then
			M.balance_150_199(tunnel)
		else
			M.balance_circles(tunnel)
		end
	elseif (dist_start == 450) then
		local rnd = randomf()
		if (rnd < 0.33) then
			M.balance_hard_200(tunnel)
		elseif (rnd < 0.66) then
			M.balance_hard_300(tunnel)
		else
			M.balance_columns_1(tunnel)
		end
	elseif (dist_start == 500) then
		M.balance_circles(tunnel)
	elseif (dist_start <= 550) then
		local rnd = randomf()
		if (rnd < 0.4) then
			rnd = randomf()
			if (rnd < 0.1) then
				M.balance_0_49(tunnel)
			elseif (rnd < 0.5) then
				M.balance_150_199(tunnel)
			else
				M.balance_50_99(tunnel)
			end
		else
			rnd = randomf()
			if (rnd < 0.33) then
				M.balance_hard_200(tunnel)
			else
				M.balance_hard_300(tunnel)
			end
		end
	elseif (dist_start <= 600) then
		M.balance_hard_600(tunnel)
	elseif (dist_start > 999 and dist_start % 1000 == 0) then
		local rnd = randomf()
		if (rnd < 0.5) then
			M.balance_circles(tunnel)
		else
			M.balance_columns_1(tunnel)
		end
	else
		local rnd = randomf()
		if (rnd < 0.33) then
			rnd = randomf()
			if (rnd < 0.1) then
				M.balance_0_49(tunnel)
			elseif (rnd < 0.4) then
				M.balance_150_199(tunnel)
			elseif (rnd < 0.7) then
				if (dist_start < 850) then
					M.balance_circles(tunnel)
				else
					M.balance_150_199(tunnel)
				end
			else
				M.balance_50_99(tunnel)
			end
		else
			rnd = randomf()
			if (rnd < 0.6) then
				M.balance_hard_600(tunnel)
			else
				rnd = randomf()
				if (rnd < 0.5) then
					M.balance_hard_300(tunnel)
				else
					M.balance_hard_300(tunnel)
				end
			end
		end
	end
	for i = #M.entities_new, 1, -1 do
		local e = TABLE_REMOVE(M.entities_new)
		M.world.game.ecs_game:add_entity(e)
	end
end

return M

