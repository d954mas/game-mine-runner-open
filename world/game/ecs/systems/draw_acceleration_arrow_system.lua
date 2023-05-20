local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local RENDER3D = require "scene3d.render.render3d"

local FACTORY = msg.url("game_scene:/factory#acceleration_arrow")

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	ARROW = COMMON.HASHES.hash("/arrow"),
	GLOW = COMMON.HASHES.hash("/glow"),
}

---@class DrawAccelerationArrowSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("acceleration_arrow")
System.name = "DrawAccelerationArrowSystem"

function System:update(dt)
	local entities = self.entities
	local rotation_glow = RENDER3D.view_rotation
	for i = 1, #entities do
		local e = entities[i]
		if (not e.visible and e.acceleration_arrow_go) then
			go.delete(assert(e.acceleration_arrow_go.root), true)
			e.acceleration_arrow_go = nil
		elseif (e.visible and not e.acceleration_arrow_go) then
			local collection = collectionfactory.create(FACTORY, e.position, e.rotation, nil, 1)
			---@class AccelerationArrowGo
			local acceleration_arrow_go = {
				root = msg.url(assert(collection[PARTS.ROOT])),
				glow = {
					root = msg.url(assert(collection[PARTS.GLOW])),
					sprite = nil
				},
			}
			acceleration_arrow_go.glow.sprite = COMMON.LUME.url_component_from_url(acceleration_arrow_go.glow.root, COMMON.HASHES.SPRITE)
			e.acceleration_arrow_go = acceleration_arrow_go
		end
		if (e.acceleration_arrow_go) then
			go.set_rotation(rotation_glow, e.acceleration_arrow_go.glow.root)
		end
	end
end

return System