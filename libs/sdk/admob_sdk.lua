local COMMON = require "libs.common"

local TAG = "ADMOB_SDK"

local Sdk = COMMON.class("AdmobSdk")

---@param world World
---@param sdk Sdks
function Sdk:initialize(world, sdk)
	self.world = assert(world)
	self.callback = nil
	self.context = nil
	self.platform_sdk = assert(sdk)
	self.subscription = COMMON.RX.SubscriptionsStorage()
	self.initialized = false
	self.interstitial = {
		exist = false,
		loading = false
	}
	self.rewarded = {
		exist = false,
		loading = false
	}
	self.config = {
		interstitial_prev = socket.gettime(),
		interstitial_delay = 180--3min
	}
end

function Sdk:interstitial_remove()
	if (self.interstitial.exist) then
		self.interstitial.exist = false
		self.interstitial.loading = false
		self:interstitial_load()
	end
end

function Sdk:interstitial_load()
	if (not self.interstitial.exist and not self.interstitial.loading) then
		admob.load_interstitial(self.ads.interstitial)
		self.interstitial.loading = true
	end
end

function Sdk:rewarded_remove()
	if (self.rewarded.exist) then
		self.rewarded.exist = false
		self.rewarded.loading = false
		self:rewarded_load()
	end
end

function Sdk:rewarded_load()
	if (not self.rewarded.exist and not self.rewarded.loading) then
		admob.load_rewarded(self.ads.rewarded)
		self.rewarded.loading = true
	end
end

