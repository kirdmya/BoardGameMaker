local NumberInput = {}
NumberInput.__index = NumberInput

local Fonts = require("assets.fonts")

function NumberInput.new(x, y, w, h, value, onChange)
    local self = setmetatable({}, NumberInput)
    self.x, self.y, self.w, self.h = x, y, w or 64, h or 36
    self.value = tostring(value or 0)
    self.onChange = onChange or function() end
    self.active = false
    self.lastValid = tostring(value or 0)
    return self
end

function NumberInput:update(dt) end 

function NumberInput:draw()
    love.graphics.setColor(self.active and {0.6,0.85,1} or {0.22,0.27,0.38})
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 8, 8)
    love.graphics.setColor(0.32, 0.41, 0.57)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 8, 8)
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(self.value, self.x+6, self.y + self.h/2 - Fonts.normal:getHeight()/2, self.w-12, "center")
end

function NumberInput:mousepressed(x, y, button)
    if button == 1 and x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
        self.active = true
        self.value = ""
        return true
    else
        self.active = false
        local num = tonumber(self.value)
        if not (num and num >= 0 and num <= 100) then
            self.value = self.lastValid
        end
    end
    return false
end


function NumberInput:textinput(t)
    if self.active and #self.value < 3 and t:match("%d") then
        self.value = self.value .. t
    end
end

function NumberInput:keypressed(key)
    if self.active then
        if key == "backspace" then
            self.value = self.value:sub(1, -2)
        elseif key == "return" or key == "kpenter" then
            local num = tonumber(self.value)
            if num and num >= 0 and num <= 100 then
                self.lastValid = tostring(num)
                self.onChange(num)
            else
                self.value = self.lastValid
            end
            self.active = false
        elseif key == "escape" then
            self.value = self.lastValid
            self.active = false
        end
    end
end

return NumberInput
