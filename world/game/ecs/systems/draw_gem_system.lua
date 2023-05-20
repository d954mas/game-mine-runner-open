local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local RENDER3D = require("scene3d.render.render3d")

local TEMP_Q = vmath.quat_rotation_z(0)
local TEMP_Q2 = vmath.quat_rotation_z(0)

local TEMP_V = vmath.vector3(0)

local FACTORY = msg.url("game_scene:/factory#gem")
local FACTORY_DAILY_GEM = {
	msg.url("game_scene:/factory#gem_daily_1"),
	msg.url("game_scene:/factory#gem_daily_2"),
	msg.url("game_scene:/factory#gem_daily_3"),
}

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	MODEL = COMMON.HASHES.hash("/model"),
	GLOW = COMMON.HASHES.hash("/glow")
}

---@class DrawGemSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("gem")
System.name = "DrawGemSystem"

local SCALE_V = vmath.vector3(40/50)

function System:init()
	self.angle = 0
	self.time = 0
end

function System:update(dt)
	self.time = self.time + dt
	self.rotation_glow = RENDER3D.view_rotation
	self.angle = self.angle + math.pi / 2 * dt
	xmath.quat_rotation_y(TEMP_Q, self.angle)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		if (not e.visible and e.gem_go) then
			go.delete(assert(e.gem_go.root), true)
			e.gem_go = nil
		elseif (e.visible and not e.gem_go) then
			local factory_url = FACTORY
			if (e.gem_daily) then
				factory_url = assert(FACTORY_DAILY_GEM[e.gem_daily_type])
			end
			local collection = collectionfactory.create(factory_url, e.position, nil, nil, SCALE_V)
			---@class GemGo
			local gem_go = {
				root = msg.url(assert(collection[PARTS.ROOT])),
				model = msg.url(assert(collection[PARTS.MODEL])),
				glow = msg.url(assert(collection[PARTS.GLOW])),
				sprite = nil
			}
			e.gem_go = gem_go
			if (e.gem_daily) then
				local glow_sprite = COMMON.LUME.url_component_from_url(gem_go.glow, COMMON.HASHES.SPRITE)
				go.set(glow_sprite, "tint", vmath.vector4(0.8, 0.5, 0, 1))
			end
		end

		if (e.gem_go) then
			--	xmath.quat_mul(TEMP_Q2, e.rotation, TEMP_Q)
			--if(not e.gem_daily)then
			xmath.quat_mul(TEMP_Q2, e.rotation, TEMP_Q)
			go.set_rotation(TEMP_Q2, e.gem_go.model)
			--	end


			if (e.magnet) then
				go.set_position(e.position, e.gem_go.root)
			else
				local dposy = math.sin((self.time + (0.33 * e.gem_idx))*4) * 0.2
				TEMP_V.x = 0
				TEMP_V.y = dposy
				TEMP_V.z = 0

				xmath.rotate(TEMP_V,e.rotation,TEMP_V)
				--xmath.add(e.position,e.position_start,TEMP_V)
				go.set_position(TEMP_V, e.gem_go.glow)
				go.set_position(TEMP_V, e.gem_go.model)
			end
			if(e.auto_destroy_delay)then
				local a = 1-(e.auto_destroy_delay/0.3)
				local scale = 1-(a * 5)
				if(scale<=0)then
					scale = 0.001
				end
				xmath.mul(TEMP_V,SCALE_V,scale)
				go.set_scale(TEMP_V,e.gem_go.root)
			end
			go.set_rotation(self.rotation_glow, e.gem_go.glow)



			--	go.set_rotation(RENDER3D.view_rotation, e.gem_go.glow)
		end
	end
end

return System