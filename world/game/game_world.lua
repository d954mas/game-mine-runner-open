local COMMON = require "libs.common"
local EcsGame = require "world.game.ecs.game_ecs"
local ENUMS = require "world.enums.enums"
local DEBUG_INFO = require "debug.debug_info"
local ACTIONS = require "libs.actions.actions"
local DEFS = require "world.balance.def.defs"
local Tasks = require "world.balance.tasks"
local LevelCreator = require "world.game.levels.level_creator"

local IS_DEV = COMMON.CONSTANTS.VERSION_IS_DEV

local MATH_FLOOR = math.floor

local TAG = "GAME_WORLD"

---@class GameWorld
local GameWorld = COMMON.class("GameWorld")

---@param world World
function GameWorld:initialize(world)
	self.world = assert(world)
	self.ecs_game = EcsGame(self.world)
	self.tasks = Tasks(self)
	self:reset_state()
end

function GameWorld:reset_state()
	self.actions = ACTIONS.Parallel()
	self.actions.drop_empty = false
	self.state = {
		gems = 0,
		time = 0,
		start_timer = 0,
		state = ENUMS.GAME_STATE.MENU,
		speed_level = 1,
		speed_level_time = 0,
		lose = false,
		score = 0,
		highscore = self.world.storage.game:highscore_get(),
		revive = nil,
		gem_daily_take = false,
		revive_time = 0,
		gem_take_time = -1,
		powerup_take_time = -1,
		powerups = {
			[DEFS.POWERUPS.MAGNET.id] = { duration = -10 },
			[DEFS.POWERUPS.STAR.id] = { duration = -10 },
			[DEFS.POWERUPS.RUN.id] = { duration = -10 }, --worked for more few second when duration end
		}
	}
end

function GameWorld:game_loaded()
	DEBUG_INFO.game_reset()
	self.textures = {
		mine_world = {
			texture = go.get("game_scene:/textures#textures", "mine_world")
		},
		dark_world = {
			texture = go.get("game_scene:/textures#textures", "dark_world")
		},
		toon_world = {
			texture = go.get("game_scene:/textures#textures", "toon_world")
		},
		metal_world = {
			texture = go.get("game_scene:/textures#textures", "metal_world")
		},
		grass_world = {
			texture = go.get("game_scene:/textures#textures", "grass_world")
		}
	}

	self.tunnel_world = self.world.storage.game:world_id_def_get()
	self.level_creator = LevelCreator(self.world)
	self.level_creator:create()

	self.world.sounds:play_music(self.world.sounds.music.menu)

	--recreate world to current def
	self:set_tunnel_world(self.world.storage.game:world_id_def_get())
end

function GameWorld:set_tunnel_world(world_def)
	self.tunnel_world = assert(world_def)
	local world_texture = assert(self.textures[world_def.texture])
	self.world.storage.game:world_id_set(self.tunnel_world.id)
	local ctx = COMMON.CONTEXT:set_context_top_game()
	for _,tunnel in ipairs(self.level_creator.tunnels)do
		go.set(tunnel.tunnel_go.mesh, "texture0", world_texture.texture)
	end
	self.level_creator:clear_game()
	self.level_creator:create_game()
	COMMON.RENDER.renders.game:init_directional_light()
	ctx:remove()
end

function GameWorld:update(dt)
	if (self.state.state == ENUMS.GAME_STATE.RUN and self.state.start_timer == 0) then
		if (IS_DEV) then DEBUG_INFO.ecs_update_dt = socket.gettime() end
		--slow more when pickup. Bad feeling
		--[[local dt_scale = 1
		if(self.state.gem_take_time-self.state.time>-0.5)then
		--	dt_scale = 0.5
		end
		if(self.state.powerup_take_time-self.state.time>-0.5)then
			local a = math.abs(self.state.powerup_take_time-self.state.time)*(1/0.5)
			dt_scale = 0.5 + 0.5 * a
		end
		dt = dt * dt_scale--]]
		self.ecs_game:update(dt)
		if IS_DEV then DEBUG_INFO.update_ecs_dt(socket.gettime() - DEBUG_INFO.ecs_update_dt) end
		self.state.time = self.state.time + dt
		if (self.actions) then self.actions:update(dt) end
		if (not self.world.storage.game:is_tutorial_completed()) then
			local distance = self.level_creator.player.tunnel_movement.distance
			if (distance > 35) then
				self:tutorial_completed()
			end
		end
	else
		if (self.state.start_timer > 0) then
			self.state.start_timer = math.max(0, self.state.start_timer - dt)
			if (self.state.start_timer == 0) then
				self.state.revive = false
			end
		end
		--or not drawing? wtf
		self.ecs_game:update(0)
	end
