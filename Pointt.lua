local dbg = require("debugger")


--[[
    This is a traditional lua class implementation that mimics the following OOP class structure:

    ```C++
    class Point
    {
        protected:
        float m_x = 0;
        float m_y = 0;

        public:
        Point(float _x, float _y): m_x(_x), m_y(_y) {}

        float getX() {
            return this->m_x;
        }

        void setX(float _x) {
            this->m_x = _x;
        }

        float getY() {
            return this->m_y;
        }

        void setY(float _y) {
            this->m_y = _y;
        }

        char * c_str() {
            char *buffer = (char*)calloc(32, sizeof(char));
            snprintf(buffer, 32, "Point(%.3g, %.3g)", this->m_x, this->m_y);
            return buffer;
        }
        
        Point operator+(Point other) {
            return Point(this->getX() + other.getX(), this->getY() + other.getY());
        }
        
        Point operator+(float other) {
            return Point(this->getX() + other, this->getY() + other);
        }
    };
    ```


    ```C#
    class Point
    {
        private float x;
        private float y;
        
        public Point(float _x, float _y) {
            x = _x; y = _y;
        }
        
        public float GetX() { return x; }
        public float GetY() { return y; }
        public void SetX(float _x) { x = _x; }
        public void SetY(float _y) { y = _y; }
        
        public static Point operator +(Point a, float b) {
            return new Point(a.GetX() + b, a.GetY() + b);
        }
        
        public static Point operator +(Point a, Point b) {
            return new Point(a.GetX() + b.GetX(), a.GetY() + b.GetY());
        }
        
        public override string ToString() {
            return String.Format("Point({0:0.##}, {1:0.##})", GetX(), GetY());
        }
    }
    ```
--]]

local EQ_EPSILON = 0.0001

-- "Class" metatable for new instances
local Point = {__type="Point"}
Point.__index = Point

Point.new = function(_x, _y)
    local self = {x=_x, y=_y}
    setmetatable(self, Point)
    return self
end

Point.__tostring = function(self)
    return string.format("Point(%.2g, %.2g)", self.x, self.y)
end

Point.__add = function(self, other)
    local other_type = type(other)
    if other_type == "number" then
        return Point.new(self.x + other, self.y + other)
    elseif other_type == "table" and other.__type == "Point" then
        return Point.new(self.x + other.x, self.y + other.y)
    end
end

Point.__sub = function(self, other)
    local other_type = type(other)
    if other_type == "number" then
        return Point.new(self.x - other, self.y - other)
    elseif other_type == "table" and other.__type == "Point" then
        return Point.new(self.x - other.x, self.y - other.y)
    end
end

Point.__mul = function(self, other)
    local other_type = type(other)
    if other_type == "number" then
        return Point.new(self.x * other, self.y * other)
    elseif other_type == "table" and other.__type == "Point" then
        return Point.new(self.x * other.x, self.y * other.y)
    end
end

Point.__div = function(self, other)
    local other_type = type(other)
    if other_type == "number" then
        return Point.new(self.x / other, self.y / other)
    elseif other_type == "table" and other.__type == "Point" then
        return Point.new(self.x / other.x, self.y / other.y)
    end
end

Point.__eq = function(self, other)
    return math.abs(self.x - other.x) < EQ_EPSILON and math.abs(self.y - other.y) < EQ_EPSILON
end

Point.__lt = function(self, other)
    return self.x < other.x and self.y < other.y
end

Point.__le = function(self, other)
    return self.x <= other.x and self.y <= other.y
end

Point.__unm = function(self)
    return Point.new(-self.x, -self.y)
end

Point.__len = function(self)
    return math.sqrt(self.x * self.x + self.y * self.y)
end

setmetatable(Point, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

return Point