local ECS = require 'libs.ecs'
local COMMON = require "libs.common"

local FORWARD = vmath.vector3(0, 0, -1)
local UP = vmath.vector3(0, 1, 0)

local QUAT = vmath.quat_rotation_z(0)
local LOOK_AT_ROTATION = vmath.quat_rotation_z(0)
local NORMAL_ROTATION = vmath.quat_rotation_z(0)

local LOOK_AT = vmath.vector3()
local LOOK_DIFF = vmath.vector3()
local DMOVE = vmath.vector3()

local FACTORY = msg.url("game_scene:/factory#vagon")

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	MODEL = COMMON.HASHES.hash("/model"),
}

---@class DrawVagonSystem:ECSSystemProcessing
local System = ECS.processingSystem()
System.filter = ECS.filter("vagon")
System.name = "DrawVagonSystem"

function System:init()

end

function System:preProcess(dt)

end

---@param e EntityGame
function System:process(e, dt)
	if (not e.visible and e.vagon_go) then
		go.delete(assert(e.vagon_go.root), true)
		e.vagon_go = nil
	elseif (e.visible and not e.vagon_go) then
		local collection = collectionfactory.create(FACTORY, e.tunnel_movement.position, nil, nil, 1.5)
		---@class VagonGo
		local vagon_go = {
			root = msg.url(assert(collection[PARTS.ROOT])),
			model = {
				root = msg.url(assert(collection[PARTS.MODEL])),
				model = nil
			},
			config = {
				look_at = vmath.vector3(0, 0, -1)
			}
		}
		vagon_go.model.model = COMMON.LUME.url_component_from_url(vagon_go.model.root, COMMON.HASHES.MESH)
		e.vagon_go = vagon_go
	end

	if (e.vagon_go) then
		go.set_position(e.position or e.tunnel_movement.position, e.vagon_go.root)

		xmath.quat_from_to(QUAT, FORWARD, e.tunnel_movement.dir)
		local look_at_rotation = QUAT
		if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
			xmath.quat_rotation_z(look_at_rotation, 0)
		end
		xmath.rotate(LOOK_AT, look_at_rotation, FORWARD)
		--local look_at = LOOK_AT
		LOOK_AT_ROTATION = QUAT
		--[[xmath.sub(LOOK_DIFF, look_at, e.vagon_go.config.look_at)
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
				scale = 0.5
			end
			--d_move = d_move*scale*dt
			xmath.mul(d_move, d_move, scale * dt)
			if (vmath.length(d_move) > diff_len) then
				d_move = diff
			end
			e.vagon_go.config.look_at = e.vagon_go.config.look_at + d_move
			xmath.quat_from_to(LOOK_AT_ROTATION, FORWARD, e.vagon_go.config.look_at)
			--look_at_rotation = vmath.quat_from_to(FORWARD, e.player_go.config.look_at)
		end--]]


		xmath.quat_from_to(NORMAL_ROTATION, UP, e.tunnel_movement.normal)
		--local normal_rotation = vmath.quat_from_to(UP, e.tunnel_movement.normal)
		if (NORMAL_ROTATION.x ~= NORMAL_ROTATION.x or NORMAL_ROTATION.y ~= NORMAL_ROTATION.y or NORMAL_ROTATION.z ~= NORMAL_ROTATION.z) then
			xmath.quat_rotation_z(NORMAL_ROTATION, math.rad(180))
		end
		xmath.quat_mul(QUAT, LOOK_AT_ROTATION, NORMAL_ROTATION)
		--local rotation = look_at_rotation * normal_rotation

		go.set_rotation(QUAT, e.vagon_go.model.root)

		if (e.revive and not e.vagon_go.revive_animation) then
			e.vagon_go.revive_animation = true
			go.animate(e.vagon_go.model.model, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 1, 0)
		end

		if (e.force_v and not e.vagon_go.force_animation) then
			e.vagon_go.force_animation = true
			go.set(e.vagon_go.model.model, "tint.w", 0.85)
			go.animate(e.vagon_go.model.model, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 0.5, 0)
		end
	end
end

return System