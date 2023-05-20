local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"

local FACTORY_BY_WORLD = {
	[DEFS.WORLDS.WORLDS_BY_ID.MINE_WORLD.id] = msg.url("game_scene:/factory/mine#box_1"),
	[DEFS.WORLDS.WORLDS_BY_ID.METAL_WORLD.id] = msg.url("game_scene:/factory/metal#box_1"),
	[DEFS.WORLDS.WORLDS_BY_ID.TOON_WORLD.id] = msg.url("game_scene:/factory/toon#box_1"),
	[DEFS.WORLDS.WORLDS_BY_ID.DARK_WORLD.id] = msg.url("game_scene:/factory/mine#box_1"),
	[DEFS.WORLDS.WORLDS_BY_ID.GRASS_WORLD.id] = msg.url("game_scene:/factory/grass#box_1"),
}

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	MESH = COMMON.HASHES.hash("/mesh")
}

---@class DrawBoxSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("box")
System.name = "DrawBoxSystem"

function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		if (not e.visible and e.box_go) then
			go.delete(assert(e.box_go.root), true)
			e.box_go = nil
		elseif (e.visible and not e.box_go) then
			local FACTORY = FACTORY_BY_WORLD[self.world.game_world.storage.game:world_id_get()]
			local collection = collectionfactory.create(FACTORY, e.position, e.rotation, nil, 40 / 50)
			---@class BoxGo
			local box_go = {
				root = msg.url(assert(collection[PARTS.ROOT])),
				mesh = {
					root = msg.url(assert(collection[PARTS.MESH])),
					model = nil
				}
			}
			box_go.mesh.model = COMMON.LUME.url_component_from_url(box_go.mesh.root, COMMON.HASHES.MESH)
			e.box_go = box_go
		end
		if (e.box_go) then
			if (e.revive and not e.box_go.revive_animation) then
				e.box_go.revive_animation = true
				go.animate(e.box_go.mesh.model, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 1, 0)
			end
			if (e.force_v) then
				if (not e.box_go.force_animation) then
					e.box_go.force_animation = true
					go.set(e.box_go.mesh.model, "tint.w", 0.85)
					go.animate(e.box_go.mesh.model, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 0.33, 0)
				end
				go.set_position(e.position, e.box_go.root)
			end
		end
	end
end

return System