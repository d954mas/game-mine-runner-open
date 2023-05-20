local COMMON = require "libs.common"
local YA = require "libs.yagames.yagames"
local CRYPTO = require "libs.crypto"
local BASE64 = require "libs.base64"
local ACTIONS = require "libs.actions.actions"
local DEFS = require "world.balance.def.defs"

local TAG = "YAGAMES_SDK"

local Sdk = COMMON.class("YAGAMES_SDK")

---@param world World
---@param sdks Sdks
function Sdk:initialize(world, sdks)
	self.world = assert(world)
	self.sdks = assert(sdks)
	self.callback = nil
	self.context = nil
	self.is_initialized = false
	self.ya = YA
	---@type string|nil
	self.ya_storage_data = nil
	self.leaderboard_send_queue = ACTIONS.Sequence()
	self.leaderboard_send_queue.drop_empty = false
	self.subscription = COMMON.RX.SubscriptionsStorage()
	self.scheduler = COMMON.RX.CooperativeScheduler.create()

	self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STAR_ADD)
								:go_distinct(self.scheduler):subscribe(
			function()
				self:leaderboard_send_stars()
			end))
	self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.NEW_HIGHSCORE)
								:go(self.scheduler):subscribe(
			function(event)
				self:leaderboard_send_world_highscore(event.world_id)
			end
	))
end

function Sdk:update(dt)
	self.leaderboard_send_queue:update(dt)
	self.scheduler:update(dt)
end

function Sdk:callback_save(cb)
	assert(not self.callback)
	self.callback = cb
	self.context = lua_script_instance.Get()
end

function Sdk:callback_execute(success)
	if (self.callback) then
		local ctx_id = COMMON.CONTEXT:set_context_top_by_instance(self.context)
		self.callback(success)
		COMMON.CONTEXT:remove_context_top(ctx_id)
		self.context = nil
		self.callback = nil

		if (html5) then
			html_utils.focus()
		end
	else
		COMMON.w("no callback to execute", TAG)
	end
end

function Sdk:init(cb)
	assert(yagames_private)
	YA.init(function(...)
		self.is_initialized = true
		--localization
		local locale = YA.environment().i18n.lang
		COMMON.LOCALIZATION:set_locale(locale)
		cb(...)
	end)
end

