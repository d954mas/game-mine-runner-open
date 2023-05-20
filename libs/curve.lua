local COMMON = require "libs.common"
local BINARY_SEARCH = require "libs.binary_search"


--https://gist.github.com/brookesi/6593166
---@class Curve
local Curve = COMMON.class("Curve")

local CONSTRUCTOR_CONF = {
    points = "table",
    tension = "?number", -- 0-1, 0 = no smoothing, 0.5 = smooth (default), 1 = very smoothed
    segments = "?number", --numberOfSegments resolution of the smoothed curve. Higer number -> smoother (default 16)
}

--- Create a new Bezier Curve instance
-- @param s Start point coordinate in the form : {x, y}
-- @param f Finish point coordinate in the form : {x, y}
-- @return BezierCurve instance
function Curve:initialize(config)
    checks("?", CONSTRUCTOR_CONF)
    assert(#config.points >= 2,"points:" .. #config.points)
    self.points = {}
    for _, point in ipairs(config.points) do
        table.insert(self.points, vmath.vector3(point.x, point.y, point.z or 0))
    end
    self.tension = config.tension or 0.5
    self.segments = config.segments or 16

    self:_calculate()
end

function Curve:_calculate()
    local _pts
    local res = {}            --/ clone array
    local x
    local y                    --/ our x,y coords
    local z
    local t1x
    local t2x
    local t1y
    local t2y        --/ tension vectors
    local t1z
    local t2z
    local c1, c2, c3, c4            --/ cardinal points
    local st, t, i                --/ steps based on num. of segments
    local pow3, pow2                --/ cache powers
    local pow32, pow23
    local p0, p1, p2, p3,p1_z,p3_z            --/ cache points
    local pl = #self.points

    self.points_calculated = {}


    --/ clone array so we don't change the original content
    for k, v in ipairs(self.points) do
        self.points_calculated[k] = vmath.vector3(v)
    end

    --дублируем начало и конец
    table.insert(self.points_calculated, 1, self.points[1])
    table.insert(self.points_calculated, self.points[pl])

    --/ 1. loop goes through point array
    --/ 2. loop goes through each segment between the two points + one point before and after
    ----for (i = 2 i < pl i += 2)
    for i = 2, pl, 1 do
        p0 = self.points_calculated[i].x
        p1 = self.points_calculated[i].y
        p1_z = self.points_calculated[i].z
        p2 = self.points_calculated[i + 1].x
        p3 = self.points_calculated[i + 1].y
        p3_z = self.points_calculated[i + 1].z

        --/ calc tension vectors
        t1x = (p2 - self.points_calculated[i - 1].x) * self.tension
        t2x = (self.points_calculated[i + 2].x - p0) * self.tension

        t1y = (p3 - self.points_calculated[i - 1].y) * self.tension
        t2y = (self.points_calculated[i + 2].y - p1) * self.tension

        t1z = (p3_z - self.points_calculated[i - 1].z) * self.tension
        t2z = (self.points_calculated[i + 2].z - p1_z) * self.tension

        for t = 0, self.segments-1 do

            --/ calc step
            st = t / self.segments

            pow2 = math.pow(st, 2)
            pow3 = pow2 * st
            pow23 = pow2 * 3
            pow32 = pow3 * 2

            --/ calc cardinals
            c1 = pow32 - pow23 + 1
            c2 = pow23 - pow32
            c3 = pow3 - 2 * pow2 + st
            c4 = pow3 - pow2

            --/ calc x and y cords with common control vectors
            x = c1 * p0 + c2 * p2 + c3 * t1x + c4 * t2x
            y = c1 * p1 + c2 * p3 + c3 * t1y + c4 * t2y
            z = c1 * p1_z + c2 * p3_z + c3 * t1z + c4 * t2z

            --/ store points in array
            table.insert(res, vmath.vector3(x, y, z))
        end
    end

    table.insert(res, self.points[pl])

    self.points_calculated = res
    self.len = 0
    self.segments = {}

    for i = 1, #self.points_calculated - 1 do
        local start_point, end_point = self.points_calculated[i], self.points_calculated[i + 1]
        local v = end_point - start_point
        local v_len = vmath.length(v)
        if (v_len ~= 0) then
            local start_len = self.len
            self.len = self.len + v_len
            table.insert(self.segments, { len = v_len, p1 = start_point, p2 = end_point, vector = v, curve_len_start = start_len, curve_len_finish = self.len })

        end
    end
end

local COMPARATOR = function(segment, dist)
    if (dist > segment.curve_len_finish) then return 1
    elseif (dist < segment.curve_len_start) then return -1
    else return 0 end
end

function Curve:point_interpolated_get_segment(a)
    a = COMMON.LUME.clamp(a, 0, 1)
    if (a == 1) then return self.segments[#self.segments], #self.segments
    elseif (a == 0) then return self.segments[1], 1 end
    local dist = self.len * a
    local target_segment_id = BINARY_SEARCH:Search(self.segments, dist, COMPARATOR)
    return self.segments[target_segment_id], target_segment_id
end

function Curve:point_interpolated_get_coords(a)
    a = COMMON.LUME.clamp(a, 0, 1)
    if (a == 1) then return self.points[#self.points].x, self.points[#self.points].y, self.points[#self.points].z
    elseif (a == 0) then return self.points[1].x, self.points[1].y, self.points[1].z end
    local dist = self.len * a

    local target_segment = self.segments[BINARY_SEARCH:Search(self.segments, dist, COMPARATOR)]
    --local target_segment_2
    --for _, segment in ipairs(self.segments) do
    --	if (dist < segment.curve_len_finish) then
    --	target_segment_2 = segment
    --	break
    --end
    --end
    --	assert(target_segment==target_segment_2,"bad fast search.Get:" .. tostring(target_segment) .. "need:" .. tostring(target_segment_2))
    local point_a = 1 - ((target_segment.curve_len_finish - dist) / target_segment.len)
    local x = target_segment.p1.x + target_segment.vector.x * point_a
    local y = target_segment.p1.y + target_segment.vector.y * point_a
    local z = target_segment.p1.z + target_segment.vector.z * point_a
    return x, y, z
end

function Curve:point_interpolated_get_v3(a)
    local x, y, z = self:point_interpolated_get_coords(a)
    return vmath.vector3(x, y, z)
end

function Curve:debug_draw()
    for i = 1, #self.points - 1 do
        msg.post("@render:", "draw_line", { start_point = self.points[i], end_point = self.points[i + 1], color = vmath.vector4(1, 0, 0, 0.5) })
    end

    for i = 1, #self.points_calculated - 1 do
        msg.post("@render:", "draw_line", { start_point = self.points_calculated[i], end_point = self.points_calculated[i + 1], color = vmath.vector4(1, 1, 1, 0.5) })
    end
end

return Curve