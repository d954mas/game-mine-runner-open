local COMMON = require "libs.common"
---@class SelectionView
local View = COMMON.class("SelectionView")

---@param root url
function View:initialize(root_name)
	self.root_name = assert(root_name)
	self:bind_vh()
	self:gui_init()
end

function View:gui_init()
	self.texture9 = gui.get_slice9(self.vh.root)
	gui.set_enabled(self.vh.root, false)
end

function View:select_view_size_by_view(view)
	local anchor_x = gui.get_xanchor(view)
	local anchor_y = gui.get_yanchor(view)
	local parent = gui.get_parent(view)
	while (parent) do
		if (anchor_x == gui.ANCHOR_NONE) then anchor_x = gui.get_xanchor(parent) end
		if (anchor_y == gui.ANCHOR_NONE) then anchor_y = gui.get_xanchor(parent) end
		parent = gui.get_parent(parent)
	end
	self:select_view_area(gui.get_screen_position(view), gui.get_size(view), view)
end

function View:select_view_area(pos, size, parent)
	gui.set_enabled(self.vh.root, true)
	--gui.set_size(self.vh.root, size+vmath.vector3(70,70,0))
	local new_size = size + vmath.vector3(28, 28, 0)
	if (new_size.x % 2 == 1) then new_size.x = new_size.x + 1 end
	if (new_size.y % 2 == 1) then new_size.y = new_size.y + 1 end
	local scale_x = (self.texture9.x + self.texture9.z) / new_size.x
	local scale_y = (self.texture9.y + self.texture9.w ) / new_size.y
	local scale = math.max(1, scale_x, scale_y)
	new_size = new_size * scale
	new_size.x, new_size.y, new_size.z = math.ceil(new_size.x), math.ceil(new_size.y), 1
	gui.set_scale(self.vh.root, vmath.vector3(1 / scale))
	gui.set_size(self.vh.root, new_size)

	if (parent) then
		pos = pos - gui.get_screen_position(parent)
		gui.set_position(self.vh.root, pos)
		gui.set_parent(self.vh.root, parent, false)
	else
		gui.set_parent(self.vh.root, nil, false)
		gui.set_position(self.vh.root, pos)
	end
end

function View:hide()
	gui.set_enabled(self.vh.root, false)
end

function View:bind_vh()
	self.vh = {
		root = gui.get_node(self.root_name .. "/root"),
	}
end

return View