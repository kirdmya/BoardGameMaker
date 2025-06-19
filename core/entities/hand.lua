local Logger = require("utils.logger")

local Hand = {}
Hand.__index = Hand

local next_hand_id = 1

function Hand.new(owner)
    local self = setmetatable({}, Hand)
    self.id = next_hand_id
    next_hand_id = next_hand_id + 1

    self.owner = owner
    self.items = {}
    Logger.log("Создана рука игрока: " .. (owner and owner.name or "unknown"))
    return self
end

function Hand:add(item)
    local name = "nil"
    if item then
        if type(item.get_display_name) == "function" then
            name = item:get_display_name()
        elseif item.name then
            name = item.name
        else
            name = tostring(item)
        end
    end
    table.insert(self.items, item)
    Logger.log("В руку добавлен предмет: " .. name)
end

function Hand:remove(item)
    local name = "nil"
    if item then
        if type(item.get_display_name) == "function" then
            name = item:get_display_name()
        elseif item.name then
            name = item.name
        else
            name = tostring(item)
        end
    end
    for i, it in ipairs(self.items) do
        if it == item then
            table.remove(self.items, i)
            Logger.log("Из руки убран предмет: " .. name)
            return item
        end
    end
end

function Hand:serialize()
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
        type = "hand",
        id = self.id,
        owner = self.owner and self.owner.id or self.owner,
        items = item_refs,
    }
end

function Hand.from_table(tbl)
    local self = setmetatable({}, Hand)
    self.id = tbl.id
    self.owner = tbl.owner 
    self.items = tbl.items or {}
    return self
end

return Hand
