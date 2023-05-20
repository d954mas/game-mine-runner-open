local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local RENDER_3D = require("scene3d.render.render3d")
--local MATH_CEIL = math.ceil
--local MATH_ABS = math.abs
local ENUMS = require "world.enums.enums"
local DEFS = require "world.balance.def.defs"

local TEMP_V = vmath.vector3(0)
--local TEMP_DIFF = vmath.vector3(0)
local TEMP_DIR = vmath.vector3(0)
--local TEMP_Q = vmath.quat_rotation_z(0)

--local P1 = vmath.vector3()
--local P2 = vmath.vector3()

--local NORMAL_1 = vmath.vector3()
--local NORMAL_2 = vmath.vector3()

local FORWARD = vmath.vector3(0, 0, -1)
local CAMERA_DMOVE = vmath.vector3(0, 0, 0)
--local UP = vmath.vector3(0, 1, 0)

local QUAT = vmath.quat_rotation_z(0)
local LOOK_AT_ROTATION = vmath.quat_rotation_z(0)
local NORMAL_ROTATION = vmath.quat_rotation_z(0)

local LOOK_AT = vmath.vector3()
local LOOK_DIFF = vmath.vector3()
local DMOVE = vmath.vector3()

local DELTA_FOV = math.rad(10)
---@class PlayerCameraSystem:ECSSystem
local System = ECS.system()
System.name = "PlayerCameraSystem"
function System:init()
	self.field_of_view = 0
	self.near_clip = 0.5
	self.far_clip = 1000
	self.look_at = vmath.vector3(0, 0, -1)
	self.position = vmath.vector3()
	self.rotation = vmath.quat_rotation_z(0)
	self.camera_delta_rotation = vmath.quat_rotation_x(math.rad(-5))
	self.camera_delta_angle = -math.rad(15)
	self.camera_death = {
		time = 0,
		distance = 0
	}
	self.powerup_speed_distance = 0
	self.base_distance = DEFS.SPEED_LEVELS.BASE[1].distance
	self.base_fov = DEFS.SPEED_LEVELS.BASE[1].fov

	--Если проверять несколько точек, то заметно дергается.
	--поэтому беру точку немного впереди чтобы заранее было видно что там будет.
	self.check_points = {
		{ power = 1, distance = 3, dir = vmath.vector3() },
	}
end

---@param e EntityGame
function System:update(dt)
	local player = self.world.game_world.game.level_creator.player
	local game = self.world.game_world.game
	local tm = player.tunnel_movement

	if (self.world.game_world.game.state.lose) then
		self.camera_death.time = self.camera_death.time + dt
		if (self.camera_death.time > 1) then
			self.camera_death.distance = -1
		elseif (self.camera_death.time > 0.1) then
			self.camera_death.distance = 0.5 + -1.5 * (self.camera_death.time - 0.1) / 0.9
		else
			self.camera_death.distance = 0.5 * self.camera_death.time / 0.1
		end
	else
		self.camera_death.time = 0
		if (self.camera_death.distance < 0) then
			self.camera_death.distance = math.min(self.camera_death.distance + dt * 1, 0)
		end
	end
	local speed_level = self.world.game_world.game.state.speed_level
