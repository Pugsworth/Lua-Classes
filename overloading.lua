local inspect = require("inspect")



local signature_types = {
    [ "number" ]   = 0x1,
    [ "string" ]   = 0x2,
    [ "boolean" ]  = 0x4,
    [ "table" ]    = 0x8,
    [ "function" ] = 0x10,
    [ "userdata" ] = 0x20,
    [ "thread" ]   = 0x40,
    [ "nil" ]      = 0x80,
    [ "any" ]      = 0xFF,
}


--- Generate a short string of all the arguments
local function hash(...)
    local args = {...}
    local str = ""
    local _hash = 8129

    -- Given a series of string(able) arguments, generate a hash where each character is converted to the ASCII value of the character

    for i = 1, #args do
        local arg = tostring(args[i])

        for j = 1, #arg do
            local char = string.sub(arg, j, j)
            local byte = string.byte(char)

            -- hash = ((hash << 5) + hash) + j
            _hash = (31 * _hash + byte) % 2^32
        end
    end

    -- Then, convert the hash to a base64 string
    local base64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local base64_str = ""

    while _hash > 0 do
        local remainder = _hash % 64
        _hash = math.floor(_hash / 64)

        base64_str = string.sub(base64, remainder, remainder) .. base64_str
    end

    return base64_str
end

--- Generate the signature hash from a list of types
---@param types string[] List of types
local function signature(types)
    local sig = 0

    for i = 1, #types do
        local kind = types[i]
        local type_sig = signature_types[kind]

        if not type_sig then
            error(string.format("Unknown type %s", kind))
        end

        sig = sig + type_sig
    end

    return sig
end

--- Create a new overloaded function
local function func(self, ...)
    local args = {...}
    local func = args[#args]
    args[#args] = nil
    local sig = signature(args)

    self._overloads[sig] = func

    return func
end

--- Dispatches the given args to the correct overloaded function
local function dispatch(self, ...)
    local args = {...}
    local types = {}
    for i = 1, #args do
        local arg_type = type(args[i])
        table.insert(types, arg_type)
    end
    local sig = signature(types)

    if self._overloads[sig] then
        return self._overloads[sig](...)
    end

    error("No overload found for given arguments", 2)
end

--- Create a new table for building an overloaded function. Call the table to dispatch the arguments to the correct overloaded function
local function overload()
    local obj = {
        func = func,
        _signatures = {},
        _overloads = {}
    }
    local meta = {
        __call = function(...)
            return dispatch(obj, ...)
        end,
    }

    meta.__index = function(self, key)
        local value = rawget(self, key)
        if value == nil then
            return value
        else
            return rawget(meta, key)
        end
    end

    return setmetatable(obj, meta)
end


local class = overload()
print(
    inspect.inspect(class)
)

local mainfunc = class:func("string", "string", "table", function(name, base, body)
    print("string", "string", "table")
end)
class:func("string", "table", function(name, body)
    print("string", "table")
end)
class:func("string", "string", function(name, base)
    print("string", "string")
end)
class:func("string", function(name)
    print("string")
end)
-- class:build()

mainfunc()
class("test")
class("Hello", "World!")