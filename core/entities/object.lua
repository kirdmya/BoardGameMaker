local Logger = require("utils.logger")

local Object = {}
Object.__index = Object

local next_object_id = 1

function Object.new(name, props)
    local self = setmetatable({}, Object)
    self.id = next_object_id
    next_object_id = next_object_id + 1

    self.name = name
    self.props = props or {} 
    Logger.log("Создан объект: " .. tostring(name))
    return self
end

function Object:serialize()
    return {
        type = "object",
        id = self.id,
        name = self.name,
        props = self.props,
    }
end

function Object.from_table(tbl)
    local self = setmetatable({}, Object)
    self.id = tbl.id
    self.name = tbl.name
    self.props = tbl.props or {}
    return self
end

return Object