function Sdk:on_message(_go, message_id, message)
	if message_id == admob.MSG_INITIALIZATION then
		if message.event == admob.EVENT_COMPLETE then
			print("EVENT_COMPLETE: Initialization complete")
			self.initialized = true
			self:rewarded_load()
			self:interstitial_load()
		elseif message.event == admob.EVENT_JSON_ERROR then
			print("EVENT_JSON_ERROR: Internal NE json error " .. message.error)
		end
	elseif message_id == admob.MSG_IDFA then
		if message.event == admob.EVENT_STATUS_AUTORIZED then
			print("EVENT_STATUS_AUTORIZED: ATTrackingManagerAuthorizationStatusAuthorized")
		elseif message.event == admob.EVENT_STATUS_DENIED then
			print("EVENT_STATUS_DENIED: ATTrackingManagerAuthorizationStatusDenied")
		elseif message.event == admob.EVENT_STATUS_NOT_DETERMINED then
			print("EVENT_STATUS_NOT_DETERMINED: ATTrackingManagerAuthorizationStatusNotDetermined")
		elseif message.event == admob.EVENT_STATUS_RESTRICTED then
			print("EVENT_STATUS_RESTRICTED: ATTrackingManagerAuthorizationStatusRestricted")
		elseif message.event == admob.EVENT_NOT_SUPPORTED then
			print("EVENT_NOT_SUPPORTED: IDFA request not supported on this platform or OS version")

		end
	elseif message_id == admob.MSG_INTERSTITIAL then
		if message.event == admob.EVENT_CLOSED then
			print("EVENT_CLOSED: Interstitial AD closed")
			self:interstitial_remove()
			self:resume()
			self:callback_execute()
		elseif message.event == admob.EVENT_FAILED_TO_SHOW then
			print("EVENT_FAILED_TO_SHOW: Interstitial AD failed to show\nCode: " .. message.code .. "\nError: " .. message.error)
			self:interstitial_remove()
			self:callback_execute()
		elseif message.event == admob.EVENT_OPENING then
			self.config.interstitial_prev = socket.gettime()
			-- on android this event fire only when ADS activity closed =(
			print("EVENT_OPENING: Interstitial AD is opening")
			self:interstitial_remove()
			self:pause()
			--   self:callback_execute()
		elseif message.event == admob.EVENT_FAILED_TO_LOAD then
			print("EVENT_FAILED_TO_LOAD: Interstitial AD failed to load\nCode: " .. message.code .. "\nError: " .. message.error)
			self.interstitial.loading = false
		elseif message.event == admob.EVENT_LOADED then
			self.interstitial.loading = false
			self.interstitial.exist = true
			print("EVENT_LOADED: Interstitial AD loaded")
		elseif message.event == admob.EVENT_NOT_LOADED then
			print("EVENT_NOT_LOADED: can't call show_interstitial() before EVENT_LOADED\nError: " .. message.error)
			self:interstitial_remove()
			self:callback_execute()
		elseif message.event == admob.EVENT_IMPRESSION_RECORDED then
			-- self:callback_execute()
			print("EVENT_IMPRESSION_RECORDED: Interstitial did record impression")
		elseif message.event == admob.EVENT_JSON_ERROR then
			-- self:callback_execute()
			print("EVENT_JSON_ERROR: Internal NE json error: " .. message.error)
		end
	elseif message_id == admob.MSG_REWARDED then
		if message.event == admob.EVENT_CLOSED then
			print("EVENT_CLOSED: Rewarded AD closed")
			self:rewarded_remove()
			self:resume()
			self:callback_execute(false, message)
		elseif message.event == admob.EVENT_FAILED_TO_SHOW then
			print("EVENT_FAILED_TO_SHOW: Rewarded AD failed to show\nCode: " .. message.code .. "\nError: " .. message.error)
			android_toast.toast("Rewarded AD failed to show",1)
			self:rewarded_remove()
			self:resume()
			self:callback_execute(false, message)
		elseif message.event == admob.EVENT_OPENING then
			-- on android this event fire only when ADS activity closed =(
			print("EVENT_OPENING: Rewarded AD is opening")
			self:rewarded_remove()
			--self:pause()
			-- self:callback_execute(true)
		elseif message.event == admob.EVENT_FAILED_TO_LOAD then
			self.rewarded.loading = false
			print("EVENT_FAILED_TO_LOAD: Rewarded AD failed to load\nCode: " .. message.code .. "\nError: " .. message.error)
		elseif message.event == admob.EVENT_LOADED then
			self.rewarded.loading = false
			self.rewarded.exist = true
			print("EVENT_LOADED: Rewarded AD loaded")
		elseif message.event == admob.EVENT_NOT_LOADED then
			print("EVENT_NOT_LOADED: can't call show_rewarded() before EVENT_LOADED\nError: " .. message.error)
			self:rewarded_remove()
			self:resume()
			self:callback_execute(false, message)
		elseif message.event == admob.EVENT_EARNED_REWARD then
			print("EVENT_EARNED_REWARD: Reward: " .. tostring(message.amount) .. " " .. tostring(message.type))
			self:rewarded_remove()
			self:resume()
			self:callback_execute(true, message)
		elseif message.event == admob.EVENT_IMPRESSION_RECORDED then
			print("EVENT_IMPRESSION_RECORDED: Rewarded did record impression")
		elseif message.event == admob.EVENT_JSON_ERROR then
			print("EVENT_JSON_ERROR: Internal NE json error: " .. message.error)
		end
	elseif message_id == admob.MSG_BANNER then
		if message.event == admob.EVENT_LOADED then
			print("EVENT_LOADED: Banner AD loaded. Height: " .. message.height .. "px Width: " .. message.width .. "px")
		elseif message.event == admob.EVENT_OPENING then
			print("EVENT_OPENING: Banner AD is opening")
		elseif message.event == admob.EVENT_FAILED_TO_LOAD then
			print("EVENT_FAILED_TO_LOAD: Banner AD failed to load\nCode: " .. message.code .. "\nError: " .. message.error)
		elseif message.event == admob.EVENT_CLICKED then
			print("EVENT_CLICKED: Banner AD loaded")
		elseif message.event == admob.EVENT_CLOSED then
			print("EVENT_CLOSED: Banner AD closed")
		elseif message.event == admob.EVENT_DESTROYED then
			print("EVENT_DESTROYED: Banner AD destroyed")
		elseif message.event == admob.EVENT_IMPRESSION_RECORDED then
			print("EVENT_IMPRESSION_RECORDED: Banner did record impression")
		elseif message.event == admob.EVENT_JSON_ERROR then
			print("EVENT_JSON_ERROR: Internal NE json error: " .. message.error)
		end
	end
end

function Sdk:callback_save(cb)
	assert(not self.callback)
	self.callback = cb
	self.context = lua_script_instance.Get()
end

function Sdk:callback_execute(...)
	if (self.callback) then
		local ctx_id = COMMON.CONTEXT:set_context_top_by_instance(self.context)
		self.callback(...)
		COMMON.CONTEXT:remove_context_top(ctx_id)
		self.context = nil
		self.callback = nil
	else
		COMMON.w("no callback to execute", TAG)
	end
end

function Sdk:pause()
	COMMON.INPUT.IGNORE = true
	self.pause_time = socket.gettime()
end
function Sdk:resume()
	COMMON.INPUT.IGNORE = false
	self.pause_time = nil
end

function Sdk:init()
	assert(admob)
	COMMON.i("admob init ", TAG)
	self.ads = COMMON.CONSTANTS.VERSION_IS_RELEASE and COMMON.CONSTANTS.ADMOB.BASE or COMMON.CONSTANTS.ADMOB.TEST
	-- !!! Set callback before initialization
	admob.set_callback(function(...)
		self:on_message(...)
	end)
	-- !!! Read documentation about privacy settings and use the following method if you need to apply it
	-- https://developers.google.com/admob/ios/ccpa
	-- https://developers.google.com/admob/android/ccpa
	admob.set_privacy_settings(true)
	admob.initialize()
end

function Sdk:show_interstitial_ad(cb)
	COMMON.i("interstitial_ad show", TAG)
	if (not self.initialized) then
		COMMON.w("can't show ads. Not initialized")
		cb(false)
		return
	end
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		if (socket.gettime()- self.config.interstitial_prev > self.config.interstitial_delay) then
			if (self.interstitial.exist) then
				self:callback_save(cb)
				admob.show_interstitial()
			else
				cb(true)
			end
		else
			print("skip interstitial:" .. (socket.gettime() - self.config.interstitial_prev))
			cb(true)
		end

	end

end

function Sdk:show_rewarded_ad(cb)
	COMMON.i("rewarded_ad show", TAG)
	if (not self.initialized) then
		COMMON.w("can't show ads. Not initialized")
		if (cb) then cb(false, "not inited") end
		return
	end
	if (self.callback) then
		COMMON.w("can't show already have callback")
		if (cb) then cb(false, "callback exist") end
		return
	else
		if (self.rewarded.exist) then
			self:pause()
			self:callback_save(cb)
			admob.show_rewarded()
		else
			self:rewarded_load()
			cb(false)
			android_toast.toast("Rewarded AD not loaded.Please, try later",1)

		end

	end

end

return Sdk