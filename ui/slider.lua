local Slider = {}
Slider.__index = Slider

local Fonts = require("assets.fonts")
local Logger = require("utils.logger")

function Slider.new(x, y, w, h, value, onChange)
    local self = setmetatable({}, Slider)
    self.x = x
    self.y = y
    self.w = w or 300
    self.h = h or 32
    self.value = math.floor(value or 0)
    self.onChange = onChange or function() end
    self.dragging = false
    self.hovered = false
    self.handleRadius = math.floor(self.h/2 + 4)
    return self
end


function Slider:getValue()
    return self.value
end

function Slider:setValue(val)
    local clamped = math.max(0, math.min(100, math.floor(val)))
    if self.value ~= clamped then
        self.value = clamped
        self.onChange(self.value)
    end
end

function Slider:_valueToX()
    return self.x + (self.w - self.handleRadius*2) * (self.value / 100) + self.handleRadius
end

function Slider:_xToValue(mx)
    local rel = (mx - self.x - self.handleRadius) / (self.w - self.handleRadius*2)
    local v = math.floor(rel * 100 + 0.5)
    return math.max(0, math.min(100, v))
end

function Slider:draw()
    love.graphics.setColor(0.22, 0.27, 0.38)
    love.graphics.setLineWidth(6)
    love.graphics.line(self.x + self.handleRadius, self.y + self.h/2, self.x + self.w - self.handleRadius, self.y + self.h/2)

    local handleX = self:_valueToX()
    love.graphics.setColor(0.17, 0.53, 0.85)
    love.graphics.setLineWidth(8)
    love.graphics.line(self.x + self.handleRadius, self.y + self.h/2, handleX, self.y + self.h/2)

    if self.dragging then
        love.graphics.setColor(1, 0.86, 0.3)
    elseif self.hovered then
        love.graphics.setColor(0.8, 0.9, 1)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.circle("fill", handleX, self.y + self.h/2, self.handleRadius)
    love.graphics.setColor(0.4, 0.47, 0.62)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", handleX, self.y + self.h/2, self.handleRadius)
end

function Slider:update(dt)
    local mx, my = love.mouse.getPosition()
    local handleX = self:_valueToX()
    self.hovered = (mx - handleX)^2 + (my - (self.y + self.h/2))^2 <= self.handleRadius^2
        or (mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h)
end

function Slider:mousepressed(x, y, button)
    local handleX = self:_valueToX()
    if button == 1 then
        if (x - handleX)^2 + (y - (self.y + self.h/2))^2 <= self.handleRadius^2 then
            self.dragging = true
            return true
        elseif (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h) then
            self:setValue(self:_xToValue(x))
            return true
        end
    end
    return false
end

function Slider:keypressed(key)
    if key == "escape" then
        self.dragging = false
    end
end


function Slider:mousereleased(x, y, button)
    if button == 1 and self.dragging then
        self.dragging = false
        return true
    end
    return false
end

function Slider:mousemoved(x, y, dx, dy, istouch)
    if self.dragging then
        self:setValue(self:_xToValue(x))
    end
end

return Slider
