local SM_ENUMS = require "libs.sm.enums"
local COMMON = require "libs.common"
local WORLD = require "world.world"
local BaseScene = require "libs.sm.scene"

---@class PauseScene:Scene
local Scene = BaseScene:subclass("PauseScene")
function Scene:initialize()
	BaseScene.initialize(self, "PauseScene", "/pause_scene#collectionproxy")
	self._config.modal = true
end

function Scene:load_done()
end

function Scene:show_done()

end

function Scene:transition(transition)
	if (transition == SM_ENUMS.TRANSITIONS.ON_HIDE or
			transition == SM_ENUMS.TRANSITIONS.ON_BACK_HIDE) then
		if(not self._input.to_menu)then
			WORLD.game:set_start_delay()
		end
		local ctx = COMMON.CONTEXT:set_context_top_pause_gui()
		ctx.data:animate_hide()
		ctx:remove()

		COMMON.coroutine_wait(0.5)
	elseif (transition == SM_ENUMS.TRANSITIONS.ON_SHOW) then
		local ctx = COMMON.CONTEXT:set_context_top_pause_gui()
		ctx.data:animate_show()
		ctx:remove()
		COMMON.coroutine_wait(0.5)
	end
end

return Scene