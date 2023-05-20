local COMMON = require "libs.common"
local Camera = require "libs.rendercam_camera"

local Cameras = COMMON.class("Cameras")

function Cameras:initialize()

end

function Cameras:init()
    self.game_camera = Camera("game", {
        orthographic = true,
        near_z = -100,
        far_z = 100,
        view_distance = 1,
        fov = 1,
        ortho_scale = 1,
        fixed_aspect_ratio = false,
        aspect_ratio = vmath.vector3(1067,600, 0),
        use_view_area = true,
        view_area = vmath.vector3(1067,600, 0),
        scale_mode = Camera.SCALEMODE.FIXEDAREA
    })
    self.current = self.game_camera
    self:window_resized()
end

function Cameras:update(dt)
    self.game_camera:update(dt)
end

function Cameras:set_current(camera)
    self.current = assert(camera)
end

function Cameras:window_resized()
    self.game_camera:recalculate_viewport()
end

function Cameras:dispose()
    self.subscription:unsubscribe()
end

return Cameras()
