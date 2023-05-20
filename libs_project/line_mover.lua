local COMMON = require "libs.common"

-----@class LineMover
local Mover = COMMON.CLASS("LineMover")

---@param curve Curve
function Mover:initialize(curve)
    self.curve = curve
    self.segment_id = 1
    self.segment_id_max = #curve.segments
    self.speed_a = 0
    self.a = 0
    self.position = { x = curve.segments[1].p1.x, y = curve.segments[1].p1.y }
end

function Mover:reset()
    self.a = 0
    self.segment_id = 1
end

function Mover:speed_a_set(speed_a)
    self.speed_a = assert(speed_a)
end

function Mover:move(dt)
    local curve = self.curve

    local delta_move = self.speed_a * dt
    local a = self.a + delta_move
    a = COMMON.LUME.clamp(a, 0, 1)

    local dist = a * curve.len

    local segment
    if (a >= self.a) then
        for i = self.segment_id, self.segment_id_max, 1 do
            self.segment_id = i
            segment = curve.segments[i]
            if (segment.curve_len_finish > dist) then break end
        end
    else
        for i = self.segment_id, 1, -1 do
            self.segment_id = i
            segment = curve.segments[i]
            if (segment.curve_len_start < dist) then break end
        end
    end


    local point_a = 1 - ((segment.curve_len_finish - dist) / segment.len)
    self.point_a = point_a
    self.position.x = segment.p1.x + segment.vector.x * point_a
    self.position.y = segment.p1.y + segment.vector.y * point_a

    self.a = a

end

return Mover