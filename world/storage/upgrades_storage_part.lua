local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local StoragePart = require "world.storage.storage_part_base"

---@class UpgradesPartOptions:StoragePartBase
local Storage = COMMON.class("UpgradesPartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.upgrades = self.storage.data.upgrades
end

function Storage:get_level(id)
	return self.upgrades[id].level
end

function Storage:is_max_level(id)
	return self.upgrades[id].level >= #DEFS.POWERUPS[id].levels
end

function Storage:get_price(id)
	if (self:is_max_level(id)) then return math.huge end
	return DEFS.POWERUPS[id].levels[self:get_level(id) + 1].cost
end

function Storage:level_up(id)
	if (not self:is_max_level(id)) then
		local price = self:get_price(id)
		if (self.storage.game:gems_get() >= price) then
			self.storage.game:gems_spend(price)
			self.upgrades[id].level = self.upgrades[id].level + 1
			self:save_and_changed()
		end
	end
end

return Storage