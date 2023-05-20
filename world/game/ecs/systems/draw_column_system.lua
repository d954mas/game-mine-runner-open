local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"


local FACTORY_BY_WORLD = {
	[DEFS.WORLDS.WORLDS_BY_ID.MINE_WORLD.id] = msg.url("game_scene:/factory/mine#box_column"),
	[DEFS.WORLDS.WORLDS_BY_ID.METAL_WORLD.id] = msg.url("game_scene:/factory/metal#box_column"),
	[DEFS.WORLDS.WORLDS_BY_ID.TOON_WORLD.id] = msg.url("game_scene:/factory/toon#box_column"),
	[DEFS.WORLDS.WORLDS_BY_ID.DARK_WORLD.id] = msg.url("game_scene:/factory/mine#box_column"),
	[DEFS.WORLDS.WORLDS_BY_ID.GRASS_WORLD.id] = msg.url("game_scene:/factory/grass#box_column"),
}

local PARTS = {
	ROOT = COMMON.HASHES.hash("/root"),
	MESH = COMMON.HASHES.hash("/mesh")
}

---@class DrawColumnSystem:ECSSystemProcessing
local System = ECS.system()
System.filter = ECS.filter("column")
System.name = "DrawColumnSystem"

---@param e EntityGame
function System:update(dt)
	local entities = self.entities
	for i = 1, #entities do
		local e = entities[i]
		if (not e.visible and e.column_go) then
			go.delete(assert(e.column_go.root), true)
			e.column_go = nil
		elseif (e.visible and not e.column_go) then
			local FACTORY = FACTORY_BY_WORLD[self.world.game_world.storage.game:world_id_get()]
			local collection = collectionfactory.create(FACTORY, e.position, e.rotation, nil, e.column_odd and 40 / 50 or 39 / 50)
			---@class ColumnGo
			local column_go = {
				root = msg.url(assert(collection[PARTS.ROOT])),
				mesh = {
					root = msg.url(assert(collection[PARTS.MESH])),
					model = nil,
					model_2 = nil
				}
			}
			column_go.mesh.model = COMMON.LUME.url_component_from_url(column_go.mesh.root, COMMON.HASHES.MESH)
			column_go.mesh.model_2 = COMMON.LUME.url_component_from_url(column_go.mesh.root, COMMON.HASHES.hash("mesh_2"))
			e.column_go = column_go
		end
		if (e.column_go) then
			if (e.revive and not e.column_go.revive_animation) then
				e.column_go.revive_animation = true
				go.animate(e.column_go.mesh.model, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 1, 0)
				go.animate(e.column_go.mesh.model_2, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 1, 0)
			end
			if (e.force_v) then
				if (not e.column_go.force_animation) then
					e.column_go.force_animation = true
					go.set(e.column_go.mesh.model, "tint.w", 0.85)
					go.set(e.column_go.mesh.model_2, "tint.w", 0.85)
					go.animate(e.column_go.mesh.model, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 0.33, 0)
					go.animate(e.column_go.mesh.model_2, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INBACK, 0.33, 0)
				end
				go.set_position(e.position, e.column_go.root)
			end
		end
	end
end

return System