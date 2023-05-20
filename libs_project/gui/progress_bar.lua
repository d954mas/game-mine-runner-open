local COMMON = require "libs.common"

---@class ProgressBar
local Bar = COMMON.class("Bar")

function Bar:initialize(vh)
    self.vh = {
        root = assert(vh.root),
        bg = assert(vh.bg),
        progress = assert(vh.progress),
        --center = gui.get_node(root_name .. "/center"),
        lbl = vh.lbl
    }
    self.value_max = 100
    self.value = 0
    self.padding_progress = gui.get_position(self.vh.progress).x
    self.progress_width_max = gui.get_size(self.vh.bg).x - self.padding_progress * 2
    self.nine_texture_size = gui.get_slice9(self.vh.progress)
    self.nine_texture_size_origin = gui.get_slice9(self.vh.progress)
    self.animation = {
        value = 0,
    }

    self:set_value(self.value)
    self:gui_update()
end

function Bar:set_value_max(value)
    assert(value > 0)
    self.value_max = value
    self:gui_update()
end

function Bar:update(dt)

end

function Bar:lbl_format_value()
    return (math.ceil(self.animation.value) .. "/" .. self.value_max)
end

function Bar:gui_update()
    if self.vh.lbl then
        gui.set_text(self.vh.lbl, self:lbl_format_value())
    end

    local size = vmath.vector3(self.progress_width_max * self.animation.value / self.value_max, gui.get_size(self.vh.progress).y, 0)
    size.x = math.floor(size.x)
    if (size.x == 0) then
        if (not self.progress_disabled) then
            self.progress_disabled = true
            gui.set_enabled(self.vh.progress, false)
        end
    elseif (size.x < self.nine_texture_size_origin.x + self.nine_texture_size_origin.w) then
        self.nine_texture_size_changed = true
        self.nine_texture_size.x = size.x
        self.nine_texture_size.w = 0
        gui.set_slice9(self.vh.progress, self.nine_texture_size)
    else
        if (self.nine_texture_size_changed) then
            self.nine_texture_size = vmath.vector4(self.nine_texture_size_origin)
            gui.set_slice9(self.vh.progress, self.nine_texture_size)
            self.nine_texture_size_changed = nil
        end
    end

    if (size.x ~= 0 and self.progress_disabled) then
        self.progress_disabled = nil
        gui.set_enabled(self.vh.progress, true)
    end
    gui.set_size(self.vh.progress, size)
end

function Bar:set_enabled(enabled)
    gui.set_enabled(self.vh.root, enabled)
end

function Bar:set_value(value, force)
    if(self.value == value) then return end
    self.value = COMMON.LUME.clamp(value, 0, self.value_max)
    self.animation.value = COMMON.LUME.clamp(value, 0, self.value_max)
    self:gui_update()
end


function Bar:destroy()
    gui.delete_node(self.vh.root)
    self.vh = nil
end

return Bar