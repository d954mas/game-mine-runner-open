local Utils = {}

local V1 = vmath.vector3(0)
local V2 = vmath.vector3(0)

local HASH_DRAW_LINE = hash("draw_line")
local MSD_DRAW_LINE_COLOR = vmath.vector4(0)

local MSD_DRAW_LINE = {
	start_point = V1,
	end_point = V2,
	color = MSD_DRAW_LINE_COLOR
}

function Utils.draw_aabb(left, top, right, bottom, color)
	MSD_DRAW_LINE_COLOR.x = color.x
	MSD_DRAW_LINE_COLOR.y = color.y
	MSD_DRAW_LINE_COLOR.z = color.z
	MSD_DRAW_LINE_COLOR.w = color.w

	V1.x, V1.y = left, top
	V2.x, V2.y = right, top
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y = right, top
	V2.x, V2.y = right, bottom
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y = right, bottom
	V2.x, V2.y = left, bottom
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)

	V1.x, V1.y = left, bottom
	V2.x, V2.y = left, top
	msg.post("@render:", HASH_DRAW_LINE, MSD_DRAW_LINE)
end

return Utils