function Sdk:show_interstitial_ad(cb)
	COMMON.i("interstitial_ad show", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		if (self.is_initialized) then
			self:callback_save(cb)
			YA.adv_show_fullscreen_adv({
				open = function()
					self.sdks:__ads_start()
				end,
				close = function(wasShown)
					self.sdks:__ads_stop()
					self:callback_execute(wasShown)
				end,
				error = function()
					--self.sdks:__ads_stop()
					--self:callback_execute(false)
				end,
				offline = function()
					--self.sdks:__ads_stop()
					--self:callback_execute(false)
				end })
		else
			if (cb) then cb(false, "not inited") end
		end

	end
end

function Sdk:sticky_banner_hide()
	self.ya.adv_get_banner_adv_status(function(_, error, status)
		if (status.stickyAdvIsShowing) then
			self.ya.adv_hide_banner_adv()
		end

	end)
end

function Sdk:sticky_banner_show()
	self.ya.adv_get_banner_adv_status(function(_, error, status)
		if (not status.stickyAdvIsShowing) then
			self.ya.adv_show_banner_adv()
		end
	end)
end

function Sdk:show_rewarded_ad(cb)
	COMMON.i("interstitial_ad show", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		if (self.is_initialized) then
			self:callback_save(cb)
			local rewarded = false
			YA.adv_show_rewarded_video({
				open = function()
					self.sdks:__ads_start()
				end
			, rewarded = function()
					rewarded = true
				end, close = function()
					self.sdks:__ads_stop()
					self:callback_execute(rewarded)
				end, error = function()
					self.sdks:__ads_stop()
					self:callback_execute(false)
				end })
		else
			if (cb) then cb(false, "not inited") end
		end

	end
end

function Sdk:ya_save_storage()
	if (YA.player_ready) then
		print("YA SAVE DATA")
		local data = json.encode(self.world.storage.data)
		if (self.ya_storage_data ~= data) then
			print("YA UPDATE DATA")
			local send_data = {
				data = BASE64.encode(CRYPTO.crypt(data, COMMON.CONSTANTS.CRYPTO_KEY)),
				encrypted = true
			}
			YA.player_set_data({ storage = send_data }, true, function()

			end)
		else
			print("YA storage not changed")
		end

	end
end

function Sdk:ya_load_storage(cb)
	YA.player_get_data({ "storage" }, function(_, err, result)
		print("GET STORAGE")
		pprint(result)
		if (not err) then
			local stars = self.world.storage.game:stars_get()
			if (not result.storage) then
				cb()
				return
			end

			---@type StorageData
			local ya_storage_data = result.storage
			local success = true

			if (ya_storage_data.data) then
				if (ya_storage_data.encrypted) then
					ya_storage_data = BASE64.decode(ya_storage_data.data)
					ya_storage_data = CRYPTO.crypt(ya_storage_data, COMMON.CONSTANTS.CRYPTO_KEY)
				else
					ya_storage_data = ya_storage_data.data
				end
			else
				print("bad ya storage")
				cb()
				return
			end

			success, ya_storage_data = pcall(json.decode, ya_storage_data)
			if (not success) then
				print("can't decode ya storage")
				cb()
				return
			end

			local ya_stars = ya_storage_data.game.stars
			local ya_time = ya_storage_data.time or 0

			print(string.format("local stars:%d ", stars))
			print(string.format("ya.stars:%d ", ya_stars))

			if (ya_stars > stars) then
				print("rewrite storage.More stars.Use ya.")
				--keep current world id(fixed error when world_id is different)
				local current_world = self.world.storage.data.game.world_id
				self.world.storage.data = ya_storage_data
				self.world.storage.data.game.world_id = current_world
				self.world.storage:update_data()
				self.world.storage:save()
			elseif(ya_stars == stars and ya_time > self.world.storage.data.time)then
				print("rewrite storage.Time bigger. Use ya.")
				--keep current world id(fixed error when world_id is different)
				local current_world = self.world.storage.data.game.world_id
				self.world.storage.data = ya_storage_data
				self.world.storage.data.game.world_id = current_world
				self.world.storage:update_data()
				self.world.storage:save()
			end

			self.ya_storage_data = json.encode(self.world.storage.data)
		end
		COMMON.EVENT_BUS:event(COMMON.EVENTS.STORAGE_CHANGED)
		cb()
	end)
end

function Sdk:login_player()
	print("player init")
	YA.player_init({ scopes = true }, function(_, err)
		if (err) then
			print("login_player ERROR:" .. tostring(err))
		end
		if (err == "FetchError: Unauthorized" or (YA.player_ready and YA.player_get_mode() == "lite")) then
			print("auth dialog")
			YA.auth_open_auth_dialog(function(_, err)
				print("auth dialog show")
				if (not err) then
					self:login_player()
				else
					print("auth dialog error:" .. tostring(err))
				end
			end)
		elseif (not err) then
			--load storage
			self:ya_load_storage(function()
				self:leaderboard_load_world_highscore(self.world.storage.game:world_id_get())
			end)
		end
	end)
end

function Sdk:leaderboard_send_data(leaderboard_name, score, extra_data, cb)
	print("leaderboard_send_data")
	if (YA.leaderboards_ready) then
		print("leaderboard ready set score")
		YA.leaderboards_set_score(leaderboard_name, score, extra_data, cb)
	else
		YA.leaderboards_init(function(_, err)
			if (not err) then
				print("leaderboard init")
				YA.leaderboards_set_score(leaderboard_name, score, extra_data, cb)
			else
				print(err)
				cb(_, "error", { error = err })
			end
		end)
	end
end

function Sdk:leaderboard_send_stars()
	self.leaderboard_send_queue:add_action(function()
		print("leaderboard send stars")
		local stars = self.world.storage.game:stars_get()
		local delay = 5
		self:leaderboard_send_data("stars", stars, nil,
				function()
					delay = 1
				end)
		while (delay > 0) do delay = delay - coroutine.yield() end
	end)
end

function Sdk:leaderboard_init_send()
	self:leaderboard_send_stars()
	for _, world in ipairs(DEFS.WORLDS.WORLD_LIST) do
		self:leaderboard_send_world_highscore(world.id)
	end
end

function Sdk:leaderboard_send_world_highscore(world_id)
	local def = assert(DEFS.WORLDS.WORLDS_BY_ID[world_id])
	local score = self.world.storage.game:highscore_get(def.id)
	if (score ~= 0) then
		self.leaderboard_send_queue:add_action(function()
			local delay = 5
			self:leaderboard_send_data(def.ya_leaderboard, score, nil,
					function()
						print("leaderboard send world:" .. world_id)
						delay = 1
					end)
			while (delay > 0) do delay = delay - coroutine.yield() end
		end)
	end

end

function Sdk:__leaderboard_load_world_highscore(world_id, cb)
	local def = assert(DEFS.WORLDS.WORLDS_BY_ID[world_id])
	YA.leaderboards_get_entries(def.ya_leaderboard, { getAvatarSrc = "small", quantityTop = 10, includeUser = true }, function(_, err, result)
		if (err) then
			cb(false)
		else
			cb(true, result)
		end
	end)
end

function Sdk:leaderboard_load_world_highscore(world_id, cb)
	local def = assert(DEFS.WORLDS.WORLDS_BY_ID[world_id])
	if (not YA.player_ready) then
		cb(false)
		return
	end
	if (not YA.leaderboards_ready) then
		YA.leaderboards_init(function(_, err)
			if (not err) then
				self:__leaderboard_load_world_highscore(world_id, cb)
			else
				print(err)
				cb(false)
			end
		end)
		return
	end
	self:__leaderboard_load_world_highscore(world_id, cb)

end

return Sdk