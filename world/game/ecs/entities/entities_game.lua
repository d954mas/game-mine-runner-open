local COMMON = require "libs.common"
local DEBUG_INFO = require "debug.debug_info"
local DEFS = require "world.balance.def.defs"

local TABLE_REMOVE = table.remove
local TABLE_INSERT = table.insert

local TEMP_V = vmath.vector3(0)
local TEMP_V2 = vmath.vector3(0)

local V_UP = vmath.vector3(0, 1, 0)
local V_FORWARD = vmath.vector3(0, 0, -1)
local V_RIGHT = vmath.vector3(1, 0, 0)

local PLANE_P1 = vmath.vector3()
local PLANE_P2 = vmath.vector3()
local PLANE_P3 = vmath.vector3()
local PLANE_P4 = vmath.vector3()

local TAG = "Entities"

---@class MoveCurveConfig
---@field curve Curve
---@field a number position in curve [0,1]
---@field speed number
---@field deviation number
---@field position_descriptor number

---@class MoveData
---@field active boolean
---@field state string
---@field pos_d vector3
---@field speed_max number
---@field speed_max_a number
---@field direction number 1 or -1
---@field polygon boolean
---@field wait_delay number


---@class InputInfo
---@field action_id hash
---@field action table

---@class Size
---@field w number
---@field h number


---@class bbox
---@field w number
---@field h number

---@class Tile
---@field tile_id number

---@class EntityGame
---@field _in_world boolean is entity in world
---@field tag string tag can search entity by tag
---@field position vector3
---@field move_curve_config MoveCurveConfig
---@field input_info InputInfo
---@field auto_destroy_delay number
---@field auto_destroy boolean
---@field actions Action[]
---@field visible boolean
---@field visible_bbox bbox

---@class ENTITIES
local Entities = COMMON.class("Entities")

---@param world World
function Entities:initialize(world)
	self.world = world
	---@type EntityGame[]
	self.pool_input = {}
	---@type EntityGame[]
	self.pool_player_events = {}
end



--region ecs callbacks
---@param e EntityGame
function Entities:on_entity_removed(e)
	DEBUG_INFO.game_entities = DEBUG_INFO.game_entities - 1
	e._in_world = false
	if (e.input_info) then
		TABLE_INSERT(self.pool_input, e)
	end
	if (e.player_event) then
		TABLE_INSERT(self.pool_player_events, e)
	end

	if (e.tunnel) then
		e.tunnel:Destroy()
		e.tunnel = nil
	end

	if (e.gem_go) then
		go.delete(e.gem_go.root, true)
		e.gem_go = nil
	end
	if (e.box_go) then
		go.delete(e.box_go.root, true)
		e.box_go = nil
	end
	if (e.vagon_go) then
		go.delete(e.vagon_go.root, true)
		e.vagon_go = nil
	end
	if (e.player_go and e.player_go.model.root) then
		go.delete(e.player_go.model.root, true)
		e.player_go.model.root = nil
	end
	if (e.powerup_go) then
		go.delete(e.powerup_go.root, true)
		e.powerup_go = nil
	end
	if (e.column_go) then
		go.delete(e.column_go.root, true)
		e.column_go = nil
	end
	if (e.acceleration_arrow_go) then
		go.delete(e.acceleration_arrow_go.root, true)
		e.acceleration_arrow_go = nil
	end
	--[[for k,v in pairs(e)do
		if(string.find(k,"_go"))then
			print(k)
		end
	end--]]
end

---@param e EntityGame
function Entities:on_entity_added(e)
	DEBUG_INFO.game_entities = DEBUG_INFO.game_entities + 1
	e._in_world = true
end

---@param e EntityGame
function Entities:on_entity_updated(e)

end
--endregion


--region Entities

