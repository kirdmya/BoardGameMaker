local Logger = require("utils.logger")

local Field = {}
Field.__index = Field

local next_field_id = 1

function Field.new(name, size)
    local self = setmetatable({}, Field)
    self.id = next_field_id
    next_field_id = next_field_id + 1

    self.name = name or "Field"
    self.size = size or {width=0, height=0}
    self.cells = {} 
    Logger.log("Создано игровое поле: " .. self.name)
    return self
end

function Field:serialize()
    local serial_cells = {}
    for k, obj in pairs(self.cells) do
        if type(obj) == "table" and obj.id then
            serial_cells[k] = obj.id
        elseif type(obj) == "table" and obj.name then
            serial_cells[k] = obj.name
        else
            serial_cells[k] = obj
        end
    end
    return {
        type = "field",
        id = self.id,
        name = self.name,
        size = self.size,
        cells = serial_cells,
    }
end

function Field.from_table(tbl)
    local self = setmetatable({}, Field)
    self.id = tbl.id
    self.name = tbl.name or "Field"
    self.size = tbl.size or {width=0, height=0}
    self.cells = tbl.cells or {}
    return self
end

return Field
