local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local ENUMS = require "world.enums.enums"

local StoragePart = require "world.storage.storage_part_base"

---@class GamePartOptions:StoragePartBase
local Storage = COMMON.class("GamePartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.game = self.storage.data.game
end

function Storage:gems_add(gems, type)
	type = type or ENUMS.GEMS_ADD_TYPE.UNKNOWN
	assert(gems >= 0)
	self.game.gems = self.game.gems + gems
	self:save_and_changed()
	self.world.game.tasks:add_gems(gems)
	COMMON.EVENT_BUS:event(COMMON.EVENTS.GEMS_ADD, { gems = gems, type = type })
end

function Storage:gems_spend(gems, type)
	type = type or ENUMS.GEMS_SPEND_TYPE.UNKNOWN
	assert(gems >= 0)
	assert(gems <= self.game.gems)
	self.game.gems = self.game.gems - gems
	self:save_and_changed()
	COMMON.EVENT_BUS:event(COMMON.EVENTS.GEMS_SPEND, { gems = gems, type = type })
end

function Storage:gems_get()
	return self.game.gems
end

function Storage:gems_game_set(gems)
	self.game.gems_game = assert(gems)
	self:save()
end

function Storage:gems_game_get()
	return self.game.gems_game
end

function Storage:stars_get()
	return self.game.stars
end

function Storage:stars_add(stars, type)
	type = type or ENUMS.GEMS_SPEND_TYPE.UNKNOWN
	self.game.stars = self.game.stars + stars
	self:save_and_changed()
	COMMON.EVENT_BUS:event(COMMON.EVENTS.STAR_ADD, { gems = stars, type = type })
end

function Storage:highscore_get(world_id)
	world_id = world_id or self:world_id_get()
	return self.game.highscore[world_id]
end

function Storage:highscore_set(highscore)
	local score = self:highscore_get()
	if (highscore > score) then
		local world_id = self:world_id_get()
		self.game.highscore[world_id] = highscore
		COMMON.EVENT_BUS:event(COMMON.EVENTS.NEW_HIGHSCORE, { world_id = world_id, highscore = highscore })
		self:save_and_changed()
	end
end

function Storage:gems_daily_is_have(type)
	local data = assert(self.game.gems_daily[tostring(type)])
	return data.have
end

function Storage:gems_daily_take(type)
	local data = assert(self.game.gems_daily[tostring(type)])
	data.have = true
	COMMON.EVENT_BUS:event(COMMON.EVENTS.DAILY_GEM_COLLECT, { type = type })
	self:save_and_changed()
end

--local DAY_TIME = 60 * 60 * 24
function Storage:gems_daily_can_collect()
	--local time = math.floor(self.game.gems_daily.last_time / DAY_TIME)
	--local time_current = math.floor(os.time() / DAY_TIME)

	--same day need wait
	--if (time == time_current) then
	--return false, (time_current + 1) * DAY_TIME
	--end
	return true
end

function Storage:gems_daily_get_reward()
	local level = self.storage.upgrades:get_level(DEFS.POWERUPS.MORE_GEMS.id)
	local reward = {
		gems = DEFS.POWERUPS.MORE_GEMS.levels[level].daily_gems,
	}
	return reward
end

function Storage:gems_daily_collect()
	if (self:gems_daily_can_collect()) then
		self.game.gems_daily[tostring(1)].have = false
		self.game.gems_daily[tostring(2)].have = false
		self.game.gems_daily[tostring(3)].have = false

		local reward = self:gems_daily_get_reward()

		self:gems_add(reward.gems, ENUMS.GEMS_ADD_TYPE.DAILY_REWARD)
		self.game.gems_daily.last_time = os.time()

		self.world.game.tasks:daily_gems_completed()
	end
end

function Storage:skin_get()
	return self.game.skin
end

function Storage:skin_set(skin)
	assert(skin)
	assert(DEFS.SKINS.SKINS_BY_ID[skin], "unknown skin:" .. skin)
	self.game.skin = skin
	self:save_and_changed()
	self.world.game.tasks:skin_changed()
end

function Storage:shop_offer_get_reward()
	local def = DEFS.POWERUPS.MORE_GEMS
	local level_def = def.levels[self.storage.upgrades:get_level(def.id)]
	return level_def.shop_offer
end

function Storage:shop_offer_success()
	local reward = self:shop_offer_get_reward()
	self:gems_add(reward, ENUMS.GEMS_ADD_TYPE.SHOP_OFFER)
	self:save_and_changed()
end

function Storage:is_tutorial_completed()
	return self.game.tutorial_completed
end

function Storage:tutorial_completed()
	self.game.tutorial_completed = true
	self:save_and_changed()
end

function Storage:world_id_get()
	return self.game.world_id
end

function Storage:world_id_def_get()
	return DEFS.WORLDS.WORLDS_BY_ID[self.game.world_id]
end

function Storage:world_can_run()
	local stars = self:stars_get()
	local def = self:world_id_get()
	return def.stars <= stars
end

function Storage:world_id_set(world_id)
	self.game.world_id = assert(world_id)
	self:save_and_changed()
end

return Storage