end

function GameWorld:final()
	self:reset_state()
	self.ecs_game:clear()
end

function GameWorld:on_input(action_id, action)
	if (self.state.state == ENUMS.GAME_STATE.TUTORIAL_WAIT) then
		local input = COMMON.HASHES.INPUT
		if (action_id == input.TOUCH or action_id == input.ARROW_RIGHT or action_id == input.ARROW_LEFT
				or action_id == input.A or action_id == input.D) and action.pressed then
			self.state.state = ENUMS.GAME_STATE.RUN
			self.world.sdk:gameplay_start()
			local ctx_game_gui = COMMON.CONTEXT:set_context_top_game_gui()
			ctx_game_gui.data:tutorial_start_run()
			ctx_game_gui:remove()
		end
	end
	--[[if (self.state.state == ENUMS.GAME_STATE.RUN and not self.state.lose) then
		self.ecs_game:add_entity(self.ecs_game.entities:create_input(action_id, action))
	end--]]
end

function GameWorld:game_pause()
	if (self.state.state == ENUMS.GAME_STATE.RUN) then
		self.state.state = ENUMS.GAME_STATE.PAUSE
		self.world.sdk:gameplay_stop()
	end
end
function GameWorld:game_resume()
	if (self.state.state == ENUMS.GAME_STATE.PAUSE) then
		self.state.state = ENUMS.GAME_STATE.RUN
		self.world.sdk:gameplay_start()
	end
end

function GameWorld:lose()
	if (not self.state.lose) then
		self.state.lose = true
		if(self.world.storage.game:is_tutorial_completed())then
			self.world.storage.game:gems_game_set(self.state.gems)
		end
		local player = self.level_creator.player
		player.moving = false

		self.world.sounds:player_hit()

		if self.world.storage.game:is_tutorial_completed() then
			self.actions:add_action(function()
				COMMON.coroutine_wait(0.85)
				local SM = reqf "libs_project.sm"
				SM:show(SM.MODALS.LOSE)
				self.world.sdk:gameplay_stop()
			end)
		else

			self.actions:add_action(function()
				self.world.sdk:gameplay_stop()
				local ctx = COMMON.CONTEXT:set_context_top_fader()
				ctx.data:reload_game()
				ctx:remove()
				COMMON.coroutine_wait(1)
				self:restart_run()
				self.state.start_timer = 0
				local ctx_game_gui = COMMON.CONTEXT:set_context_top_game_gui()
				ctx_game_gui.data:game_gui_show(false)
				while (not ctx_game_gui.data.animation_game_gui:is_empty()) do ctx_game_gui.data.animation_game_gui:update(1) end
				ctx_game_gui.data:tutorial_begin()
				ctx_game_gui:remove()


			end)
		end


	end
end

function GameWorld:tutorial_completed()
	self.world.storage.game:tutorial_completed()
	local ctx = COMMON.CONTEXT:set_context_top_game_gui()
	ctx.data:game_gui_show(true)
	ctx.data:tutorial_hide_input(true)
	ctx:remove()
	self.world.game.tasks:complete_tutorial()
	self.world.sounds:play_music(self.world.sounds.music.game)

end

---@return EntityGame
---@return number
function GameWorld:get_tunnel_by_distance(distance)
	local segments = self.level_creator.tunnels[1].tunnel_segments
	local tunnel_idx = MATH_FLOOR((distance / segments) + 1)
	local segment_idx = MATH_FLOOR(distance % (segments))
	local result_tunnel
	for _, tunnel in ipairs(self.level_creator.tunnels) do
		if (tunnel.tunnel_idx == tunnel_idx) then
			result_tunnel = tunnel
			break
		end
	end
	--assert(result_tunnel, "no tunnel with id:" .. tunnel_idx)
	if (not result_tunnel) then return nil end

	local d_move = distance - (result_tunnel.tunnel_idx - 1) * result_tunnel.tunnel_segments - segment_idx
	return result_tunnel, segment_idx, d_move
