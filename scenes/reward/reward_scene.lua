local SM_ENUMS = require "libs.sm.enums"
local COMMON = require "libs.common"
local BaseScene = require "libs.sm.scene"

---@class RewardScene:Scene
local Scene = BaseScene:subclass("RewardScene")
function Scene:initialize()
	BaseScene.initialize(self, "RewardScene", "/reward_scene#collectionproxy")
	self._config.modal = true
end

function Scene:load_done()
end

function Scene:show_done()

end

function Scene:transition(transition)
	if (transition == SM_ENUMS.TRANSITIONS.ON_HIDE or
			transition == SM_ENUMS.TRANSITIONS.ON_BACK_HIDE) then
		local ctx = COMMON.CONTEXT:set_context_top_reward_gui()
		ctx.data:animate_hide()
		ctx:remove()

		COMMON.coroutine_wait(0.5)
	elseif (transition == SM_ENUMS.TRANSITIONS.ON_SHOW) then
		local ctx = COMMON.CONTEXT:set_context_top_reward_gui()
		ctx.data:animate_show(self._input)
		ctx:remove()
		COMMON.coroutine_wait(0.65)
	end
end

return Scene