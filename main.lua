local classes = require("class")
local inspect = require("inspect")
local dbg = require("debugger")

-- TODO: Find a way to use modules like Typescript (import { Class } from "class")
local class = classes.class
local private = classes.private
local protected = classes.protected

---@class Point
-- local Point = class("Point", {
--     m_x = protected(0),
--     m_y = protected(0),
-- })

local Point = class("Point")

function Point.new(self, _x, _y)
    self.m_x = _x
    self.m_y = _y
end

function Point.__tostring(self)
    return string.format("Point(%d, %d)", self.m_x, self.m_y)
end

function Point.__add(self, other)
    local other_type = type(other)

    if other_type == "number" then
        return Point(self.m_x + other, self.m_y + other)
    elseif other_type == "Point" then
        return Point(self.m_x + other.m_x, self.m_y + other.m_y)
    end

    error(string.format("Cannot add Point to %s", other_type))
end

-- Constructor can be called in one of 2 ways
-- Type 1
local p = Point(1, 2)
print("The tables:")
print(inspect.inspect(p))
print(inspect.inspect(getmetatable(p)))



-- Type 2
local p2 = Point.new(3, 4)
dbg()

print("Point table:")
print(inspect(Point))

print("\nPoint instance:")
print(inspect(p))

print("\nThe table:")
print(p)

print("The table + 2")
print(p + 2)

print("\ninstance metatable")
print(inspect(getmetatable(p)))