---@return EntityGame
function Entities:create_player()
	---@type EntityGame
	local e = {}
	e.player = true
	e.visible = true
	local path = "game_scene:/" .. "player"
	e.skin = self.world.storage.game:skin_get()
	e.player_go = {
		root = msg.url(path .. "/root"),
		model = {
			root = nil, --msg.url(path .. "model"),
			model = nil
		},
		glow_gem = {
			root = msg.url(path .. "/glow_gem"),
			sprite = nil
		},
		glow_powerup = {
			root = msg.url(path .. "/glow_powerup"),
			sprite = nil
		},
		glow_powerup_speed = {
			root = msg.url(path .. "/glow_powerup_speed"),
			sprite = nil
		},
		shine = {
			root = msg.url(path .. "/shine"),
			rotation = msg.url(path .. "/shine_rotation"),
			sprite = nil
		},
		config = {
			animation = nil,
			rotation = vmath.quat_rotation_z(0),
			look_at = vmath.vector3(0, 0, -1),
			skin = nil,
			left_right_angle = 0
		}
	}
	e.player_go.glow_gem.sprite = COMMON.LUME.url_component_from_url(e.player_go.glow_gem.root, COMMON.HASHES.SPRITE)
	e.player_go.glow_powerup.sprite = COMMON.LUME.url_component_from_url(e.player_go.glow_powerup.root, COMMON.HASHES.SPRITE)
	e.player_go.glow_powerup_speed.sprite = COMMON.LUME.url_component_from_url(e.player_go.glow_powerup_speed.root, COMMON.HASHES.SPRITE)
	e.player_go.shine.sprite = COMMON.LUME.url_component_from_url(e.player_go.shine.rotation, COMMON.HASHES.SPRITE)
	go.set(e.player_go.glow_gem.sprite, COMMON.HASHES.TINT_W, 0)
	go.set(e.player_go.glow_powerup.sprite, COMMON.HASHES.TINT, COMMON.CONSTANTS.POWERUP_COLOR_PLAYER_GLOW)
	go.set(e.player_go.glow_powerup.sprite, COMMON.HASHES.TINT_W, 0)
	go.set(e.player_go.glow_powerup_speed.sprite, COMMON.HASHES.TINT, COMMON.CONSTANTS.POWERUP_SPEED_COLOR_PLAYER_GLOW)
	go.set(e.player_go.glow_powerup_speed.sprite, COMMON.HASHES.TINT_W, 0)
	go.set(e.player_go.shine.sprite, COMMON.HASHES.TINT, COMMON.CONSTANTS.SHINE_PLAYER_COLOR)
	go.animate(e.player_go.shine.rotation, "euler.z", go.PLAYBACK_LOOP_FORWARD, -360, go.EASING_LINEAR, 8)
	msg.post(e.player_go.shine.rotation, COMMON.HASHES.MSG.DISABLE)
	msg.post(e.player_go.glow_powerup.root,COMMON.HASHES.MSG.DISABLE)
	msg.post(e.player_go.glow_powerup_speed.root,COMMON.HASHES.MSG.DISABLE)
	msg.post(e.player_go.glow_gem.root,COMMON.HASHES.MSG.DISABLE)
	--go.set(e.player_go.shine.sprite, COMMON.HASHES.TINT_W, 1)
	--model.play_anim(e.player_go.model.model, "run", go.PLAYBACK_LOOP_FORWARD)

	e.rotation = vmath.quat_rotation_z(0)
	e.angle = 0
	e.moving = true
	e.movement = {
		direction = vmath.vector3(0)
	}
	local start_distance = 0
	e.tunnel_movement = {
		speed = 6,
		speed_x = 2,
		tunnel_idx = 1,
		angle = 0,
		plane = 0.5,
		segment_idx = 0,
		plane_idx = 0,
		plane_dmove = 0,
		distance = start_distance,
		start_distance = start_distance,


		position = vmath.vector3(0, 0, 0),
		position_center = vmath.vector3(0, 0, 0),
		normal = vmath.vector3(0, 1, 0),
		dir = vmath.vector3(0, 0, -1),
	}

	return e
end

---@return EntityGame
function Entities:create_vagon(distance, plane)
	---@type EntityGame
	local e = {}
	e.vagon = true
	e.visible = false
	e.moving = false
	e.vagon_start_distance = 50
	e.distance_culling = true

	e.tunnel_movement = {
		speed = -10,
		speed_x = 0,
		tunnel_idx = 1,
		angle = 0,
		plane = plane + 0.5,
		segment_idx = 0,
		plane_idx = 0,
		plane_dmove = 0,
		distance = distance,
		position = vmath.vector3(0, 0, -100),
		position_center = vmath.vector3(0, 0, 0),
		normal = vmath.vector3(0, 1, 0),
		dir = vmath.vector3(0, 0, -1),
	}

	return e
end

