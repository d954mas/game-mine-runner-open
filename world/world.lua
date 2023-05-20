local COMMON = require "libs.common"
local Storage = require "world.storage.storage"
local GameWorld = require "world.game.game_world"
local Sdk = require "libs.sdk.sdk"
local SOUNDS = require "libs.sounds"
local Highscores = require "libs_project.highscores"


local TAG = "WORLD"
---@class World
local M = COMMON.class("World")

function M:initialize()
	COMMON.i("init", TAG)
	self.storage = Storage(self)
	self.game = GameWorld(self)
	self.sdk = Sdk(self)
	self.highscores = Highscores(self)
	self.sounds = SOUNDS
	self.sounds.world = self
	self.time = 0
end

function M:update(dt)
	self.storage:update(dt)
	self.sdk:update(dt)
	self.time = self.time + dt
end

function M:on_storage_changed()

end

function M:final()

end

return M()