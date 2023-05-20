local WORLD = require "world.world"
local BaseScene = require "libs.sm.scene"
local ENUMS = require "world.enums.enums"

---@class GameScene:Scene
local Scene = BaseScene:subclass("Game")
function Scene:initialize()
	BaseScene.initialize(self, "GameScene", "/game_scene#collectionproxy")
	self._config.keep_running = true
	self._config.keep_running_scenes = { ["LoseScene"] = true,["ShopScene"] = true }
end

function Scene:update(dt)
	BaseScene.update(self, dt)
end

function Scene:resume()
	BaseScene.resume(self)
end

function Scene:pause()
	BaseScene.pause(self)
end

function Scene:pause_done()

end

function Scene:resume_done()

end

function Scene:show_done()

end

function Scene:load_done()
	self._input = self._input or {}
end

return Scene