function Entities:create_tunnel(points_count, url)
	---@type EntityGame
	local e = {}
	e.points = { }
	for i = 1, points_count do
		e.points[i] = vmath.vector3()
	end
	e.tunnel = game.create_tunnel()
	e.tunnel_size = 2
	e.tunnel_angles = 10
	e.tunnel_delta_angle = math.rad(-105)
	e.tunnel:SetAngles(e.tunnel_angles)
	e.tunnel:SetPlaneSize(e.tunnel_size)
	e.tunnel:SetStartAngle(e.tunnel_delta_angle)
	--e.tunnel:SetPoints(points)
	e.tunnel_segments = points_count - 1
	e.tunnel_go = {
		root = assert(url),
		mesh = assert(url),
		vertices = nil,
		config = {
			content_version = -1;
			visible = true
		}
	}
	---@type EntityGame[]
	e.game_objects = {}
	e.tunnel_go.mesh = COMMON.LUME.url_component_from_url(e.tunnel_go.root, COMMON.HASHES.hash("mesh"))
	e.tunnel_go.vertices = go.get(e.tunnel_go.mesh,
			COMMON.HASHES.hash("vertices"))

	--self:tunnel_init(e)

	return e
end

function Entities:tunnel_init(e)
	if(self.world.storage.game:world_id_def_get().random_colors)then
		e.tunnel:SetPlanesRandomColors()
	end
	resource.set_buffer(e.tunnel_go.vertices, e.tunnel:GetBuffer())
end

---@param tunnel EntityGame
---@return EntityGame
function Entities:create_gem(tunnel, segment_idx, plane_idx)
	local start_idx = (tunnel.tunnel_idx - 1) * tunnel.tunnel_segments

	---@type EntityGame
	local e = {}
	e.gem = true
	e.gem_idx = segment_idx + plane_idx * 0.1
	e.tunnel_position = { segment = assert(segment_idx), plane = assert(plane_idx) }

	local center = vmath.vector3()
	center.x, center.y, center.z = tunnel.tunnel:GetPlaneCenter(segment_idx, plane_idx)
	TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneNormal(segment_idx, plane_idx)
	xmath.mul(TEMP_V2, TEMP_V, 0.8)
	xmath.add(center, center, TEMP_V2)

	e.position = center
	e.position_start = vmath.vector3(e.position)
	e.rotation = nil
	e.tunnel_dist = start_idx + 0.5 + (segment_idx)
	local normal_rotation = vmath.quat_from_to(V_UP, TEMP_V)
	--fixed normal Perpendicular V_UP
	local diff_y = TEMP_V.y - V_UP.y
	if (diff_y < -1.98 or normal_rotation.x ~= normal_rotation.x or normal_rotation.y ~= normal_rotation.y or normal_rotation.z ~= normal_rotation.z) then
		xmath.quat_rotation_z(normal_rotation, 0)
	end

	--[[TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneDir(segment_idx, plane_idx)
	local look_at_rotation = vmath.quat_from_to(V_FORWARD, TEMP_V)
	if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
		look_at_rotation = vmath.quat_rotation_z(0)
	end--]]

	e.rotation = normal_rotation

	e.distance_culling = true

	table.insert(tunnel.game_objects, e)

	return e
end

---@param tunnel EntityGame
---@return EntityGame
function Entities:create_gem_daily(tunnel, segment_idx, plane_idx, gem_daily_type)
	local e = self:create_gem(tunnel, segment_idx, plane_idx)
	e.gem_daily = true
	e.gem_daily_type = assert(gem_daily_type)
	return e
end

