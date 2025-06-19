local Logger = require("utils.logger")

local Zone = {}
Zone.__index = Zone

local next_zone_id = 1

function Zone.new(name)
    local self = setmetatable({}, Zone)
    self.id = next_zone_id
    next_zone_id = next_zone_id + 1

    self.name = name or "Zone"
    self.items = {} 
    Logger.log("Создана зона: " .. self.name)
    return self
end

function Zone:add(item)
    table.insert(self.items, item)
    Logger.log("В зону добавлен предмет: " .. (item and item.name or tostring(item)))
end

function Zone:remove(item)
    for i, it in ipairs(self.items) do
        if it == item then
            table.remove(self.items, i)
            Logger.log("Из зоны убран предмет: " .. (item and item.name or tostring(item)))
            return item
        end
    end
end

function Zone:get_top()
    return self.items[#self.items]
end

function Zone:clear()
    self.items = {}
end

function Zone:contains(item)
    for _, it in ipairs(self.items) do
        if it == item then return true end
    end
    return false
end


function Zone:serialize()
    local item_refs = {}
    for _, item in ipairs(self.items) do
        if type(item) == "table" and item.id then
            table.insert(item_refs, item.id)
        elseif type(item) == "table" and item.name then
            table.insert(item_refs, item.name)
        else
            table.insert(item_refs, item)
        end
    end
    return {
        type = "zone",
        id = self.id,
        name = self.name,
        items = item_refs,
    }
end

function Zone.from_table(tbl)
    local self = setmetatable({}, Zone)
    self.id = tbl.id
    self.name = tbl.name or "Zone"
    self.items = tbl.items or {}
    return self
end

return Zone
