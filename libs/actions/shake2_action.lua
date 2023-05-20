local COMMON = require "libs.common"
local TweenAction = require "libs.actions.tween_action"

---@class Shake2Action:SequenceAction
local Action = COMMON.class("ShakeAction", TweenAction)

function Action:config_check(config)
	assert(self.config.magnitude)
	TweenAction.config_check(self,config)
end

function Action:initialize(config)
	assert(config.object)
	config.property = "a"
	self.go_object = assert(config.object)
	self.magnitude = config.magnitude
	config.magnitude = nil
	config.object = {}
	config.to = { a = 1 }
	config.from = { a = 0 }
	self.position = gui.get_position(self.go_object)
	TweenAction.initialize(self, config)
end

function Action:set_property(...)
	TweenAction.set_property(self, ...)
	local position = vmath.vector3(self.position)

	gui.set_position(position + vmath.vector3(math.random(-self.magnitude, self.magnitude),
			math.random(-self.magnitude, self.magnitude), 0), self.go_object)

end

return Action