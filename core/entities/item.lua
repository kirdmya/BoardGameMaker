local Logger = require("utils.logger")

local Item = {}
Item.__index = Item

local next_item_id = 1

function Item.new(name, props)
    local self = setmetatable({}, Item)
    self.id = next_item_id
    next_item_id = next_item_id + 1

    self.name = name
    self.props = props or {}  
    Logger.log("Создан предмет: " .. tostring(name))
    return self
end

function Item:serialize()
    return {
        type = "item",
        id = self.id,
        name = self.name,
        props = self.props,
    }
end

function Item.from_table(tbl)
    local self = setmetatable({}, Item)
    self.id = tbl.id
    self.name = tbl.name
    self.props = tbl.props or {}
    return self
end

return Item
