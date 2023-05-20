local COMMON = require "libs.common"
local PERLIN = require "libs.perlin"
local Action = require "libs.actions.action"

local CHECKS_CONFIG = {
	easing = "function",
	time = "number",
	angle = "number",
	perlin_power = "number",
	object = "userdata"
}

---@class ShakeEulerZAction:Action
local ShakeAction = COMMON.class("ShakeAction", Action)

function ShakeAction:config_check(config)
	checks("?", CHECKS_CONFIG)
end

function ShakeAction:initialize(config)
	Action.initialize(self, config)
	self.perlin_seeds = { math.random(128), math.random(128), math.random(128) }
	self.angle = gui.get_rotation(self.config.object)
	self.angle_result = gui.get_rotation(self.config.object)
	self.time = 0
end

function ShakeAction:set_property()
	local a = 1 - self.config.easing(self.time, 0, 1, self.config.time)
	local angle = self.config.angle * a * (PERLIN.noise(self.time * self.config.perlin_power, self.perlin_seeds[1], 0))
	self.angle_result.z = self.config.angle * 0.2 + self.angle.z + angle --for some reason noize is return - more offen
	gui.set_rotation(self.config.object, self.angle_result)

end

function ShakeAction:act(dt)
	if self.config.delay then
		COMMON.coroutine_wait(self.config.delay)
	end

	while (self.time < self.config.time) do
		self:set_property()
		dt = coroutine.yield()
		self.time = self.time + dt
	end

	gui.set_rotation(self.config.object, self.angle)
end

return ShakeAction