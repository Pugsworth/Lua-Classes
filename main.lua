local class = require("class")
local inspect = require("inspect")

local Point = class("Point", {
    m_x = 0,
    m_y = 0,
    new = function(self, _x, _y)
        self.m_x = _x
        self.m_y = _y
    end,
    __tostring = function(self)
        print("__tostring")
        return string.format("Point(%d, %d)", self.m_x, self.m_y)
    end,
    __add = function(self, other)
        local other_type = type(other)
        if other_type == "number" then
            return self.__call(self.m_x + other, self.m_y + other)
        elseif other_type == "Point" then
            return self.__call(self.m_x + other.m_x, self.m_y + other.m_y)
        end

        error(string.format("Cannot add Point to %s", other_type))
    end,
    
})

local p = Point(1, 2)

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
