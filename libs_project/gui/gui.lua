local M = {}
M.ButtonIconTest = require "libs_project.gui.button_icon_text"
M.ButtonScale = require "libs_project.gui.button_scale"
M.CheckboxWithLabel = require "libs_project.gui.checkbox_with_label"
M.ProgressBar = require "libs_project.gui.progress_bar"

local COMMON = require "libs.common"
local CounterLabel = COMMON.class("CounterLabel")
function CounterLabel:initialize(config)
	self.config = assert(config)
	self.labels = {}
	for i, lbl in ipairs(self.config.labels) do
		self.labels[i] = {
			lbl = lbl,
			value = "",
			enabled = true
		}
		gui.set_text(lbl, "0")
	end
	self.max_value = math.pow(10, #self.labels) - 1 --4 labels 0000-9999
	self.min_labels = assert(self.config.min_labels)
	self.value = nil
	self.count = 0
	self:set_value(0)
end

function CounterLabel:set_value(value)
	if (self.value == value) then return end
	self.value = value
	local value_str = tostring(math.min(value, self.max_value))
	value_str = value_str:reverse()

	local str_size = #value_str
	local count = math.max(str_size, self.min_labels)
	self.count = count

	for i = 1, count do
		local lbl = self.labels[i]
		if (not lbl.enabled) then
			lbl.enabled = true
			gui.set_enabled(lbl.lbl, true)
		end

		local lbl_value = value_str:sub(i, i)
		if (lbl_value == "") then lbl_value = "0" end
		if (lbl.value ~= lbl_value) then
			lbl.value = lbl_value
			gui.set_text(lbl.lbl, lbl_value)
		end
	end
	for i = count + 1, #self.labels do
		local lbl = self.labels[i]
		if (lbl.enabled) then
			lbl.enabled = false
			gui.set_enabled(lbl.lbl, false)
		end
	end
end

M.CounterLabel = CounterLabel

function M.set_nodes_to_center(l_node, is_l_node_text, r_node, is_r_node_text, delta)
	if delta == nil then delta = 0 end

	local l_size_x = (is_l_node_text and gui.get_text_metrics_from_node(l_node).width or gui.get_size(l_node).x) * gui.get_scale(l_node).x
	local r_size_x = (is_r_node_text and gui.get_text_metrics_from_node(r_node).width or gui.get_size(r_node).x) * gui.get_scale(r_node).x
	local l_pivot = gui.get_pivot(l_node)
	local r_pivot = gui.get_pivot(r_node)
	local l_pos = gui.get_position(l_node)
	local r_pos = gui.get_position(r_node)

	local text_length = l_size_x + r_size_x + delta
	local l_dx = (text_length / 2) - l_size_x
	local r_dx = (text_length / 2) - r_size_x

	l_pos.x = -l_dx
	if l_pivot == gui.PIVOT_W or l_pivot == gui.PIVOT_NW or l_pivot == gui.PIVOT_SW then
		l_pos.x = l_pos.x - l_size_x
	elseif l_pivot == gui.PIVOT_CENTER then
		l_pos.x = l_pos.x - l_size_x / 2
	end
	r_pos.x = r_dx
	if r_pivot == gui.PIVOT_E or r_pivot == gui.PIVOT_NE or r_pivot == gui.PIVOT_SE then
		r_pos.x = r_pos.x + r_size_x
	elseif r_pivot == gui.PIVOT_CENTER then
		r_pos.x = r_pos.x + r_size_x / 2
	end

	gui.set_position(l_node, l_pos)
	gui.set_position(r_node, r_pos)
end

function M.autosize_text(node, scale, text)
	local metrics = resource.get_text_metrics(gui.get_font_resource(gui.get_font(node)), tostring(text))
	local size = gui.get_size(node).x
	if (metrics.width > size) then
		local new_scale = scale * size / metrics.width
		gui.set_scale(node, vmath.vector3(new_scale))
	else
		gui.set_scale(node, vmath.vector3(scale))
	end
	gui.set_text(node, text)
end

return M