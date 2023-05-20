local COMMON = require "libs.common"
local GOOEY = require "gooey.gooey"

local CHEKCKBOX_PRESSED = hash("checkbox_pressed")
local CHEKCKBOX_CHECKED_PRESSED = hash("checkbox_checked_pressed")
local CHEKCKBOX_CHECKED_NORMAL = hash("checkbox_checked_normal")
local CHEKCKBOX_NORMAL = hash("checkbox_normal")

local function refresh_checkbox(checkbox)
	if checkbox.pressed and not checkbox.checked then
		gui.play_flipbook(checkbox.node, CHEKCKBOX_PRESSED)
	elseif checkbox.pressed and checkbox.checked then
		gui.play_flipbook(checkbox.node, CHEKCKBOX_CHECKED_PRESSED)
	elseif checkbox.checked then
		gui.play_flipbook(checkbox.node, CHEKCKBOX_CHECKED_NORMAL)
	else
		gui.play_flipbook(checkbox.node, CHEKCKBOX_NORMAL)
	end
end

local Btn = COMMON.class("ButtonScale")

function Btn:initialize(root_name, path)
	self.vh = {
		root = gui.get_node(root_name .. (path or "/root")),
	}
	self.root_name = root_name .. (path or "/root")
	self.gooey_listener = function(cb)
		self.checked = cb.checked
		if self.input_listener then self.input_listener() end
	end
	self.checked = false
end

function Btn:set_input_listener(listener)
	self.input_listener = listener
end

function Btn:set_checked(checked)
	self.checked = checked
	local cb = GOOEY.checkbox(self.root_name .. "/box")
	cb.set_checked(self.checked)
end

function Btn:on_input(action_id, action)
	if (not self.ignore_input) then
		local cb = GOOEY.checkbox(self.root_name .. "/box", action_id, action, self.gooey_listener, refresh_checkbox)
		return cb.consumed
	end
end

function Btn:set_enabled(enable)
	gui.set_enabled(self.vh.root, enable)
end

function Btn:set_ignore_input(ignore)
	self.ignore_input = ignore
end

return Btn