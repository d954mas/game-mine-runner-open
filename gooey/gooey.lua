local core = require "gooey.internal.core"
local checkbox = require "gooey.internal.checkbox"
local button = require "gooey.internal.button"

local M = {}


--- Check if a node is enabled. This is done by not only
-- looking at the state of the node itself but also it's
-- ancestors all the way up the hierarchy
-- @param node
-- @return true if node and all ancestors are enabled
function M.is_enabled(node)
	return core.is_enabled(node)
end


--- Convenience function to acquire input focus
function M.acquire_input()
	msg.post(".", "acquire_input_focus")
end


--- Convenience function to release input focus
function M.release_input()
	msg.post(".", "release_input_focus")
end


function M.create_theme()
	local theme = {}
	
	theme.is_enabled = function(component)
		if component.node then
			return M.is_enabled(component.node)
		end
	end

	theme.set_enabled = function(component, enabled)
		if component.node then
			gui.set_enabled(component.node, enabled)
		end
	end

	theme.acquire_input = M.acquire_input
	theme.release_input = M.release_input

	theme.group = M.group

	return theme
end


-- no-operation
-- empty function to use when no component callback function was provided
local function nop() end


function M.button(node_id, action_id, action, fn, refresh_fn)
	local b = button(node_id, action_id, action, fn or nop, refresh_fn)
	return b
end


function M.checkbox(node_id, action_id, action, fn, refresh_fn)
	local c = checkbox(node_id, action_id, action, fn or nop, refresh_fn)
	return c
end



return M