--[[	if(self.world.game_world.game.state.speed_level_time>0)then
		speed_level = speed_level + 1
	end
	if(self.world.game_world.game.state.lose)then
		speed_level = speed_level - 1
	end--]]
	speed_level = COMMON.LUME.clamp(speed_level,1,#DEFS.SPEED_LEVELS.BASE)
	local speed_level_data = DEFS.SPEED_LEVELS.BASE[speed_level]
	local fov = speed_level_data.fov

	local powerup_duration = game.state.powerups[DEFS.POWERUPS.RUN.id].duration
	local powerup_level = game.world.storage.upgrades:get_level(DEFS.POWERUPS.RUN.id)
	local powerup_max_duration = DEFS.POWERUPS[DEFS.POWERUPS.RUN.id].levels[powerup_level].duration

	if (powerup_duration > 0 and powerup_duration < 0.66) then
		local a = powerup_duration / 0.66
		fov = fov + DELTA_FOV * a
		self.powerup_speed_distance = -0.25 * a
	elseif (powerup_max_duration - powerup_duration < 0.66) then
		local a = (powerup_max_duration - powerup_duration) / 0.66
		fov = fov + DELTA_FOV * a
		self.powerup_speed_distance = -0.25 * a
	elseif(powerup_duration>0)then
		fov = fov +DELTA_FOV
		self.powerup_speed_distance = -0.25
	end


	TEMP_DIR.x, TEMP_DIR.y, TEMP_DIR.z = 0, 0, 0
	local distance = math.max(COMMON.CONSTANTS.START_RUN_CAMERA, tm.distance + self.camera_death.distance + self.powerup_speed_distance)
	for i = 1, #self.check_points do
		local p_data = self.check_points[i]
		local tunnel, segment = game:get_tunnel_by_distance(distance + p_data.distance)
		p_data.dir.x, p_data.dir.y, p_data.dir.z = tunnel.tunnel:GetPlaneDir(segment, tm.plane_idx)
		xmath.mul(p_data.dir, p_data.dir, p_data.power)
		xmath.add(TEMP_DIR, TEMP_DIR, p_data.dir)
	end
	--xmath.normalize(TEMP_DIR, TEMP_DIR)

	local tunnel, segment, plane_dmove = game:get_tunnel_by_distance(distance)

	xmath.quat_from_to(QUAT, FORWARD, TEMP_DIR)
	local look_at_rotation = QUAT
	if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
		look_at_rotation.x, look_at_rotation.y, look_at_rotation.z, look_at_rotation.w = 0, 0, 0, 0
		xmath.quat_rotation_z(look_at_rotation, 0)
	end

	xmath.rotate(LOOK_AT, look_at_rotation, FORWARD)
	--local look_at = vmath.rotate(look_at_rotation,vmath.vector3(0,0,-1))
	local look_at = LOOK_AT

	xmath.sub(LOOK_DIFF, look_at, self.look_at)
	--local diff = look_at-e.player_go.config.look_at
	local diff = LOOK_DIFF
	local diff_len = vmath.length(diff)
	if (diff_len > 0) then
		xmath.normalize(DMOVE, diff)
		--local d_move = vmath.normalize(diff)
		local d_move = DMOVE
		local scale = 0.8 --diff_len>0.1 and 0.8 or 0.6
		if (diff_len < 0.2) then
			scale = 0.4
		elseif (diff_len < 0.05) then
			--avoid small move
			scale = 0
		end
		--d_move = d_move*scale*dt
		if (self.world.game_world.game.state.state == ENUMS.GAME_STATE.MENU) then
			dt = 1 / 60
			scale = 10
		end
		xmath.mul(d_move, d_move, scale * dt)
		if (vmath.length(d_move) > diff_len) then
			d_move = diff
		end
		xmath.add(self.look_at, self.look_at, d_move)
		xmath.quat_from_to(LOOK_AT_ROTATION, FORWARD, self.look_at)
		--look_at_rotation = vmath.quat_from_to(FORWARD, e.player_go.config.look_at)
	end
	--local rotation = look_at_rotation * normal_rotation
	local angle_circle = tm.plane / tunnel.tunnel_angles
	xmath.quat_rotation_z(NORMAL_ROTATION, angle_circle * math.pi * 2 + self.camera_delta_angle)



	--[[	local plane_id = math.floor(tm.plane)
		local plane_id_next = 0
		local plane_x_pos = (tm.plane - plane_id)
		if (plane_x_pos < 0.5) then
			plane_id_next = plane_id - 1
		end
		if (plane_id_next >= tunnel.tunnel_angles) then plane_id_next = 0
		elseif (plane_id_next < 0) then plane_id_next = tunnel.tunnel_angles - 1
		end
		NORMAL_1.x, NORMAL_1.y, NORMAL_1.z = tunnel.tunnel:GetPlaneNormal(segment, plane_id)
		NORMAL_1.z = 0
		xmath.normalize(NORMAL_1, NORMAL_1)
		NORMAL_2.x, NORMAL_2.y, NORMAL_2.z = tunnel.tunnel:GetPlaneNormal(segment, plane_id_next)
		NORMAL_2.z = 0
		xmath.normalize(NORMAL_2, NORMAL_2)
		--local normal_mixed = nil
	--	local plane_normal_lerp = MATH_ABS(plane_x_pos * 2 - 1)
		--local a
	--	if (plane_normal_lerp < 0) then
		--	a = -plane_normal_lerp / 2
	--	else
	--		a = plane_normal_lerp / 2
	--	end
	--	xmath.mul(NORMAL_1, NORMAL_1, 1 - a)
	--	xmath.mul(NORMAL_2, NORMAL_2, a)
		--xmath.add(NORMAL_1,NORMAL_1,NORMAL_2)
		xmath.quat_from_to(NORMAL_ROTATION, UP, NORMAL_1)
		--xmath.add(tm.normal, NORMAL_1, NORMAL_2)
		--xmath.normalize(tm.normal, tm.normal)--]]

	xmath.quat_mul(QUAT, LOOK_AT_ROTATION, NORMAL_ROTATION)
	--xmath.quat_mul(self.rotation, LOOK_AT_ROTATION, NORMAL_ROTATION)
	xmath.quat_mul(self.rotation, QUAT, self.camera_delta_rotation)

	xmath.quat_from_to(QUAT, FORWARD, self.look_at)

	self.position.x, self.position.y, self.position.z = tunnel.tunnel:GetSegmentP1(segment)
	TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetSegmentP2(segment)
	xmath.sub(TEMP_V, TEMP_V, self.position)
	xmath.mul(TEMP_V, TEMP_V, plane_dmove)
	xmath.add(self.position, self.position, TEMP_V)

	--self.position.x, self.position.y, self.position.z = tunnel.tunnel:GetSegmentCenter(segment)

	if(self.base_distance>speed_level_data.distance)then
		self.base_distance = self.base_distance - 0.25 * dt
		if(self.base_distance<=speed_level_data.distance)then
			self.base_distance = speed_level_data.distance
		end
	end
	CAMERA_DMOVE.z = self.base_distance
	xmath.rotate(TEMP_V, QUAT, CAMERA_DMOVE)
	xmath.add(self.position, self.position, TEMP_V)


	if(self.base_fov~=fov)then
		if(self.base_fov>fov)then
			self.base_fov = self.base_fov - math.rad(5)*dt
			if(self.base_fov<fov)then
				self.base_fov=fov
			end
		else
			self.base_fov = self.base_fov + math.rad(5)*dt
			if(self.base_fov>fov)then
				self.base_fov=fov
			end
		end
	end

	if (self.field_of_view ~= self.base_fov) then
		self.field_of_view = self.base_fov
		RENDER_3D.perspective_dirty = true
	end

	RENDER_3D.view_position = self.position
	-- R.view_direction(vmath.rotate(go.get_rotation(), R.FORWARD))
	RENDER_3D.view_from_rotation(self.rotation)
	--RENDER_3D.view_from_rotation(NORMAL_ROTATION)

	RENDER_3D.fov = self.field_of_view
	RENDER_3D.near = self.near_clip
	RENDER_3D.far = self.far_clip
	--RENDER_3D.perspective_dirty = true
end

return System