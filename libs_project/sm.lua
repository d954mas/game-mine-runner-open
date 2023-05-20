local SM = require "libs.sm.scene_manager"

---@class SceneManagerProject:SceneManager
local sm = SM()

local scenes = {
	require "scenes.game.game_scene",
	require "scenes.lose.lose_scene",
	require "scenes.pause.pause_scene",
	require "scenes.shop.shop_scene",
	require "scenes.reward.reward_scene",
}

sm.SCENES = {
	GAME = "GameScene",
}


sm.MODALS = {
	LOSE = "LoseScene",
	PAUSE = "PauseScene",
	SHOP = "ShopScene",
	REWARD = "RewardScene",
}

function sm:register_scenes()
	local reg_scenes = {}
	for i, v in ipairs(scenes) do reg_scenes[i] = v() end --create instances
	self:register(reg_scenes)
end

return sm