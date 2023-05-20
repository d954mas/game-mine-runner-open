local COMMON = require "libs.common"

local TAG = "Sound"
---@class Sounds
local Sounds = COMMON.class("Sounds")

--gate https://www.defold.com/manuals/sound/
function Sounds:initialize()
	self.gate_time = 0.1
	self.gate_sounds = {}
	self.fade_in = {}
	self.fade_out = {}
	self.sounds = {
		gem_take = { name = "gem_take", url = msg.url("main:/sounds#gem_take"), gate_time = 0.01},
		gem_take_daily = { name = "gem_take", url = msg.url("main:/sounds#gem_take_daily"), gate_time = 0.01 },
		gem_daily_menu_success = { name = "gem_daily_menu_success", url = msg.url("main:/sounds#gem_daily_menu_success"), gate_time = 0.01 },
		gem_daily_menu_bad = { name = "gem_daily_menu_bad", url = msg.url("main:/sounds#gem_daily_menu_bad"), gate_time = 0.01 },
		powerup_run = { name = "powerup_run", url = msg.url("main:/sounds#powerup_run"), gate_time = 0.01 },
		powerup_x2 = { name = "powerup_x2", url = msg.url("main:/sounds#powerup_x2"), gate_time = 0.01 },
		powerup_magnet = { name = "powerup_magnet", url = msg.url("main:/sounds#powerup_magnet"), gate_time = 0.01 },
		player_hit_1 = { name = "player_hit_1", url = msg.url("main:/sounds#player_hit_1") },
		player_hit_2 = { name = "player_hit_2", url = msg.url("main:/sounds#player_hit_2") },
		player_hit_3 = { name = "player_hit_3", url = msg.url("main:/sounds#player_hit_3") },
		revive = { name = "revive", url = msg.url("main:/sounds#revive") },
		ui_task_completed_popup = { name = "ui_task_completed_popup", url = msg.url("main:/sounds#ui_task_completed_popup") },
		star_add = { name = "star_add", url = msg.url("main:/sounds#star_add") },
		speedup = { name = "speedup", url = msg.url("main:/sounds#speedup") },
	}
	self.music = {
		game = { name = "game", url = msg.url("main:/music#game"), fade_in = 3, fade_out = 3 },
		menu = { name = "menu", url = msg.url("main:/music#menu"), fade_in = 3, fade_out = 3 },
	}
	self.scheduler = COMMON.RX.CooperativeScheduler.create()
	self.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_CHANGED)
							  :go_distinct(self.scheduler):subscribe(function()
		self:on_storage_changed()
	end)
	self.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.WINDOW_EVENT):subscribe(function(event)
		if event.event == window.WINDOW_EVENT_FOCUS_LOST then
			self.focus = false
			sound.set_group_gain(COMMON.HASHES.hash("master"), 0)
		elseif event.event == window.WINDOW_EVENT_FOCUS_GAINED then
			self.focus = true
			if (not self.paused) then
				sound.set_group_gain(COMMON.HASHES.hash("master"), 1)
			end
		end
	end)

	self.paused = false
	self.focus = true

	self.master_gain = 1
	---@type World
	self.world = nil
	self.current_music = nil
end

function Sounds:on_storage_changed()
	sound.set_group_gain(COMMON.HASHES.hash("sound"), self.world.storage.options:sound_get() and 1 or 0)
	sound.set_group_gain(COMMON.HASHES.hash("music"), self.world.storage.options:music_get() and 1 or 0)
end

function Sounds:pause()
	COMMON.i("pause", TAG)
	self.master_gain = sound.get_group_gain(COMMON.HASHES.hash("master"))
	self.paused = true
	sound.set_group_gain(COMMON.HASHES.hash("master"), 0)
end

function Sounds:resume()
	COMMON.i("resume", TAG)
	self.paused = false
	if (self.focus) then
		sound.set_group_gain(COMMON.HASHES.hash("master"), 1)
	end
end

function Sounds:update(dt)
	self.scheduler:update(dt)
	for k, v in pairs(self.gate_sounds) do
		self.gate_sounds[k] = v - dt
		if self.gate_sounds[k] < 0 then
			self.gate_sounds[k] = nil
		end
	end
	for k, v in pairs(self.fade_in) do
		local a = 1 - v.time / v.music.fade_in
		a = COMMON.LUME.clamp(a, 0, 1)
		sound.set_gain(v.music.url, a)
		v.time = v.time - dt
		--        print("Fade in:" .. a)
		if (a == 1) then
			self.fade_in[k] = nil
		end
	end

	for k, v in pairs(self.fade_out) do
		local a = v.time / v.music.fade_in
		a = COMMON.LUME.clamp(a, 0, 1)
		sound.set_gain(v.music.url, a)
		v.time = v.time - dt
		--      print("Fade out:" .. a)
		if (a == 0) then
			self.fade_out[k] = nil
			sound.stop(v.url)
		end
	end
end

function Sounds:play_sound(sound_obj, config)
	assert(sound_obj)
	assert(type(sound_obj) == "table")
	assert(sound_obj.url)
	config = config or {}

	if not self.gate_sounds[sound_obj] or sound_obj.no_gate then
		self.gate_sounds[sound_obj] = sound_obj.gate_time or self.gate_time
		sound.play(sound_obj.url, nil, config.on_complete)
		COMMON.i("play sound:" .. sound_obj.name, TAG)
	else
		COMMON.i("gated sound:" .. sound_obj.name .. "time:" .. self.gate_sounds[sound_obj], TAG)
	end
end
function Sounds:play_music(music_obj)
	assert(music_obj)
	assert(type(music_obj) == "table")
	assert(music_obj.url)

	if (self.current_music) then
		if (self.current_music.fade_out) then
			self.fade_out[self.current_music] = { music = self.current_music, time = self.current_music.fade_out }
			self.fade_in[self.current_music] = nil
		else
			sound.stop(self.current_music.url)
		end
	end
	sound.stop(music_obj.url)
	sound.play(music_obj.url)

	if (music_obj.fade_in) then
		sound.set_gain(music_obj.url, 0)
		self.fade_in[music_obj] = { music = music_obj, time = music_obj.fade_in }
		self.fade_out[music_obj] = nil
	end
	self.current_music = music_obj

	COMMON.i("play music:" .. music_obj.name, TAG)
end


--pressed M to enable/disable
function Sounds:toggle()
	local music = self.world.storage.options:music_get()
	if (music) then
		-- music priority
		self.world.storage.options:music_set(false)
		self.world.storage.options:sound_set(false)
	else
		self.world.storage.options:music_set(true)
		self.world.storage.options:sound_set(true)
	end
end

function Sounds:player_hit()
	self:play_sound(self.sounds["player_hit_" .. math.random(1,3)])
end

function Sounds:player_destroy_object()
	self:play_sound(self.sounds["player_hit_" .. math.random(1,3)])
end


return Sounds()