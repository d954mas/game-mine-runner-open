local COMMON = require "libs.common"
local ECS = require 'libs.ecs'
local ENUMS = require 'world.enums.enums'
local DEFS = require "world.balance.def.defs"

local FORWARD = vmath.vector3(0, 0, -1)
local UP = vmath.vector3(0, 1, 0)

local QUAT = vmath.quat_rotation_z(0)
local LOOK_AT_ROTATION = vmath.quat_rotation_z(0)
local NORMAL_ROTATION = vmath.quat_rotation_z(0)

local LOOK_AT = vmath.vector3()
local LOOK_DIFF = vmath.vector3()
local DMOVE = vmath.vector3()

local V_EMPTY = vmath.vector3(0)

local ANGLE_MOVE_LEFT_RIGHT = math.rad(25)

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
}

---@class DrawPlayerSystem:ECSSystem
local System = ECS.processingSystem()
System.filter = ECS.requireAll("player")
System.name = "PlayerMoveSystem"

---@param e EntityGame
function System:get_animation(e)
	local state = self.world.game_world.game.state
	if (state.lose) then
		return ENUMS.ANIMATION.DIE
	end
	if (state.start_timer > 0) then
		if (state.revive) then
			return ENUMS.ANIMATION.REVIVE
		end
		return ENUMS.ANIMATION.PAUSE
	end
	if (self.world.game_world.game.state.state == ENUMS.GAME_STATE.MENU) then
		return ENUMS.ANIMATION.MENU
	end
	return ENUMS.ANIMATION.RUN
end

---@param e EntityGame
function System:process(e, dt)
	if (self.bad_normal) then return true end
	local anim = self:get_animation(e)
	e.skin = self.world.game_world.storage.game:skin_get()
	if (e.skin ~= e.player_go.config.skin) then
		e.player_go.config.skin = e.skin
		e.player_go.config.animation = nil
		local def = assert(DEFS.SKINS.SKINS_BY_ID[e.skin])
		if (e.player_go.model.root) then
			go.delete(e.player_go.model.root, true)
		end

		local collection = collectionfactory.create(def.factory, V_EMPTY, nil, nil, 1)
		e.player_go.model.root = msg.url(assert(collection[PARTS.ROOT]))
		e.player_go.model.model = COMMON.LUME.url_component_from_url(e.player_go.model.root, "model")

		go.set_parent(e.player_go.model.root, e.player_go.root, false)
	end

	if (e.player_go.config.animation ~= anim) then
		e.player_go.config.animation = anim
		if (anim == ENUMS.ANIMATION.PAUSE) then
			model.cancel(e.player_go.model.model)
		elseif (anim == ENUMS.ANIMATION.MENU) then
			model.play_anim(e.player_go.model.model, "run", go.PLAYBACK_ONCE_FORWARD,
					{ blend_duration = 0, offset = 1 })
		elseif (anim == ENUMS.ANIMATION.RUN) then
			model.play_anim(e.player_go.model.model, "run", go.PLAYBACK_LOOP_FORWARD,
					{ blend_duration = 0.1 })
		elseif (anim == ENUMS.ANIMATION.DIE) then
			model.play_anim(e.player_go.model.model, "die", go.PLAYBACK_ONCE_FORWARD,
					{ blend_duration = 0.1 })
		elseif (anim == ENUMS.ANIMATION.REVIVE) then
			model.play_anim(e.player_go.model.model, "run", go.PLAYBACK_LOOP_FORWARD,
					{ blend_duration = 2.5 }, function()
					end)
		end
	end
	go.set_position(e.tunnel_movement.position, e.player_go.root)
	--local dir = vmath.vector3(e.tunnel_movement.dir.x,e.tunnel_movement.dir.y,e.tunnel_movement.dir.z)
	--	dir = vmath.cross(dir,e.tunnel_movement.normal)
	xmath.quat_from_to(QUAT, FORWARD, e.tunnel_movement.dir)
	--	local look_at_rotation = vmath.quat_from_to(vmath.vector3(0,0,-1),dir)
	local look_at_rotation = QUAT
	if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
		--	look_at_rotation = vmath.quat_rotation_z(0)
		xmath.quat_rotation_z(look_at_rotation, 0)
	end

	xmath.rotate(LOOK_AT, look_at_rotation, FORWARD)
	--local look_at = vmath.rotate(look_at_rotation,vmath.vector3(0,0,-1))
	local look_at = LOOK_AT

	xmath.sub(LOOK_DIFF, look_at, e.player_go.config.look_at)
	--local diff = look_at-e.player_go.config.look_at
	local diff = LOOK_DIFF
	local diff_len = vmath.length(diff)
	if (diff_len > 0) then
		xmath.normalize(DMOVE, diff)
		--local d_move = vmath.normalize(diff)
		local d_move = DMOVE
		local scale = 1 --diff_len>0.1 and 0.8 or 0.6
		if (diff_len < 0.1) then
			scale = 0.8
		elseif (diff_len < 0.05) then
			scale = 0.4
		end
		--d_move = d_move*scale*dt
		xmath.mul(d_move, d_move, scale * dt)
		if (vmath.length(d_move) > diff_len) then
			d_move = diff
		end
		xmath.add(e.player_go.config.look_at, e.player_go.config.look_at, d_move)
		xmath.quat_from_to(LOOK_AT_ROTATION, FORWARD, e.player_go.config.look_at)
		--look_at_rotation = vmath.quat_from_to(FORWARD, e.player_go.config.look_at)
	end

	xmath.quat_from_to(NORMAL_ROTATION, UP, e.tunnel_movement.normal)
	--local normal_rotation = vmath.quat_from_to(UP, e.tunnel_movement.normal)
	if (NORMAL_ROTATION.x ~= NORMAL_ROTATION.x or NORMAL_ROTATION.y ~= NORMAL_ROTATION.y or NORMAL_ROTATION.z ~= NORMAL_ROTATION.z) then
		NORMAL_ROTATION.x, NORMAL_ROTATION.y, NORMAL_ROTATION.z, NORMAL_ROTATION.w = 0, 0, 0, 0
		xmath.quat_rotation_z(NORMAL_ROTATION, math.pi)
	end
	xmath.quat_mul(QUAT, LOOK_AT_ROTATION, NORMAL_ROTATION)
	--local rotation = look_at_rotation * normal_rotation

	go.set_rotation(QUAT, e.player_go.root)

	if (not self.world.game_world.game.state.lose) then
		local dir = -e.movement.direction.x
		if (dir == 0) then
			dir = e.player_go.config.left_right_angle > 0 and -1 or 1
		elseif (COMMON.LUME.sign(dir) ~= COMMON.LUME.sign(e.player_go.config.left_right_angle)) then
			dir = dir * 4
		end
		e.player_go.config.left_right_angle = e.player_go.config.left_right_angle + dir * 1 * dt
		e.player_go.config.left_right_angle = COMMON.LUME.clamp(e.player_go.config.left_right_angle,
				-ANGLE_MOVE_LEFT_RIGHT, ANGLE_MOVE_LEFT_RIGHT)
	end

	if (e.player_go.model.root) then
		xmath.quat_rotation_y(QUAT, e.player_go.config.left_right_angle)
		go.set_rotation(QUAT, e.player_go.model.root)
	end

end

return System