end

function GameWorld:points_add(points)
	self.state.score = self.state.score + points
	self.tasks:run_add_points(points)
end

function GameWorld:gem_take(object)
	local level = self.world.storage.upgrades:get_level(DEFS.POWERUPS.MORE_GEMS.id)
	local count = DEFS.POWERUPS.MORE_GEMS.levels[level].gems
	self.state.gems = self.state.gems + count
	self.world.sounds:play_sound(self.world.sounds.sounds.gem_take)
	self.tasks:run_add_gems(count)
	self.world.game.ecs_game:add(self.world.game.ecs_game.entities:create_player_event(ENUMS.PLAYER_EFFECT.COLLECT_GEM, nil))
	self.state.gem_take_time = self.state.time
end

---@param e EntityGame
function GameWorld:gem_daily_take(e)
	self.world.storage.game:gems_daily_take(e.gem_daily_type)
	self.state.gem_daily_take = true
	self.world.sounds:play_sound(self.world.sounds.sounds.gem_take_daily)
end

function GameWorld:acceleration_arrow_take(e)
	self.state.speed_level = self.state.speed_level + 1
	self.state.speed_level_time = 1
	self.world.sounds:play_sound(self.world.sounds.sounds.speedup)
end

---@param e EntityGame
function GameWorld:powerup_take(powerup_id, no_task)
	local level = self.world.storage.upgrades:get_level(powerup_id)
	local duration = DEFS.POWERUPS[powerup_id].levels[level].duration
	self.state.powerups[powerup_id].duration = duration
	local ctx = COMMON.CONTEXT:set_context_top_game_gui()
	ctx.data:powerup_take(powerup_id, duration)
	ctx:remove()

	--when no task it revieve so no need for sound or tasks
	if (not no_task) then
		self.tasks:powerup_collected(powerup_id)
		if (powerup_id == DEFS.POWERUPS.RUN.id) then
			self.world.sounds:play_sound(self.world.sounds.sounds.powerup_run)
		elseif (powerup_id == DEFS.POWERUPS.STAR.id) then
			self.world.sounds:play_sound(self.world.sounds.sounds.powerup_x2)
		elseif (powerup_id == DEFS.POWERUPS.MAGNET.id) then
			self.world.sounds:play_sound(self.world.sounds.sounds.powerup_magnet)
		end
	end

	self.world.game.ecs_game:add(self.world.game.ecs_game.entities:create_player_event(ENUMS.PLAYER_EFFECT.COLLECT_POWERUP, nil))
	--print("powerup_take:" .. powerup_id)
	self.state.powerup_take_time = self.state.time
end

function GameWorld:powerup_finish(powerup_id)
	--print("powerup_finish:" .. powerup_id)
	local ctx = COMMON.CONTEXT:set_context_top_game_gui()
	ctx.data:powerup_finish(powerup_id)
	ctx:remove()
end

function GameWorld:finish_run()
	if(self.world.storage.game:is_tutorial_completed())then
		self.world.storage.game:gems_add(self.world.storage.game:gems_game_get())
		self.world.storage.game:gems_game_set(0)
	end
	self.world.storage.game:highscore_set(math.floor(self.state.score))
	self:reset_state()
	self.tasks:finish_run()
	self.world.sounds:play_music(self.world.sounds.music.menu)
end

function GameWorld:restart_run()
	self:finish_run()
	local ctx = COMMON.CONTEXT:set_context_top_game()
	self.level_creator:clear_game()
	self.level_creator:create_game()
	self:set_start_delay()
	ctx:remove()
	self:start()
end

function GameWorld:set_start_delay()
	if (not self.state.lose) then
		self.state.start_timer = 3
	end
end

function GameWorld:lose_to_menu()
	if (self.state.state == ENUMS.GAME_STATE.RUN) then
		local ctx = COMMON.CONTEXT:set_context_top_game()
		self:finish_run()
		self.level_creator:clear_game()
		self.level_creator:create_game()
		ctx:remove()

		ctx = COMMON.CONTEXT:set_context_top_game_gui()
		ctx.data:game_gui_show(false)
		ctx:remove()

		ctx = COMMON.CONTEXT:set_context_top_menu_gui()
		ctx.data:animate_show()
		ctx:remove()
	end
