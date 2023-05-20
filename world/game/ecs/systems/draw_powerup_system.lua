local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local RENDER3D = require("scene3d.render.render3d")

local NORMAL_ROTATION = vmath.quat_rotation_z(0)


local TEMP_Q = vmath.quat_rotation_z(0)
local TEMP_Q2 = vmath.quat_rotation_z(0)
local TEMP_Q3 = vmath.quat_rotation_z(0)
local TEMP_Q4 = vmath.quat_rotation_z(0)
local TEMP_V = vmath.vector3(0)

--local TINT_COLOR = COMMON.LUME.color_parse_hex("#A3D9FF")
--local TINT_COLOR = COMMON.LUME.color_parse_hex("#54C6EB")
--local TINT_COLOR = COMMON.LUME.color_parse_hex("#8EF9F3")
local TINT_COLOR = vmath.vector4(COMMON.CONSTANTS.POWERUP_COLOR)
TINT_COLOR.w = 0.95

local FACTORY = {
	[DEFS.POWERUPS.RUN.id] = msg.url("game_scene:/factory#powerup_run"),
	[DEFS.POWERUPS.STAR.id] = msg.url("game_scene:/factory#powerup_star"),
	[DEFS.POWERUPS.MAGNET.id] = msg.url("game_scene:/factory#powerup_magnet"),
}

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	MODEL = COMMON.HASHES.hash("/model"),
	GLOW = COMMON.HASHES.hash("/glow")
}

 ---@class DrawpowerupSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("powerup")
System.name = "DrawPowerupSystem"

function System:init()
	self.angle = 0
	self.time = 0
	self.camera_delta_angle = -math.rad(15)+ math.rad(90)
end

function System:count_angle_for_x2()
	local tm = self.world.game_world.game.level_creator.player.tunnel_movement
	local distance = tm.distance
	local tunnel, _ = self.world.game_world.game:get_tunnel_by_distance(distance)
	--local rotation = look_at_rotation * normal_rotation
	local angle_circle = tm.plane / tunnel.tunnel_angles
	xmath.quat_rotation_z(NORMAL_ROTATION, angle_circle * math.pi * 2 + self.camera_delta_angle)

end

function System:update(dt)
	self.angle = self.angle + math.pi / 2 * dt
	self.time = self.time + dt
	self.rotation_glow = RENDER3D.view_rotation
	--local angle_2 = math.sin(self.time*1.66)*math.rad(15)
	local dposy = math.sin(self.time*1.66*1.5)*0.066
	TEMP_V.y = dposy

--	xmath.quat_rotation_z(TEMP_Q2, angle_2)
--	xmath.quat_rotation_y(TEMP_Q, self.angle)
--	xmath.quat_mul(TEMP_Q3,TEMP_Q,TEMP_Q2)

	--self:count_angle_for_x2()
	--xmath.quat_mul(TEMP_Q2,NORMAL_ROTATION,TEMP_Q2)
	local entities = self.entities
	for i=1,#entities do
		local e = entities[i]
		if (not e.visible and e.powerup_go) then
			go.delete(assert(e.powerup_go.root), true)
			e.powerup_go = nil
		elseif (e.visible and not e.powerup_go) then
			local factory_url = assert(FACTORY[e.powerup_id])
			local collection = collectionfactory.create(factory_url, e.position, nil, nil, 1)
			---@class powerupGo
			local powerup_go = {
				root = msg.url(assert(collection[PARTS.ROOT])),
				model = msg.url(assert(collection[PARTS.MODEL])),
				glow = msg.url(assert(collection[PARTS.GLOW])),
				sprite = nil
			}
			e.powerup_go = powerup_go
			local glow_sprite = COMMON.LUME.url_component_from_url(powerup_go.glow, COMMON.HASHES.SPRITE)
			go.set(glow_sprite, "tint", TINT_COLOR)
		end

		if (e.powerup_go) then
			--	xmath.quat_mul(TEMP_Q2, e.rotation, TEMP_Q)
			if(e.powerup_id==DEFS.POWERUPS.STAR.id)then
				go.set_rotation(self.rotation_glow, e.powerup_go.model)
				go.set_position(TEMP_V,e.powerup_go.model)
			else
			--	go.set_rotation(TEMP_Q, e.powerup_go.model)
				--xmath.quat_mul(TEMP_Q4,e.rotation,TEMP_Q3)
				--go.set_rotation(TEMP_Q4, e.powerup_go.model)
				go.set_rotation(self.rotation_glow, e.powerup_go.model)
				go.set_position(TEMP_V,e.powerup_go.model)
			end
			go.set_rotation(self.rotation_glow,e.powerup_go.glow)
			--	go.set_rotation(RENDER3D.view_rotation, e.powerup_go.glow)
			--
		end
	end
end


return System