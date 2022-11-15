---@type table{ [string] = table }
local classes = {}

--- Create a pure lua class and return the table
---@param name string The name of the class
---@param body table The class table
function class(name, body)
    if classes[name] ~= nil then
        error(string.format("Class '%s' already defined!", name))
        return
    end

    --[[
        The returned class table should only contain the constructor and "static" methods
    ]]
    -- The constructed class table returned by this function
    local class_table = {}

    local class_table_meta = {
        __name = name,
        __base = nil,
        __call = function(self, ...)
            local instance = setmetatable(body, self)
            if instance.new ~= nil then
                instance:new(self, ...)
            end
            return instance
        end,
        __index = function(self, key)
            if self[key] ~= nil then
                return self[key]
            end
            return self.__base[key]
        end,
        -- Seal the class from adding anything besides new methods
        __newindex = function(self, key, value)
            if type(value) == "function" then
                -- Add the function to the class table
                -- TODO: Check if the function already exists
                classes[name][key] = value
            else
                error(string.format("Cannot add '%s' to class '%s'", key, name))
            end
        end

    }

    -- Add any functions prefixed with __ from the body table into the meta table and remove them from the body table
    for k,v in pairs(body) do
        if string.sub(k, 1, 2) == "__" then
            class_table_meta[k] = v
            body[k] = nil
        end
    end

    setmetatable(class_table, class_table_meta)

    classes[name] = class_table

    return class_table
end


return class