end

function GameWorld:revive()
	if (self.state.lose) then
		self.world.sdk:gameplay_start()
		self.state.lose = false
		self.state.revive = true
		self.level_creator.player.moving = true
		self.state.start_timer = 3
		self.state.revive_time = self.state.time
		self:powerup_take(DEFS.POWERUPS.RUN.id, true)
		self:powerup_take(DEFS.POWERUPS.MAGNET.id, true)

		self.world.sounds:play_sound(self.world.sounds.sounds.revive)

		local player = self.level_creator.player
		player.tunnel_movement.speed = self.world.game.ecs_game.system_player_speed_increase:get_data(self.state.speed_level) * 0.75
		local tunnels = {}

		local ctx = COMMON.CONTEXT:set_context_top_game()
		msg.post(player.player_go.shine.rotation, COMMON.HASHES.MSG.ENABLE)
		go.cancel_animations(player.player_go.shine.sprite, "tint.w")
		go.set(player.player_go.shine.sprite, "tint.w", 0)
		go.set(player.player_go.shine.rotation, "scale", vmath.vector3(0.33))

		go.animate(player.player_go.shine.rotation, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(1), go.EASING_INCUBIC, 0.66)
		go.animate(player.player_go.shine.sprite, "tint.w", go.PLAYBACK_ONCE_FORWARD, COMMON.CONSTANTS.SHINE_PLAYER_COLOR.w, go.EASING_INQUAD, 0.5, 0, function()
			go.animate(player.player_go.shine.sprite, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INQUAD, 2, 0, function()
				msg.post(player.player_go.shine.rotation, COMMON.HASHES.MSG.DISABLE)
			end)
		end)
		ctx:remove()

		--remove objects
		tunnels[self:get_tunnel_by_distance(player.tunnel_movement.distance)] = true
		tunnels[self:get_tunnel_by_distance(player.tunnel_movement.distance + 25)] = true
		tunnels[self:get_tunnel_by_distance(player.tunnel_movement.distance - 2)] = true
		for tunnel, _ in pairs(tunnels) do
			for i = #tunnel.game_objects, 1, -1 do
				local object = tunnel.game_objects[i]
				local delta_dist = object.tunnel_dist - player.tunnel_movement.distance
				if (delta_dist < 25) then
					if object.box or object.column then
						table.remove(tunnel.game_objects, i)
						object.revive = true
						object.auto_destroy_delay_2 = 1
						self.ecs_game:add_entity(object)
					end
				end
			end
		end
		for _, e in ipairs(self.ecs_game.ecs.entities) do
			if (e.vagon) then
				local delta_dist = e.tunnel_movement.distance - player.tunnel_movement.distance
				if (delta_dist < 35) then
					e.revive = true
					e.auto_destroy_delay_2 = 1
					self.ecs_game:add_entity(e)
				end
			end
		end
	end
end

function GameWorld:start()
	if (self.state.state == ENUMS.GAME_STATE.MENU) then
		if(self.world.sdk.yagames_sdk and COMMON.html5_is_mobile())then
			self.world.sdk.yagames_sdk:sticky_banner_hide()
		end
		self.world.sdk:preload_ads()
		if(self.world.storage.game:is_tutorial_completed())then
			self.world.sounds:play_music(self.world.sounds.music.game)
		end

		self.state.state = ENUMS.GAME_STATE.RUN
		local ctx = COMMON.CONTEXT:set_context_top_game_gui()
		ctx.data:game_gui_show(true)
		ctx:remove()
		self.world.game.tasks:start_run()
		if (self.world.storage.game:is_tutorial_completed()) then
			self.world.sdk:gameplay_start()
		else
			self.state.state = ENUMS.GAME_STATE.TUTORIAL_WAIT
		end

	end
end

function GameWorld:score_get()
	return math.floor(self.state.score)
end

function GameWorld:score_mul_get()
	local stars = self.world.storage.game:stars_get()
	if (self.state.powerups[DEFS.POWERUPS.STAR.id].duration >= 0) then
		stars = stars * 2
	end
	return stars
end
return GameWorld



