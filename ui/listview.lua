local ListView = {}
ListView.__index = ListView

local Fonts = require("assets.fonts")

function ListView.new(x, y, w, h, items, opts)
    opts = opts or {}
    local self = setmetatable({}, ListView)
    self.x, self.y, self.w, self.h = x, y, w, h
    self.items = items or {}
    self.itemHeight = opts.itemHeight or 40
    self.font = opts.font or Fonts.normal
    self.onClick = opts.onClick
    self.scrollY = 0
    self.maxScroll = math.max(0, #self.items * self.itemHeight - self.h)
    self.selected = opts.selected or nil
    self.bgColor = opts.bgColor or {0.15,0.18,0.28}
    self.itemColor = opts.itemColor or {0.19,0.22,0.34}
    self.itemHover = opts.itemHover or {0.23,0.39,0.61}
    self.textColor = opts.textColor or {1,1,1}
    self.radius = opts.radius or 10
    self.hoverIdx = nil
    return self
end

function ListView:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hoverIdx = nil
    if mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h then
        local relY = my - self.y + self.scrollY
        local idx = math.floor(relY / self.itemHeight) + 1
        if idx >= 1 and idx <= #self.items then
            self.hoverIdx = idx
        end
    end
end

function ListView:draw()
    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.radius, self.radius)
    love.graphics.setScissor(self.x, self.y, self.w, self.h)

    love.graphics.setFont(self.font)
    for i, item in ipairs(self.items) do
        local iy = self.y + (i-1)*self.itemHeight - self.scrollY
        if iy + self.itemHeight > self.y and iy < self.y + self.h then
            if self.selected == i then
                love.graphics.setColor(0.32, 0.6, 1)
            elseif self.hoverIdx == i then
                love.graphics.setColor(self.itemHover)
            else
                love.graphics.setColor(self.itemColor)
            end
            love.graphics.rectangle("fill", self.x, iy, self.w, self.itemHeight)
            love.graphics.setColor(self.textColor)
            love.graphics.printf(tostring(item), self.x+16, iy + self.itemHeight/2 - self.font:getHeight()/2, self.w-20, "left")
        end
    end

    love.graphics.setScissor()
    love.graphics.setColor(0.32, 0.41, 0.57)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.radius, self.radius)
end

function ListView:mousepressed(x, y, button)
    if button ~= 1 then return false end
    if x < self.x or x > self.x+self.w or y < self.y or y > self.y+self.h then return false end
    if self.hoverIdx then
        self.selected = self.hoverIdx
        if self.onClick then self.onClick(self.items[self.hoverIdx], self.hoverIdx) end
        return true
    end
end

function ListView:wheelmoved(dx, dy)
    self.scrollY = math.max(0, math.min(self.scrollY - dy*32, math.max(0, #self.items*self.itemHeight - self.h)))
end

return ListView
