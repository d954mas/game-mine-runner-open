local COMMON = require "libs.common"

---@class Features
local Features = COMMON.class("Features")

function Features:initialize()
	self.features_base = {
		debug_gui = false,
		resizer = false,
		show_dt = false,
		game_debug_info = false,
	}
end

function Features:debug_config()
	self.features_base.debug_gui = true
	self.features_base.resizer =  COMMON.CONSTANTS.PLATFORM_IS_PC
	self.features_base.show_dt = true
	self.features_base.game_debug_info = true

end
function Features:prod_config()

end

function Features:load()
	if (self.features_base.debug_gui) then
		collectionfactory.load("/features#factory_debug_gui", function()
			collectionfactory.create("/features#factory_debug_gui")
		end)
	end
	if (self.features_base.resizer) then
		collectionfactory.load("/features#factory_resizer", function()
			collectionfactory.create("/features#factory_resizer")
		end)
	end
	if (self.features_base.show_dt) then
		collectionfactory.load("/features#factory_show_dt", function()
			collectionfactory.create("/features#factory_show_dt")
		end)
	end
end

function Features:load_game()
	if (self.features_base.game_debug_info) then
		collectionfactory.create("/features#game_debug_info")

	end
end

return Features