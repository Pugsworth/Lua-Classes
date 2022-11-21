-- TODO: Provide a way to "compile" the class so as to be more performant.
--   Compiling may require generating Lua code from an AST, which might be overkill.

--[[
    'class' library should be able to:
    - Create a class ( Class(name) )
        - Inheritance ( Class(name, base_name) )
    - Instantiate a class ( Class.create(name) )
    - Provide a simple "type" system
        - Class.is_a(obj, name)
        - Class.typeof(obj)
    - Provide a simple "interface" system
        This will require a way to "create" an interface
        - Class.implements(obj, name)
        - Class.interface(name, prototype)


    Example of interface usage:

    ```Lua
    local IPoint = Class.interface("IPoint", {
        field("x", "y"),
        method("getX", "getY"),
    })

    local Point = Class.implements("Point", "IPoint")
    function Point.ctor(self, x, y)
        self.x = x
        self.y = y
    end


    function do_something(ipoint)
        if Class.implements(ipoint, "IPoint") then
            print(ipoint:get_x(), ipoint:get_y())
        end
    end
    ```
]]

-- Library table
Class = Class or {}


-- Stores the classes that have been created.
local classes = {
    --[[
    ["ClassName"] = {
        __class = "ClassName", -- Name of the class "type"
        __base = "BaseClassName", -- Name of the base class, if any
        __implements = { "InterfaceName" }, -- A list of interfaces that this class implements
        ... -- Everything else related to the class
    }
    ]]
}

-- Stores the interfaces that have been created. Is it even necessary to separate them?
local interfaces = {}


--[[ Library functions ]]
--[[ Class/Instance functions ]]

--- Returns the class table definition.
---@param name string
---@return table | nil
function Class.get(name)
    return classes[name]
end


--- Returns if the class or interface exists
---@param name string
---@return boolean
function Class.exists(name)
    return classes[name] ~= nil or interfaces[name] ~= nil
end


--- Checks if the given object is an instance of the given class or interface. Fails if not a class or interface.
---@param obj table
---@param comparand string
function Class.is_a(obj, comparand)
    return type(obj) == "table" and Class.typeof(obj) == "comparand"
end


--- Returns the class name of the given object. Returns type(obj) if not a class or interface.
--- TODO: Should this only return the class name and not use lua's built-in type() function?
---@param obj any
---@return string The class name of the object.
function Class.typeof(obj)
    return type(obj) == "table" and obj.__class or type(obj)
end


--- Returns the base class name of the given class. Returns nil if there is no base class.
---@param obj table
---@return string | nil The base class name of the object.
function Class.baseclass(obj)
    return type(obj) == "table" and obj.__base or nil
end


--- Creates a new class with the base class and interface names provided.
---@param name string Name of the class
---@param baseclass string | nil Name of the baseclass to inherit from.
---@param interface_names string[] Names of the interfaces this class implements.
function Class.create_class(name, baseclass, interface_names)
    -- Check name
    assert(not Class.exists(name), string.format("Class '%s' already exists.", name))
    -- Check baseclass
    if baseclass then
        assert(Class.exists(baseclass), string.format("Base class '%s' does not exist.", baseclass))
    end
    -- Check interfaces
    for _, iname in ipairs(interface_names) do
        assert(Class.exists(iname), string.format("Interface '%s' does not exist.", iname))
    end

    -- Build the class table and setup the metatable
    local class_table = {
        __class = name,
        __base = baseclass,
        __implements = interface_names,
    }

    -- TODO: How to handle the metatable?
    classes[name] = class_table

    return class_table
end


--- Creates a new class
---@param name string The name of the class to create.
---@return table The class table.
function Class.create(name)
    return Class.create_class(name, nil, {})
end


--- Creates a new class that inherits from another
--- TODO: How to inherit and implement?
---@param name string
---@param basename string
---@param interface_names string[] or nil
---@return table The class table.
function Class.inherits(name, basename, interface_names)
    return Class.create_class(name, basename, interface_names or {})
end


--- Creates a new class that implements the given interfaces.
--- TODO: Implement checking for interface implementations
---@param name string The name of the class to create.
---@param interface_names string[] List of names of interfaces to implement.
---@param basename string | nil The base class to inherit from
---@return table The class table.
function Class.implements(name, interface_names, basename)
    return Class.create_class(name, basename, interface_names)
end

---@class proto_t
---@field type "fields" | "methods"
---@field names string[]

--- Creates a new interface
---@param name string The name of the interface to create.
---@param prototype proto_t[] The prototype of the interface constructed using Class.fields and Class.methods.
---@return table The interface table.
function Class.interface(name, prototype)
    -- Check name
    assert(not Class.exists(name), string.format("Interface '%s' already exists.", name))

    -- Check prototype
    assert(type(prototype) == "table", "Interface prototype must be a table.")

    -- Compile the list of fields and methods into the prototype

    local proto = {
        fields = {},
        methods = {},
    }

    for _, obj in ipairs(prototype) do
        assert(type(obj) == "table", "Invalid Interface prototype must created with Class.fields and Class.methods.") 

        if obj.type == "fields" then
            for _, field in ipairs(obj) do
                table.insert(proto.fields, field)
            end
        elseif obj.type == "methods" then
            for _, method in ipairs(obj) do
                table.insert(proto.methods, method)
            end
        end
    end

    interfaces[name] = prototype
end


--- Describes a list of fields for an interface
---@param ... string
---@return table The list of fields
function Class.fields(...)
    local fields = {}

    for _, field in ipairs({...}) do
        fields[field] = true
    end

    return {
        type = "fields",
        names = fields
    }
end


--- Describes a list of methods for an interface
---@param ... string
---@return table The list of methods
function Class.methods(...)
    local methods = {}

    for _, method in ipairs({...}) do
        methods[method] = true
    end

    return {
        type = "methods",
        names = methods
    }
end




return Class