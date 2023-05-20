--
-- lume
--
-- Copyright (c) 2018 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local lume = { _version = "2.3.0" }

local pairs, ipairs = pairs, ipairs
local type, assert = type, assert
local tostring, tonumber = tostring, tonumber
local math_floor = math.floor
local math_ceil = math.ceil
local math_atan2 = math.atan2
local math_abs = math.abs
local table_remove = table.remove
local math_random = math.random

function lume.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function lume.round(x, increment)
	if increment then return lume.round(x / increment) * increment end
	return x >= 0 and math_floor(x + .5) or math_ceil(x - .5)
end

function lume.sign(x)
	return x < 0 and -1 or 1
end

local patternescape = function(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

function lume.angle(x1, y1, x2, y2)
	return math_atan2(y2 - y1, x2 - x1)
end

--counter-clockwise angles [0,360]
--https://stackoverflow.com/questions/14066933/direct-way-of-computing-clockwise-angle-between-2-vectors
function lume.angle2(x1, y1, x2, y2)
	local dot = x1 * x2 + y1 * y2      --# dot product between [x1, y1] and [x2, y2]
	local det = x1 * y2 - y1 * x2      --# determinant
	return math_atan2(det, dot)
end

function lume.angle_vector(x, y)
	return math_atan2(y, x)
end

function lume.normalize_angle_deg(deg)
	deg = deg % 360;
	if (deg < 0) then deg = deg + 360 end
	return deg
end

function lume.normalize_angle_rad(rad)
	return math.rad(lume.normalize_angle_deg(math.deg(rad)))
end

function lume.random(a, b)
	if not a then
		a, b = 0, 1
	end
	if not b then
		b = 0
	end
	return a + math_random * (b - a)
end

function lume.randomchoice(t)
	return t[math_random(#t)]
end

function lume.randomchoice_remove(t)
	return table_remove(t, math_random(#t))
end

function lume.weightedchoice(t)
	local sum = 0
	for _, v in pairs(t) do
		assert(v >= 0, "weight value less than zero")
		sum = sum + v
	end
	assert(sum ~= 0, "all weights are zero")
	local rnd = lume.random(sum)
	for k, v in pairs(t) do
		if rnd < v then
			return k
		end
		rnd = rnd - v
	end
end

function lume.removei(t, value)
	for k, v in ipairs(t) do
		if v == value then
			return table_remove(t, k)
		end
	end
end

function lume.clearp(t)
	for k, v in pairs(t) do
		t[k] = nil
	end
	return t
end
function lume.cleari(t)
	for i = 1, #t do
		t[i] = nil
	end
	return t
end

function lume.shuffle(t)
	local rtn = {}
	for i = 1, #t do
		local r = math_random(i)
		if r ~= i then
			rtn[i] = rtn[r]
		end
		rtn[r] = t[i]
	end
	return rtn
end

function lume.iftern(bool, vtrue, vfalse)
	if bool then return vtrue else return vfalse end
end

function lume.find(t, value)
	for k, v in pairs(t) do
		if v == value then
			return k
		end
	end
	return nil
end

function lume.findi(t, value)
	for k, v in ipairs(t) do
		if v == value then
			return k
		end
	end
	return nil
end

---@generic T
---@param t T
---@return T
function lume.clone_shallow(t)
	local rtn = {}
	for k, v in pairs(t) do rtn[k] = v
	end
	return rtn
end

function lume.clone_deep(t)
	local orig_type = type(t)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, t, nil do
			copy[lume.clone_deep(orig_key)] = lume.clone_deep(orig_value)
		end
	else
		-- number, string, boolean, etc
		copy = t
	end
	return copy
end

local serialize

local serialize_map = {
	["boolean"] = tostring,
	["nil"] = tostring,
	["string"] = function(v) return string.format("%q", v)
	end,
	["number"] = function(v)
		if v ~= v then
			return "0/0"      --  nan
		elseif v == 1 / 0 then
			return "1/0"      --  inf
		elseif v == -1 / 0 then
			return "-1/0"
		end -- -inf
		return tostring(v)
	end,
	["table"] = function(t, stk)
		stk = stk or {}
		if stk[t] then
			error("circular reference") end
		local rtn = {}
		stk[t] = true
		for k, v in pairs(t) do
			if k ~= "__fields__" then
				rtn[#rtn + 1] = " [" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
			end
		end
		stk[t] = nil
		return " {" .. table.concat(rtn, ", ") .. "}"
	end
}

setmetatable(serialize_map, {
	__index = function(_, k) error("unsupported serialize type: " .. k)
	end
})

serialize = function(x, stk)
	return serialize_map[type(x)](x, stk)
end

function lume.serialize(x)
	return serialize(x)
end

function lume.deserialize(str)
	return lume.dostring("return " .. str)
end

function lume.trim(str, chars)
	if not chars then
		return str:match("^[%s]*(.-)[%s]*$")
	end
	chars = patternescape(chars)
	return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

function lume.dostring(str)
	return assert((loadstring or load)(str))()
end


function lume.merge(...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		for k, v in pairs(t) do
			rtn[k] = v
		end
	end
	return rtn
end

function lume.merge_table(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k]) == "table" then
				lume.merge_table(t1[k], v)
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

function lume.mix_table(t1, t2)
	local t = {}
	for _, v in ipairs(t1) do
		table.insert(t, v)
	end
	for _, v in ipairs(t2) do
		table.insert(t, v)
	end
	return t
end




function lume.string_split(s, delimiter)
	local result = {};
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match);
	end
	return result;
end

function lume.string_replace_pattern(string, pattern, value)
	return string:gsub(pattern, value);
end

function lume.string_start_with(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

function lume.color_parse_hex(hex)
	local r, g, b, a = hex:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)")
	if a == "" then a = "ff" end
	if r and g and b and a then
		return vmath.vector4(tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255)
	end
	return nil
end

function lume.color_parse_hex2(hex)
	local a, r, g, b = hex:match("#(%x%x)(%x%x)(%x%x)(%x?%x?)")
	-- if a == "" then a = "ff" end
	if r and g and b and a then
		return vmath.vector4(tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255, tonumber(a, 16) / 255)
	end
	return nil
end

---@param url url
function lume.url_component_from_url(url, component)
	return msg.url(url.socket, url.path, component)
end

function lume.get_human_time(seconds)
	seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00";
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600));
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)));
		local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60));
		if hours == '00' then
			return mins .. ":" .. secs
		else
			return hours .. ":" .. mins .. ":" .. secs
		end
	end
end

function lume.equals_float(a, b, epsilon)
	epsilon = epsilon or 0.0001
	return (math_abs(a - b) < epsilon)
end

return lume
