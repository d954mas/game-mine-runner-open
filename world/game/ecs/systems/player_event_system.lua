local ECS = require 'libs.ecs'
local COMMON = require "libs.common"
local ENUMS = require "world.enums.enums"
local ACTIONS = require "libs.actions.actions"
local TWEEN = require "libs.tween"
local DEFS = require "world.balance.def.defs"

---@class PlayerEventSystem:ECSSystemProcessing
local System = ECS.processingSystem()
System.filter = ECS.filter("player_event")
System.name = "PlayerEventSystem"

function System:init()
	self.gem_animation = nil

	self.gems = {
		state = "NO",
		action_sequence = ACTIONS.Sequence(),
		action_tween_show = nil,
		action_tween_hide = nil,
		action_tween_disable = nil
	}
	self.gems.action_sequence.drop_empty = false

	self.powerups = {
		state = "NO", --SHOW, WAIT, HIDE
		action = nil
	}

	self.powerup_speed = {
		state = "NO", --SHOW, WAIT, HIDE
		action = nil
	}
end

function System:onAddToWorld()
	local player = self.world.game_world.game.level_creator.player
	self.gems.action_tween_show = ACTIONS.TweenGo { object = player.player_go.glow_gem.sprite, property = "tint.w",
													to = 0.2, time = 0.33, easing = TWEEN.easing.outSine }
	self.gems.action_tween_hide = ACTIONS.TweenGo { object = player.player_go.glow_gem.sprite, property = "tint.w",
													from = 0.2, to = 0, time = 0.33, easing = TWEEN.easing.outSine }
	self.gems.action_tween_disable = ACTIONS.Function({ fun = function()
		msg.post(player.player_go.glow_gem.root, COMMON.HASHES.MSG.DISABLE)
	end })
end

function System:check_powerups(dt)
	local have_powerups = false
	have_powerups = have_powerups or self.world.game_world.game.state.powerups[DEFS.POWERUPS.STAR.id].duration > 0.2
--	have_powerups = have_powerups or self.world.game_world.game.state.powerups[DEFS.POWERUPS.RUN.id].duration > 0.2
	have_powerups = have_powerups or self.world.game_world.game.state.powerups[DEFS.POWERUPS.MAGNET.id].duration > 0.2
	local player = self.world.game_world.game.level_creator.player
	if (have_powerups and (self.powerups.state == "NO" or self.powerups.state == "HIDE")) then
		self.powerups.state = "SHOW"
		msg.post(player.player_go.glow_powerup.root, COMMON.HASHES.MSG.ENABLE)
		self.powerups.action = ACTIONS.Sequence()
		self.powerups.action:add_action(ACTIONS.TweenGo { object = player.player_go.glow_powerup.sprite, property = "tint.w",
														  to = 0.3, time = 0.2, easing = TWEEN.easing.outSine })
		self.powerups.action:add_action(function()
			self.powerups.state = "WAIT"
			self.powerups.action = nil
		end)
	end
	if (not have_powerups and (self.powerups.state == "SHOW" or self.powerups.state == "WAIT")) then
		self.powerups.state = "HIDE"
		self.powerups.action = ACTIONS.Sequence()
		self.powerups.action:add_action(ACTIONS.TweenGo { object = player.player_go.glow_powerup.sprite, property = "tint.w",
														  to = 0, time = 0.15, easing = TWEEN.easing.outSine })
		self.powerups.action:add_action(function()
			self.powerups.state = "NO"
			self.powerups.action = nil
			msg.post(player.player_go.glow_powerup.root, COMMON.HASHES.MSG.DISABLE)
		end)
	end

	if (self.powerups.action) then
		self.powerups.action:update(dt)
	end
end

function System:check_speed_powerup(dt)
	local have_powerups = false
	have_powerups = have_powerups or self.world.game_world.game.state.powerups[DEFS.POWERUPS.RUN.id].duration > 0.5
	local player = self.world.game_world.game.level_creator.player
	if (have_powerups and (self.powerup_speed.state == "NO" or self.powerup_speed.state == "HIDE")) then
		self.powerup_speed.state = "SHOW"
		msg.post(player.player_go.glow_powerup_speed.root, COMMON.HASHES.MSG.ENABLE)
		self.powerup_speed.action = ACTIONS.Sequence()
		self.powerup_speed.action:add_action(ACTIONS.TweenGo { object = player.player_go.glow_powerup_speed.sprite, property = "tint.w",
														  to = 0.5, time = 0.2, easing = TWEEN.easing.outSine })
		self.powerup_speed.action:add_action(function()
			self.powerup_speed.state = "WAIT"
			self.powerup_speed.action = nil
		end)
	end
	if (not have_powerups and (self.powerup_speed.state == "SHOW" or self.powerup_speed.state == "WAIT")) then
		self.powerup_speed.state = "HIDE"
		self.powerup_speed.action = ACTIONS.Sequence()
		self.powerup_speed.action:add_action(ACTIONS.TweenGo { object = player.player_go.glow_powerup_speed.sprite, property = "tint.w",
														  to = 0, time = 0.15, easing = TWEEN.easing.outSine })
		self.powerup_speed.action:add_action(function()
			self.powerup_speed.state = "NO"
			self.powerup_speed.action = nil
			msg.post(player.player_go.glow_powerup_speed.root, COMMON.HASHES.MSG.DISABLE)
		end)
	end

	if (self.powerup_speed.action) then
		self.powerup_speed.action:update(dt)
	end
end

---@param e EntityGame
function System:process(e, dt)
	if (e.player_event.type == ENUMS.PLAYER_EFFECT.COLLECT_GEM) then
		local player = self.world.game_world.game.level_creator.player
		msg.post(player.player_go.glow_gem.root, COMMON.HASHES.MSG.ENABLE)
		self.gems.action_sequence:reset()
		self.gems.action_tween_show.config.from = go.get(player.player_go.glow_gem.sprite, "tint.w")
		self.gems.action_tween_show:reset()
		self.gems.action_tween_hide:reset()
		self.gems.action_tween_disable:reset()

		self.gems.action_sequence:add_action(self.gems.action_tween_show)
		self.gems.action_sequence:add_action(self.gems.action_tween_hide)
		self.gems.action_sequence:add_action(self.gems.action_tween_disable)
	end
end

function System:postProcess(dt)
	self:check_powerups(dt)
	self:check_speed_powerup(dt)
	self.gems.action_sequence:update(dt)
end

return System