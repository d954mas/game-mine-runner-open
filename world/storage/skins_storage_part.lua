local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local StoragePart = require "world.storage.storage_part_base"

---@class SkinsPartOptions:StoragePartBase
local Storage = COMMON.class("SkinsPartOptions", StoragePart)

function Storage:initialize(...)
	StoragePart.initialize(self, ...)
	self.skins = self.storage.data.skins
end

function Storage:skin_have(id)
	return self.skins[id].have
end

function Storage:skin_buy(id, ads)
	if not self.skins[id].have then
		if ads and DEFS.SKINS.SKINS_BY_ID[id].unlock_by_ads then
			self.skins[id].have = true
			self:save_and_changed()
		else
			local price = DEFS.SKINS.SKINS_BY_ID[id].price
			if (self.storage.game:gems_get() >= price) then
				self.storage.game:gems_spend(price)
				self.skins[id].have = true
				self:save_and_changed()
			end
		end

	end
	return
end

return Storage