function Entities:create_box(tunnel, segment_idx, plane_idx)
	local start_idx = (tunnel.tunnel_idx - 1) * tunnel.tunnel_segments

	---@type EntityGame
	local e = {}
	e.box = true
	e.tunnel_position = { segment = assert(segment_idx), plane = assert(plane_idx) }
	e.delta_dist = 0.5

	local center = vmath.vector3()
	center.x, center.y, center.z = tunnel.tunnel:GetPlaneCenter(segment_idx, plane_idx)
	TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneNormal(segment_idx, plane_idx)
	local normal_rotation = vmath.quat_from_to(V_UP, TEMP_V)
	local diff_y = TEMP_V.y - V_UP.y
	if (diff_y < -1.98 or normal_rotation.x ~= normal_rotation.x or normal_rotation.y ~= normal_rotation.y or normal_rotation.z ~= normal_rotation.z) then
		xmath.quat_rotation_z(normal_rotation, math.pi)
	end
	xmath.mul(TEMP_V, TEMP_V, 0.99 * 1 / 1.5)
	xmath.add(center, center, TEMP_V)

	e.position = center
	e.rotation = nil
	e.tunnel_dist = start_idx + 0.5 + (segment_idx)

	TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneDir(segment_idx, plane_idx)
	local look_at_rotation = vmath.quat_from_to(V_FORWARD, TEMP_V)
	if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
		look_at_rotation = vmath.quat_rotation_z(0)
	end

	e.rotation =  normal_rotation

	e.distance_culling = true

	table.insert(tunnel.game_objects, e)
	if(self.world.game.tunnel_world.id == DEFS.WORLDS.WORLDS_BY_ID.GRASS_WORLD.id)then
		e.delta_dist = 0.2

		e.tunnel_position.plane_2 = e.tunnel_position.plane + 5
		if e.tunnel_position.plane_2 > 9 then
			e.tunnel_position.plane_2 = e.tunnel_position.plane_2 - 10
		end

		local center = vmath.vector3()
		center.x, center.y, center.z = tunnel.tunnel:GetPlaneCenter(segment_idx, plane_idx)
		local center_2 = vmath.vector3()
		center_2.x, center_2.y, center_2.z = tunnel.tunnel:GetPlaneCenter(segment_idx, e.tunnel_position.plane_2)

		local diff = center_2 - center
		xmath.normalize(diff, diff)
		local normal_rotation = vmath.quat_from_to(V_UP, diff)
		if (normal_rotation.x ~= normal_rotation.x or normal_rotation.y ~= normal_rotation.y or normal_rotation.z ~= normal_rotation.z) then
			xmath.quat_rotation_z(normal_rotation, 0)
			print("BAD quat")
		end
		e.tunnel_position.plane_2 = nil
		e.rotation = normal_rotation
	end

	--[[TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneDir(segment_idx, plane_idx)
	local look_at_rotation = vmath.quat_from_to(V_FORWARD, TEMP_V)
	if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
		look_at_rotation = vmath.quat_rotation_x(0)

	end--]]




	return e
end

local column_idx = 0
function Entities:create_column(tunnel, segment_idx, plane_idx)
	local start_idx = (tunnel.tunnel_idx - 1) * tunnel.tunnel_segments
	column_idx = column_idx + 1
	---@type EntityGame
	local e = {}
	e.column = true
	e.column_odd = column_idx % 2 == 0
	e.tunnel_position = { segment = assert(segment_idx), plane = assert(plane_idx), plane_2 = plane_idx }
	e.tunnel_position.plane_2 = e.tunnel_position.plane_2 + 5
	if e.tunnel_position.plane_2 > 9 then
		e.tunnel_position.plane_2 = e.tunnel_position.plane_2 - 10
	end

	local center = vmath.vector3()
	center.x, center.y, center.z = tunnel.tunnel:GetPlaneCenter(segment_idx, plane_idx)
	local center_2 = vmath.vector3()
	center_2.x, center_2.y, center_2.z = tunnel.tunnel:GetPlaneCenter(segment_idx, e.tunnel_position.plane_2)

	local diff = center_2 - center
	xmath.normalize(diff, diff)
	local normal_rotation = vmath.quat_from_to(V_UP, diff)
	if (normal_rotation.x ~= normal_rotation.x or normal_rotation.y ~= normal_rotation.y or normal_rotation.z ~= normal_rotation.z) then
		xmath.quat_rotation_z(normal_rotation, 0)
		print("BAD quat")
	end
	--xmath.mul(TEMP_V, TEMP_V, 0.99 * 1 / 1.5)
	--xmath.add(center, center, TEMP_V)

	e.position = center
	e.rotation = nil
	e.tunnel_dist = start_idx + 0.5 + (segment_idx)

	--[[TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneDir(segment_idx, plane_idx)
	local look_at_rotation = vmath.quat_from_to(V_FORWARD, TEMP_V)
	if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
		look_at_rotation = vmath.quat_rotation_x(0)

	end--]]

	e.rotation = normal_rotation

	e.distance_culling = true

	table.insert(tunnel.game_objects, e)

	return e
end

function Entities:create_player_event(type, data)
	---@type EntityGame
	local e = TABLE_REMOVE(self.pool_player_events)
	if (not e) then
		e = { player_event = { type = nil, data = nil }, auto_destroy = true }
	end
	e.player_event.type = type
	e.player_event.data = data
	return e
end

