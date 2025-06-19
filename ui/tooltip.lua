local Tooltip = {}
Tooltip.__index = Tooltip

local Fonts = require("assets.fonts")

function Tooltip.new()
    local self = setmetatable({}, Tooltip)
    self.text = nil
    self.visible = false
    self.x, self.y = 0, 0
    self.timer = 0
    self.delay = 1.0
    return self
end

function Tooltip:show(text, x, y)
    if self.text ~= text then
        self.text = text
        self.timer = 0
        self.visible = false
        self.x, self.y = x, y
    end
end

function Tooltip:hide()
    self.visible = false
    self.text = nil
    self.timer = 0
end

function Tooltip:update(dt)
    if self.text then
        self.timer = self.timer + dt
        if self.timer >= self.delay then
            self.visible = true
        end
    else
        self.visible = false
        self.timer = 0
    end
end

function Tooltip:draw()
    if self.visible and self.text then
        love.graphics.setFont(Fonts.small or love.graphics.getFont())
        local padding = 10
        local maxWidth = 320
        local lines = {}
        for line in self.text:gmatch("[^\n]+") do table.insert(lines, line) end
        local w, h = 0, #lines * Fonts.small:getHeight() + padding * 2
        for _, line in ipairs(lines) do
            w = math.max(w, Fonts.small:getWidth(line))
        end
        w = math.min(w, maxWidth) + padding * 2

        local mx, my = love.mouse.getPosition()
        local tx = math.min(mx + 24, love.graphics.getWidth() - w - 8)
        local ty = math.min(my + 18, love.graphics.getHeight() - h - 8)

        love.graphics.setColor(0, 0, 0, 0.92)
        love.graphics.rectangle("fill", tx, ty, w, h, 10, 10)
        love.graphics.setColor(0.89, 0.89, 1)
        for i, line in ipairs(lines) do
            love.graphics.print(line, tx + padding, ty + padding + (i-1)*Fonts.small:getHeight())
        end
        love.graphics.setColor(1,1,1,1)
    end
end

return Tooltip
