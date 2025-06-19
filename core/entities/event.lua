local Logger = require("utils.logger")

local Event = {}
Event.__index = Event

local next_event_id = 1

function Event.new(event_type, data)
    local self = setmetatable({}, Event)
    self.id = next_event_id
    next_event_id = next_event_id + 1

    self.event_type = event_type
    self.data = data or {}
    Logger.log("Событие: " .. tostring(event_type))
    return self
end


function Event:serialize()
    local serialized_data = {}
    for k, v in pairs(self.data) do
        if type(v) == "table" and v.id then
            serialized_data[k] = v.id
        elseif type(v) == "table" and v.name then
            serialized_data[k] = v.name
        else
            serialized_data[k] = v
        end
    end
    return {
        type = "event",
        id = self.id,
        event_type = self.event_type,
        data = serialized_data,
    }
end

-- Десериализация события из таблицы
function Event.from_table(tbl)
    local self = setmetatable({}, Event)
    self.id = tbl.id
    self.event_type = tbl.event_type
    self.data = tbl.data or {}
    return self
end

return Event
