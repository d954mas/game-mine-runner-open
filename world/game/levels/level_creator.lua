local COMMON = require "libs.common"
local DEFS = require "world.balance.def.defs"
local LEVEL_BALANCE = require "world.balance.def.level_balance"

---@class LevelCreator
local Creator = COMMON.class("LevelCreator")

---@param world World
function Creator:initialize(world)
	self.world = world
	self.ecs = world.game.ecs_game
	self.entities = world.game.ecs_game.entities
	---@type EntityGame
	self.player = nil
end

function Creator:create_player()
	self.player = self.entities:create_player()
	self.ecs:add_entity(self.player)
end

function Creator:create_tunnels()
	self.tunnel_idx = 0
	self.tunnel_idx = self.tunnel_idx + 1
	---@type EntityGame[]
	self.tunnels = {}

	local tunnel = self.entities:create_tunnel(COMMON.CONSTANTS.TUNNEL_POINTS, msg.url("/mesh_tunnel_1"))
	tunnel.tunnel_idx = self.tunnel_idx
	msg.post(tunnel.tunnel_go.root, COMMON.HASHES.MSG.ENABLE)
	DEFS.LEVEL_LINE.get_points(tunnel.tunnel_idx, tunnel.points)
	tunnel.tunnel:SetPoints(tunnel.points)
	self.entities:tunnel_init(tunnel)
	LEVEL_BALANCE.balance_for_tunnel(self.world, tunnel)

	self.tunnel_idx = self.tunnel_idx + 1
	local tunnel2 = self.entities:create_tunnel(COMMON.CONSTANTS.TUNNEL_POINTS, msg.url("/mesh_tunnel_2"))
	tunnel2.tunnel_idx = self.tunnel_idx
	msg.post(tunnel2.tunnel_go.root, COMMON.HASHES.MSG.ENABLE)
	DEFS.LEVEL_LINE.get_points(tunnel2.tunnel_idx, tunnel2.points)
	tunnel2.tunnel:SetPoints(tunnel2.points)
	self.entities:tunnel_init(tunnel2)
	LEVEL_BALANCE.balance_for_tunnel(self.world, tunnel2)

	self.tunnel_idx = self.tunnel_idx + 1
	local tunnel3 = self.entities:create_tunnel(COMMON.CONSTANTS.TUNNEL_POINTS, msg.url("/mesh_tunnel_3"))
	tunnel3.tunnel_idx = self.tunnel_idx
	msg.post(tunnel3.tunnel_go.root, COMMON.HASHES.MSG.ENABLE)
	DEFS.LEVEL_LINE.get_points(tunnel3.tunnel_idx, tunnel3.points)
	tunnel3.tunnel:SetPoints(tunnel3.points)
	self.entities:tunnel_init(tunnel3)
	LEVEL_BALANCE.balance_for_tunnel(self.world, tunnel3)

	table.insert(self.tunnels, tunnel)
	table.insert(self.tunnels, tunnel2)
	table.insert(self.tunnels, tunnel3)

	self.ecs:add_entity(tunnel)
	self.ecs:add_entity(tunnel2)
	self.ecs:add_entity(tunnel3)
end

function Creator:clear_game()
	self.ecs:clear()
end

function Creator:create()
	game.random_set_seed(socket.gettime())
	self:create_game()
end


function Creator:create_game()
	self:create_tunnels()
	self:create_player()

	self.world.game.ecs_game:add_systems()
	self.ecs:refresh()
	self.ecs:update(0)
end

return Creator