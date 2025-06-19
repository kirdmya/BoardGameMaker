local Logger = require("utils.logger")

local Discard = {}
Discard.__index = Discard

local next_discard_id = 1

function Discard.new(name)
    local self = setmetatable({}, Discard)
    self.id = next_discard_id
    next_discard_id = next_discard_id + 1

    self.name = name or "Discard"
    self.items = {}
    Logger.log("Создан сброс: " .. self.name)
    return self
end

function Discard:add(item)
    table.insert(self.items, item)
    Logger.log("В сброс помещён: " .. (item and item.name or tostring(item)))
end

function Discard:take()
    local taken = table.remove(self.items)
    Logger.log("Из сброса взят: " .. (taken and taken.name or tostring(taken)))
    return taken
end

function Discard:get_top()
    return self.items[#self.items]
end

function Discard:clear()
    self.items = {}
end


function Discard:serialize()
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
        type = "discard",
        id = self.id,
        name = self.name,
        items = item_refs,
    }
end

function Discard.from_table(tbl)
    local self = setmetatable({}, Discard)
    self.id = tbl.id
    self.name = tbl.name or "Discard"
    self.items = tbl.items or {}
    return self
end

return Discard
