local Logger = require("utils.logger")

local Dice = {}
Dice.__index = Dice

function Dice.new(name)
    local self = setmetatable({}, Dice)
    self.name = name or "Dice"
    self.value = nil   
    self.state = "empty"
    Logger.log("Создан кубик: " .. self.name)
    return self
end

function Dice:roll()
    self.value = math.random(1, 6)
    self.state = "rolled"
    Logger.log(string.format("Кубик '%s' брошен. Выпало: %d", self.name, self.value))
    return self.value
end

function Dice:get_value()
    return self.value
end

function Dice:reset()
    self.value = nil
    self.state = "empty"
    Logger.log("Кубик '" .. self.name .. "' сброшен (empty).")
end

function Dice:set_question()
    self.state = "question"
    self.value = nil
    Logger.log("Кубик '" .. self.name .. "': состояние question.")
end

function Dice:get_sprite_path()
    if self.state == "empty" then
        return "assets/entities/dice/dice_empty.png"
    elseif self.state == "question" then
        return "assets/entities/dice/dice_question.png"
    elseif self.value and self.value >= 1 and self.value <= 6 then
        return ("assets/entities/dice/dice_%d.png"):format(self.value)
    else
        return "assets/entities/dice/dice_empty.png"
    end
end

function Dice:serialize()
    return {
        name = self.name,
        value = self.value,
        state = self.state,
    }
end

function Dice.from_table(tbl)
    local self = Dice.new(tbl.name)
    self.value = tbl.value
    self.state = tbl.state or "empty"
    return self
end

return Dice
