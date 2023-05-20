local CLASS = require "libs.middleclass"
local ContextManager = require "libs.contexts_manager"

---@class ContextManagerProject:ContextManager
local Manager = CLASS.class("ContextManagerProject", ContextManager)

Manager.NAMES = {
	GAME = "GAME",
	MAIN = "MAIN",
	SHOP = "SHOP",
	GAME_GUI = "GAME_GUI",
	MENU_GUI = "MENU_GUI",
	LOSE_GUI = "LOSE_GUI",
	PAUSE_GUI = "PAUSE_GUI",
	SHOP_GUI = "SHOP_GUI",
	REWARD_GUI = "REWARD_GUI",
	TOP_PANEL_GUI = "TOP_PANEL_GUI",
	FLY_OBJECTS_GUI = "FLY_OBJECTS_GUI",
	FADER = "FADER",
}

---@class ContextStackWrapperMain:ContextStackWrapper
-----@field data ScriptMain

---@return ContextStackWrapperMain
function Manager:set_context_top_main()
	return self:set_context_top_by_name(self.NAMES.MAIN)
end

---@return ContextStackWrapperMain
function Manager:set_context_top_game()
	return self:set_context_top_by_name(self.NAMES.GAME)
end

---@class ContextStackWrapperGameGui:ContextStackWrapper
---@field data GameSceneGuiScript

---@return ContextStackWrapperGameGui
function Manager:set_context_top_game_gui()
	return self:set_context_top_by_name(self.NAMES.GAME_GUI)
end





---@class ContextStackWrapperLoseSceneGui:ContextStackWrapper
---@field data LoseSceneGuiScript

---@return ContextStackWrapperLoseSceneGui
function Manager:set_context_top_lose_gui()
	return self:set_context_top_by_name(self.NAMES.LOSE_GUI)
end


---@class ContextStackWrapperTopPauseGui:ContextStackWrapper
---@field data PauseSceneGuiScript

---@return ContextStackWrapperTopPauseGui
function Manager:set_context_top_pause_gui()
	return self:set_context_top_by_name(self.NAMES.PAUSE_GUI)
end

---@class ContextStackWrapperTopMenuGui:ContextStackWrapper
---@field data MainMenuSceneGuiScript

---@return ContextStackWrapperTopMenuGui
function Manager:set_context_top_menu_gui()
	return self:set_context_top_by_name(self.NAMES.MENU_GUI)
end

---@class ContextStackWrapperTopShopGui:ContextStackWrapper
---@field data ShopSceneGuiScript

---@return ContextStackWrapperTopShopGui
function Manager:set_context_top_shop_gui()
	return self:set_context_top_by_name(self.NAMES.SHOP_GUI)
end

---@class ContextStackWrapperTopPanelGui:ContextStackWrapper
---@field data TopPanelGuiScript

---@return ContextStackWrapperTopPanelGui
function Manager:set_context_top_top_panel_gui()
	return self:set_context_top_by_name(self.NAMES.TOP_PANEL_GUI)
end


---@class ContextStackWrapperToShop:ContextStackWrapper
---@field data ScriptShop

---@return ContextStackWrapperToShop
function Manager:set_context_top_shop()
	return self:set_context_top_by_name(self.NAMES.SHOP)
end

---@class ContextStackWrapperToFader:ContextStackWrapper
---@field data GameFaderGuiScript

---@return ContextStackWrapperToFader
function Manager:set_context_top_fader()
	return self:set_context_top_by_name(self.NAMES.FADER)
end

---@class ContextStackWrapperToFlyObjectsGui:ContextStackWrapper
---@field data FlyObjectsGuiScript

---@return ContextStackWrapperToFlyObjectsGui
function Manager:set_context_top_fly_objects()
	return self:set_context_top_by_name(self.NAMES.FLY_OBJECTS_GUI)
end

---@class ContextStackWrapperToRewardGui:ContextStackWrapper
---@field data RewardSceneGuiScript

---@return ContextStackWrapperToRewardGui
function Manager:set_context_top_reward_gui()
	return self:set_context_top_by_name(self.NAMES.REWARD_GUI)
end

return Manager()