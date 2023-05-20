local M = {}
M.print_f = print
M.logging = true
M.use_tag_whitelist = false
M.use_tag_blacklist = false
M.disable_logging_for_release = true
M.is_debug = sys.get_engine_info().is_debug

M.tag_whitelist = {
	["none"] = true
}

M.tag_blacklist = {

}

M.NONE = 0
M.TRACE = 10
M.DEBUG = 20
M.INFO = 30
M.WARNING = 40
M.ERROR = 50
M.CRITICAL = 60
M.logging_level = M.DEBUG

M.log_level_names = {
	[0] = "NONE ",
	[10] = "TRACE ",
	[20] = "DEBUG ",
	[30] = "INFO ",
	[40] = "WARN ",
	[50] = "ERROR ",
	[60] = "CRIT "
}

function M.add_to_whitelist(tag, state)
	M.tag_whitelist[tag] = state
end

function M.add_to_blacklist(tag, state)
	state = state or true
	M.tag_blacklist[tag] = state
end

function M.override_print()
	print = function(...)
		local arg = { ... }
		local result = arg[1]
		for i = 2, #arg do
			result = result .. "\t" .. tostring(arg[i])
		end
		M.i(result,nil,2)
	end
end

-- Sets the minimum log level to log, default is log.DEBUG
function M.set_level(level)
	M.logging_level = level
end

-- TRACE
function M.t(message, tag, debug_level)
	local level = M.TRACE
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

function M.trace(message, tag, debug_level)
	local level = M.TRACE
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

-- DEBUG
function M.d(message, tag, debug_level)
	local level = M.DEBUG
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

function M.debug(message, tag, debug_level)
	local level = M.DEBUG
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

-- INFO
function M.i(message, tag, debug_level)
	local level = M.INFO
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

function M.info(message, tag, debug_level)
	local level = M.INFO
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

-- WARNING
function M.w(message, tag, debug_level)
	local level = M.WARNING
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

function M.warning(message, tag, debug_level)
	local level = M.WARNING
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

-- ERROR
function M.e(message, tag, debug_level)
	local level = M.ERROR
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
	error(message)
end

function M.error(message, tag, debug_level)
	local level = M.ERROR
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
	error(message)
end

-- CRITICAL
function M.c(message, tag, debug_level)
	local level = M.CRITICAL
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

function M.critical(message, tag, debug_level)
	local level = M.CRITICAL
	debug_level = debug_level or 1
	M.save_log_line(message, level, tag, debug_level)
end

function M.save_log_line(line, level, tag, debug_level)
	if line == nil then return end
	if M.logging == false then return false end
	if M.disable_logging_for_release and M.is_debug == false then return false end

	line = tostring(line)

	debug_level = debug_level or 0

	level = level or M.NONE
	if level < M.logging_level then return false end

	tag = tag or "none"
	if M.use_tag_whitelist then
		if M.tag_whitelist[tag] ~= true then
			return false
		end
	end

	if M.use_tag_blacklist then
		if M.tag_blacklist[tag] then
			return false
		end
	end

	local level_string = M.log_level_names[level]

	local timestamp = os.time()
	local timestamp_string = os.date('%H:%M:%S', timestamp)

	local head = "[" .. level_string .. timestamp_string .. "]"
	local body = ""

	if tag then
		head = head .. " " .. tag .. ":"
	end

	if debug then
		local info = debug.getinfo(2 + debug_level, "Sl") -- https://www.lua.org/pil/23.1.html
		local short_src = info.short_src
		local line_number = info.currentline
		body = short_src .. ":" .. line_number .. ":"
	end

	local complete_line = head .. " " .. body .. " " .. line
	if M.print == true then M.print_f(complete_line) end
end

function M.toggle_print()
	if M.print then
		M.print = false
	else
		M.print = true
	end
end

function M.toggle_logging()
	if M.logging then
		M.logging = false
	else
		M.logging = true
	end
end

return M