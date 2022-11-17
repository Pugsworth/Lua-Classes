local dbg = require("debugger")


-- TODO: Provide a way to "compile" the class so as to be more performant.
--   Compiling may require generating Lua code from an AST, which might be overkill.



---@type table{ [string] = table }
local classes = {}


--- Returns the class table definition.
---@param name string
---@return table or nil
local function get(name)
    return classes[name]
end


--- Checks if the table is a class type.
---@param obj any
---@@return boolean Is the table a class type?
local function is_class(obj)
    return type(obj) == "table" and obj.__name ~= nil
end


--- Returns the name of the class.
---@param obj table
---@return string The name of the class.
local function _type(obj)
    return is_class(obj) and obj.__name or type(obj)
end


--- Defines a field as protected (Accessible only by the class and its children)
---@param value any
local function protected(value)
    return { value = value, accessor = "protected" }
end


--- Defines a field as private (Accessible only by the class)
---@param value any
local function private(value)
    return { value = value, accessor = "private" }
end


--- Mark a method as virtual. This is useful for creating abstract classes or interfaces.
local function virtual()
end


--- Initialize the fields from tab into a new fields table.
---@param body table{ [string] = any }
---@return table fields
local function init_fields(body)
    local fields = {}

    for k, v in pairs(body) do
        -- TODO: Implement getters and setters
        if type(v) == "table" and v.accessor then
            fields[k] = v
        else
            fields[k] = { value = v, accessor = "public" }
        end
    end

    return fields
end

local function create_instance(class_table, fields, ...)
    local instance = setmetatable({}, class_table)
    instance.__fields = fields
end

local function create_constructor(class_table, ctor)
end

local function class_exists(name)
    return classes[name]
end


--- Create a pure lua class and return the table
--- Class provides a standardized factory for creating "classes" in Lua.
--- It does this by providing a constructor and a metatable for the class.
--- TODO: Add support for inheritance
--- TODO: Add support for field accessors?
--- TODO: Add support for static methods
---@param name string The name of the class
---@param base (string | nil) The name of the base class
local function class(name, base)
    if class_exists(name) then
        error(string.format("Class '%s' already exists!", name), 2)
    end
    if base ~= nil and not class_exists(base) then
        error(string.format("Base class '%s' does not exist!", base), 2)
    end

    -- Add the fields to the class
    -- local fields = init_fields(body)

    --[[
        The returned class table should only contain the constructor and "static" methods
    ]]
    -- The constructed class table returned by this function
    -- new:
    --  - constructs a new instance of the class and calls the constructor passed in

    -- class_table mimics the functionality of a class "object" being any fields or methods defined are shared by all instances of the class
    local class_table = {
        __class = name,
        __base = base,
        -- Methods defined in the class table are stored here.
        -- This table is added to classes[name] when the class is created.
    }

    local class_meta = {
        __new = function() end, -- Called by __ctor, set by user after class is created (__newindex)
        __ctor = function(self, instance, ...) -- Called by __call
            self.__new(instance, ...)
        end,
    }

    -- () operator
    function class_meta.__call(self, ...)
        -- Construct a new instance of the class and call the ctor of the new instance
        local instance = setmetatable({}, instance_meta)
        class_meta.__ctor(self, instance, ...)
        -- Call __ctor on the metatable

        return instance
    end

    -- Fetch
    function class_meta.__index(self, key)
        if key == "new" then
            return self.__call
        else
            -- Check for the key on self, then on the base class, then on the metatable
            local value = rawget(self, key)
            if value ~= nil then
                return value
            end

            local _base = rawget(self, "__base")
            if _base ~= nil then
                value = rawget(_base, key)
                if value ~= nil then
                    return value
                end
            end

            return rawget(getmetatable(self), key)
        end
    end

    -- Store
    function class_meta.__newindex(self, key, value)
        if key == "new" and type(value) == "function" then
            self.__new = value
        else
            rawset(self, key, value)
        end
    end

    -- dbg()

    setmetatable(class_table, class_meta)

    classes[name] = class_table

    return class_table
end


return {
    class     = class,
    get       = get,
    is_class  = is_class,
    type      = _type,
    private   = private,
    protected = protected
}