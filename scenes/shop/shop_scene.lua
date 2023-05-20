local SM_ENUMS = require "libs.sm.enums"
local COMMON = require "libs.common"
local BaseScene = require "libs.sm.scene"

---@class ShopScene:Scene
local Scene = BaseScene:subclass("ShopScene")
function Scene:initialize()
	BaseScene.initialize(self, "ShopScene", "/shop_scene#collectionproxy")
	self._config.modal = true
end

function Scene:load_done()
end

function Scene:show_done()

end

function Scene:transition(transition)
	if (transition == SM_ENUMS.TRANSITIONS.ON_HIDE or
			transition == SM_ENUMS.TRANSITIONS.ON_BACK_HIDE) then
		local ctx = COMMON.CONTEXT:set_context_top_shop_gui()
		ctx.data:animate_hide()
		ctx:remove()

		COMMON.coroutine_wait(0.5)
	elseif (transition == SM_ENUMS.TRANSITIONS.ON_SHOW) then
		local ctx = COMMON.CONTEXT:set_context_top_shop_gui()
		ctx.data:animate_show()
		ctx:remove()
		COMMON.coroutine_wait(0.5)
	end
end

return Scene