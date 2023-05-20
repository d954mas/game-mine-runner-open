local M = {}

--ecs systems created in require.
--so do not cache then

-- luacheck: push ignore require

local require_old = require
local require_no_cache
local require_no_cache_name
require_no_cache = function(k)
	require = require_old
	local m = require_old(k)
	if (k == require_no_cache_name) then
		--        print("load require no_cache_name:" .. k)
		package.loaded[k] = nil
	end
	require_no_cache_name = nil
	require = require_no_cache
	return m
end

local creator = function(name)
	return function(...)
		require_no_cache_name = name
		local system = require_no_cache(name)
		if (system.init) then system.init(system, ...) end
		return system
	end
end

require = creator

M.AutoDestroySystem = require "world.game.ecs.systems.auto_destroy_system"
M.ObjectCullingDistanceSystem = require "world.game.ecs.systems.object_culling_distance_system"

M.TunnelUpdateSystem = require "world.game.ecs.systems.tunnel_update_system"
M.TunnelObjectsSystem = require "world.game.ecs.systems.tunnel_objects_system"

M.PlayerCameraSystem = require "world.game.ecs.systems.player_camera_system"
M.MoveTunnelSystem = require "world.game.ecs.systems.move_tunnel_system"
M.PlayerSpeedIncreaseSystem = require "world.game.ecs.systems.player_speed_increase_system"
M.PlayerEventSystem = require "world.game.ecs.systems.player_event_system"

--M.VagonStartSystem = require "world.game.ecs.systems.vagon_start_system"
--M.VagonCollideSystem = require "world.game.ecs.systems.vagon_collide_system"

M.PowerupTickSystem = require "world.game.ecs.systems.powerup_tick_system"
M.MagnetSystem = require "world.game.ecs.systems.magnet_system"
M.ObjectForceSystem = require "world.game.ecs.systems.object_force_system"

M.InputSystem = require "world.game.ecs.systems.input_system"

M.DrawPlayerSystem = require "world.game.ecs.systems.draw_player_system"
M.DrawGemSystem = require "world.game.ecs.systems.draw_gem_system"
M.DrawBoxSystem = require "world.game.ecs.systems.draw_box_system"
M.DrawTunnelSystem = require "world.game.ecs.systems.draw_tunnel_system"
--M.DrawVagonSystem = require "world.game.ecs.systems.draw_vagon_system"
M.DrawPowerupSystem = require "world.game.ecs.systems.draw_powerup_system"
M.DrawColumnSystem = require "world.game.ecs.systems.draw_column_system"
M.DrawAccelerationArrowSystem = require "world.game.ecs.systems.draw_acceleration_arrow_system"
--M.VdropUpdateSystem = require "world.game.ecs.systems.vdrop_update_system"

--M.DebugDrawRoadSystem = require "world.game.ecs.systems.debug_draw_road"

require = require_old

-- luacheck: pop

return M