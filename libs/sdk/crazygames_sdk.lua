local COMMON = require "libs.common"

local TAG = "CRAZYGAMES_SDK"

local Sdk = COMMON.class("CrazyGamesSdk")

---@param world World
---@param sdks Sdks
function Sdk:initialize(world, sdks)
	self.world = assert(world)
	self.sdks = assert(sdks)
	self.callback = nil
	self.context = nil
	self.prev_mid_add = 0
	self.subscription = COMMON.RX.SubscriptionsStorage()
	self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.JSTODEF):subscribe(function(event)
		self:on_event(event)
	end))
end

function Sdk:on_event(event)
	local message_id = event.message_id
	--local message = event.message
	print(message_id)
	if (COMMON.LUME.string_start_with(message_id, "CrazyGame")) then
		if (message_id == "CrazyGame_adStared") then
			self.sdks:__ads_start()
		elseif (message_id == "CrazyGame_adFinished") then
			self.sdks:__ads_stop()
			self:callback_execute(true)
		elseif (message_id == "CrazyGame_adError") then
			self.sdks:__ads_stop()
			self:callback_execute(false)
		end
	end
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

function Sdk:init()
	COMMON.i("games init start", TAG)
	crazy_games.init()

	crazy_games.init_listeners()
	crazy_games.add_event_listeners()
	self.is_initialized = true
	self.gameplay_started = false
end

function Sdk:gameplay_start()
	if (not self.gameplay_started) then
		self.gameplay_started = true
		crazy_games.gameplay_start()
	end
end

function Sdk:gameplay_stop()
	if (self.gameplay_started) then
		self.gameplay_started = false
		crazy_games.gameplay_stop()
	end
end

function Sdk:happy_time(value)
	if(value == 1)then
		crazy_games.happy_time()
	end
end

function Sdk:show_interstitial_ad(cb)
	COMMON.i("interstitial_ad show", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		if (self.is_initialized) then
			self:callback_save(cb)
			crazy_games.request_ad("midgame")
		else
			if (cb) then cb(false, "not inited") end
		end

	end
end

function Sdk:show_rewarded_ad(cb)
	COMMON.i("interstitial_ad show", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		if (self.is_initialized) then
			self:callback_save(cb)
			crazy_games.request_ad("rewarded")
		else
			if (cb) then cb(false, "not inited") end
		end

	end
end
return Sdk