function Entities:create_powerup(tunnel, segment_idx, plane_idx, powerup_id)
	local start_idx = (tunnel.tunnel_idx - 1) * tunnel.tunnel_segments
	---@type EntityGame
	local e = {}
	e.powerup = true
	assert(DEFS.POWERUPS[powerup_id], "unknown powerup:" .. tostring(powerup_id))
	e.powerup_id = assert(powerup_id)
	e.tunnel_position = { segment = assert(segment_idx), plane = assert(plane_idx) }

	local center = vmath.vector3()
	center.x, center.y, center.z = tunnel.tunnel:GetPlaneCenter(segment_idx, plane_idx)
	TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneNormal(segment_idx, plane_idx)
	local normal_rotation = vmath.quat_from_to(V_UP, TEMP_V)
	local diff_y = TEMP_V.y - V_UP.y
	if (diff_y < -1.98 or normal_rotation.x ~= normal_rotation.x or normal_rotation.y ~= normal_rotation.y or normal_rotation.z ~= normal_rotation.z) then
		xmath.quat_rotation_z(normal_rotation, 0)
	end

	xmath.mul(TEMP_V, TEMP_V, 0.99 * 1 / 1.5)
	xmath.add(center, center, TEMP_V)

	e.position = center
	e.rotation = nil
	e.tunnel_dist = start_idx + 0.5 + (segment_idx)

	TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneDir(segment_idx, plane_idx)
	local look_at_rotation = vmath.quat_from_to(V_FORWARD, TEMP_V)
	if (look_at_rotation.x ~= look_at_rotation.x or look_at_rotation.y ~= look_at_rotation.y or look_at_rotation.z ~= look_at_rotation.z) then
		look_at_rotation = vmath.quat_rotation_z(0)
	end

	e.rotation = normal_rotation
	e.distance_culling = true
	table.insert(tunnel.game_objects, e)
	return e
end

function Entities:create_acceleration_arrow(tunnel, segment_idx, plane_idx)
	local start_idx = (tunnel.tunnel_idx - 1) * tunnel.tunnel_segments

	---@type EntityGame
	local e = {}
	e.acceleration_arrow = true
	e.tunnel_position = { segment = assert(segment_idx), plane = assert(plane_idx) }

	local plane_2 = plane_idx + 5
	if plane_2 > 9 then
		plane_2 = plane_2 - 10
	end

	local center = vmath.vector3()
	center.x, center.y, center.z = tunnel.tunnel:GetPlaneCenter(segment_idx, plane_idx)
	local center_2 = vmath.vector3()
	center_2.x, center_2.y, center_2.z = tunnel.tunnel:GetPlaneCenter(segment_idx, plane_2)

	local diff = center_2 - center

	e.position = center+ diff/2
	e.rotation = nil
	e.tunnel_dist = start_idx + 0.5 + (segment_idx)


	--start left
	PLANE_P1.x, PLANE_P1.y, PLANE_P1.z = tunnel.tunnel:GetPlaneP1(segment_idx, plane_idx)
	--start right
	PLANE_P2.x, PLANE_P2.y, PLANE_P2.z = tunnel.tunnel:GetPlaneP2(segment_idx, plane_idx)
	--end left
	PLANE_P3.x, PLANE_P3.y, PLANE_P3.z = tunnel.tunnel:GetPlaneP3(segment_idx, plane_idx)
	--end right
	PLANE_P4.x, PLANE_P4.y, PLANE_P4.z = tunnel.tunnel:GetPlaneP4(segment_idx, plane_idx)

	local dir = vmath.normalize(PLANE_P3-PLANE_P1)
	local right = vmath.normalize(PLANE_P2-PLANE_P1)
	local normal = vmath.normalize(vmath.cross(right,dir))
	TEMP_V.x, TEMP_V.y, TEMP_V.z = tunnel.tunnel:GetPlaneNormal(segment_idx, plane_idx)

	local dir_q = vmath.quat_from_to(V_FORWARD,dir)
	local right_q = vmath.quat_from_to(V_RIGHT,right)

	xmath.normalize(diff, diff)
	local normal_rotation = vmath.quat_from_to(V_UP, diff)
	if (normal_rotation.x ~= normal_rotation.x or normal_rotation.y ~= normal_rotation.y or normal_rotation.z ~= normal_rotation.z) then
		xmath.quat_rotation_z(normal_rotation, 0)
	end

	e.rotation = vmath.quat_rotation_z(0)-- normal_rotation

	e.distance_culling = true

	table.insert(tunnel.game_objects, e)

	return e
end

---@return EntityGame
function Entities:create_input(action_id, action)
	local input = TABLE_REMOVE(self.pool_input)
	if (not input) then
		input = { input_info = {}, auto_destroy = true }
	end
	input.input_info.action_id = action_id
	input.input_info.action = action
	return input
end

--endregion

return Entities




