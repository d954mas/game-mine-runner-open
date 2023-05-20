local COMMON = require "libs.common"

local TAG = "GameDistributionSdk"

local Sdk = COMMON.class("GameDistributionSdk")

---@param world World
---@param sdks Sdks
function Sdk:initialize(world, sdks)
	self.world = assert(world)
	self.sdks = assert(sdks)
	self.callback = nil
	self.context = nil
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

function Sdk:init()
	COMMON.i("games init start", TAG)
	COMMON.i("init gdsdk", TAG)
	gdsdk.set_listener(function(_, event, message)
		COMMON.i("event:" .. tostring(event), TAG)
		if event == gdsdk.SDK_GAME_PAUSE then
			self.sdks:__ads_start()
		elseif event == gdsdk.SDK_GAME_START then
			if (self.callback) then
				self:callback_execute(not self.rewarded)
			end
			self.sdks:__ads_stop()
		elseif event == gdsdk.SDK_REWARDED_WATCH_COMPLETE then
			if (self.callback) then
				self:callback_execute(true)
			end
		end
	end)

end

function Sdk:gameplay_start()

end

function Sdk:gameplay_stop()

end

function Sdk:happy_time()

end

function Sdk:show_interstitial_ad(cb)
	COMMON.i("interstitial_ad show", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		self.rewarded = false
		self:callback_save(cb)
		gdsdk.show_interstitial_ad()
	end
end

function Sdk:show_rewarded_ad(cb)
	COMMON.i("rewarded_ad show", TAG)
	if (self.callback) then
		COMMON.w("can't show already have callback")
		return
	else
		self.rewarded = true
		self:callback_save(cb)
		gdsdk.show_rewarded_ad()
	end
end
return Sdk