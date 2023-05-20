local COMMON = require "libs.common"
local INPUT = require "libs.input_receiver"
local ENUMS = require "world.enums.enums"
local AdmobSdk = require "libs.sdk.admob_sdk"
local CrazyGamesSdk = require "libs.sdk.crazygames_sdk"
local YaGamesSdk = require "libs.sdk.yagames_sdk"
local GameDistirbutionSdk = require "libs.sdk.gamedistribution_sdk"
local VKSdk = require "libs.sdk.vk_sdk"
local SCENE_ENUMS = require "libs.sm.enums"
local TAG = "SDK"

---@class Sdks
local Sdk = COMMON.class("Sdk")

---@param world World
function Sdk:initialize(world)
	checks("?", "class:World")
	self.world = world
	self.is_yandex = COMMON.CONSTANTS.TARGET_IS_YANDEX_GAMES or yagames_private
	self.is_poki = COMMON.CONSTANTS.TARGET_IS_POKI or poki_sdk
	self.is_crazygames = COMMON.CONSTANTS.TARGET_IS_CRAZY_GAMES or crazygames_sdk
	self.is_playmarket = COMMON.CONSTANTS.TARGET_IS_PLAY_MARKET or admob
	self.is_game_distribution = COMMON.CONSTANTS.TARGET_IS_GAME_DISTRIBUTION or gdsdk
	self.is_vk = COMMON.CONSTANTS.TARGET_IS_VK_GAMES
	self.poki = {
		gameplay_start = false
	}
end

function Sdk:init(cb)
	if (self.is_playmarket) then
		self.admob = AdmobSdk(self.world, self)
		self.admob:init()
		self.current_sdk = self.admob
		cb()
	elseif (self.is_crazygames) then
		self.crazygames = CrazyGamesSdk(self.world, self)
		self.crazygames:init()
		self.current_sdk = self.crazygames
		cb()
	elseif (self.is_yandex) then
		self.yagames_sdk = YaGamesSdk(self.world, self)
		self.yagames_sdk:init(cb)
		self.current_sdk = self.yagames_sdk
	elseif (self.is_game_distribution) then
		self.gamedistribution_sdk = GameDistirbutionSdk(self.world, self)
		self.gamedistribution_sdk:init()
		self.current_sdk = self.gamedistribution_sdk
		cb()
	elseif (self.is_vk) then
		self.vk_sdk = VKSdk(self.world, self)
		self.vk_sdk:init(cb)
		self.current_sdk = self.vk_sdk
	else
		cb()
	end
end

function Sdk:update(dt)
	if (self.current_sdk and self.current_sdk.update) then
		self.current_sdk:update(dt)
	end
end

function Sdk:gameplay_start()
	print("gameplay_start")
	if (COMMON.CONSTANTS.TARGET_IS_POKI) then
		if (not self.poki.gameplay_start) then
			poki_sdk.gameplay_start()
			self.poki.gameplay_start = true
		end
	elseif (self.current_sdk and self.current_sdk.gameplay_start) then
		self.current_sdk:gameplay_start()
	end
end

function Sdk:gameplay_stop()
	print("gameplay_stop")
	if (COMMON.CONSTANTS.TARGET_IS_POKI) then
		if (self.poki.gameplay_start) then
			poki_sdk.gameplay_stop()
			self.poki.gameplay_start = false
		end
	elseif (self.current_sdk and self.current_sdk.gameplay_stop) then
		self.current_sdk:gameplay_stop()
	end
end

function Sdk:__ads_start()
	self.world.sounds:pause()
	INPUT.IGNORE = true
	local SM = reqf "libs_project.sm"
	local scene = SM:get_top()
	if (scene and scene._state == SCENE_ENUMS.STATES.RUNNING) then
		scene:pause()
	end
end

function Sdk:__ads_stop()
	self.world.sounds:resume()
	INPUT.IGNORE = false
	local SM = reqf "libs_project.sm"
	local scene = SM:get_top()
	if (scene and scene._state == SCENE_ENUMS.STATES.PAUSED) then
		scene:resume()
	end
end

function Sdk:ads_rewarded(cb)
	print("ads_rewarded")
	if (COMMON.CONSTANTS.TARGET_IS_POKI) then
		self:__ads_start()
		poki_sdk.rewarded_break(function(_, success)
			print("ads_rewarded success:" .. tostring(success))
			self:__ads_stop()
			if (cb) then cb(success) end
		end)
	elseif (self.current_sdk and self.current_sdk.show_rewarded_ad) then
		self.current_sdk:show_rewarded_ad(cb)
	else
		if (cb) then
			cb(true) end
	end
end

function Sdk:preload_ads()
	if (self.is_playmarket) then
		self.admob:rewarded_load()
	end
end

function Sdk:ads_commercial(cb)
	print("ads_commercial")
	if (COMMON.CONSTANTS.TARGET_IS_POKI) then
		self:__ads_start()
		poki_sdk.commercial_break(function(_)
			self:__ads_stop()
			if (cb) then cb() end
		end)
	elseif (self.current_sdk and self.current_sdk.show_interstitial_ad) then
		self.current_sdk:show_interstitial_ad(cb)
	else
		if (cb) then cb() end
	end
end

function Sdk:happy_time(value)
	checks("?", "number")
	--print("happy_time:" .. tostring(value))
	if (self.current_sdk and self.current_sdk.happy_time) then
		self.current_sdk:happy_time(value)
	end
end

return Sdk
