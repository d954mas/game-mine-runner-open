local COMMON = require "libs.common"
local VK = require "libs.vkminibridge.vkminibridge"

local TAG = "VK_SDK"
local INTERSTITIAL_DELAY = 180

local Sdk = COMMON.class("vk")

---@param world World
---@param sdks Sdks
function Sdk:initialize(world, sdks)
	self.world = assert(world)
	self.callback = nil
	self.context = nil
	self.subscription = COMMON.RX.SubscriptionsStorage()
	self.subscription:add(COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.JSTODEF):subscribe(function(event)
		self:on_event(event)
	end))
	self.interstitial_ad_delay = socket.gettime() + INTERSTITIAL_DELAY
	self.sdks = assert(sdks)
end

function Sdk:on_event(event)
	local message_id = event.message_id
	--local message = event.message
	print("ADS EVENT. message_id:" .. message_id)
	pprint(event)
	if (message_id == "AdsResult") then
		self:callback_execute(event.message.success)
		self.sdks:__ads_stop()
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
	else
		COMMON.w("no callback to execute", TAG)
	end
end

function Sdk:init(cb)
	COMMON.i("vk games init start", TAG)
	VK.init(nil, function()
		COMMON.i("vk games init", TAG)
		-- Sends event to client
		VK.send('VKWebAppInit', {})
		if (cb) then cb() end
	end)
end

function Sdk:show_interstitial_ad(cb)
	COMMON.i("interstitial_ad show vk", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		if (VK.is_initialized) then
			if (VK.supports("VKWebAppShowNativeAds")) then
				if (self.interstitial_ad_delay - socket.gettime() <= 0) then
					self.sdks:__ads_start()
					self:callback_save(cb)
					VK.interstitial_native()
					self.interstitial_ad_delay = socket.gettime()
				else
					print("skip interstitial:" .. (self.interstitial_ad_delay - socket.gettime()))
					if (cb) then cb(true) end
				end

			else
				COMMON.w("not supported")
				if (cb) then cb(false, "not supported") end
			end
		else
			if (cb) then cb(false, "not inited") end
		end

	end
end

function Sdk:show_rewarded_ad(cb)
	COMMON.i("interstitial_ad show vk", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		if (VK.is_initialized) then
			if (VK.supports("VKWebAppShowNativeAds")) then
				self.sdks:__ads_start()
				self:callback_save(cb)
				VK.reward_native()
			else
				COMMON.w("not supported")
				if (cb) then cb(false, "not supported") end
			end
		else
			if (cb) then cb(false, "not inited") end
		end

	end
end

function Sdk:share(params)
	VK.send("VKWebAppShowWallPostBox", params)
end
return Sdk