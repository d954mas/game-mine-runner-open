local ECS = require 'libs.ecs'
local R = require "scene3d.render.render3d"
local COMMON = require "libs.common"

---@class VdropUpdateSystem:ECSSystem
local System = ECS.system()
System.name = "VdropUpdateSystem"

local HASH_PARAMS = hash("params")

---@param e EntityGame
function System:init()
	self.url = msg.url("game_scene:/post_process#vdrop")
	self.enabled = false
	msg.post(self.url, COMMON.HASHES.MSG.DISABLE)
	self.params = vmath.vector4(0)
	self.time = 0
	self.tint_w = 0
	self.show_time = 0
end

function System:update(dt)
	if(self.world.game_world.game.state.lose)then
		dt = 1/60
	end
	self.time = self.time + dt
	self.params.x = COMMON.RENDER.screen_size.w
	self.params.y = COMMON.RENDER.screen_size.h
	self.params.z = self.time
	go.set(self.url, HASH_PARAMS, self.params)

	local state = self.world.game_world.game.state
	local need_show = state.speed_level_time > 0
	if (not self.enabled and need_show) then
		self.enabled = true
		msg.post(self.url,  COMMON.HASHES.MSG.ENABLE)
		self.show_time = 1
		--msg.post(self.url, self.enabled and COMMON.HASHES.MSG.ENABLE or COMMON.HASHES.MSG.DISABLE)
	end

	if(self.show_time>0)then
		local a
		if(self.show_time>0.75)then
			a = (1-self.show_time)/0.25
		else
			a = 1-(0.75-self.show_time)/0.25
		end
		go.set(self.url,COMMON.HASHES.TINT_W,a)
		self.show_time = self.show_time-dt
	end
	if(self.show_time<=0)then
		self.enabled = false
		msg.post(self.url, COMMON.HASHES.MSG.DISABLE)
	end

end

return System