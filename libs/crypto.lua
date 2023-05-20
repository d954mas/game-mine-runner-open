local function repeat_key(key, length)
    if #key >= length then
        return key:sub(1, length)
    end

    local times = math.floor(length / #key)
    local remain = length % #key

    local result = ''

    for i = 1, times do
        result = result .. key
    end

    if remain > 0 then
        result = result .. key:sub(1, remain)
    end

    return result
end

local function xor(num1, num2)
    local tmp1 = num1
    local tmp2 = num2
    local str = ""
    repeat
        local s1 = tmp1 % 2
        local s2 = tmp2 % 2
        if s1 == s2 then
            str = "0" .. str
        else
            str = "1" .. str
        end
        tmp1 = math.modf(tmp1 / 2)
        tmp2 = math.modf(tmp2 / 2)
    until (tmp1 == 0 and tmp2 == 0)
    return tonumber(str, 2)
end

local function cryptXor(message, key)
    local rkey = repeat_key(key, #message)

    local result = ''

    for i = 1, #message do
        local k_char = rkey:sub(i, i)
        local m_char = message:sub(i, i)

        local k_byte = k_char:byte()
        local m_byte = m_char:byte()

        local xor_byte = xor(m_byte, k_byte)

        local xor_char = string.char(xor_byte)

        result = result .. xor_char
    end

    return result
end
--[[
local function cryptDefsave(input, key)
    local output = ""
    local key_iterator = 1

    local input_length = #input
    local key_length = #key

    for i = 1, input_length do
        local character = string.byte(input:sub(i, i))
        if key_iterator >= key_length + 1 then key_iterator = 1 end -- cycle
        local key_byte = string.byte(key:sub(key_iterator, key_iterator))
        output = output .. string.char(bit.bxor(character, key_byte))

        key_iterator = key_iterator + 1

    end
    return output
end
--]]
local M = {}

M.crypt = cryptXor

return M