local TabBar = {}
TabBar.__index = TabBar

local Fonts = require("assets.fonts")

function TabBar.new(x, y, w, tabs, opts)
    opts = opts or {}
    local self = setmetatable({}, TabBar)
    self.x = x
    self.y = y
    self.w = w
    self.tabs = tabs or {}
    self.selected = opts.selected or 1
    self.onChange = opts.onChange or function() end
    self.font = opts.font or Fonts.normal
    self.tabW = math.floor(w / #self.tabs)
    self.tabH = opts.tabH or 44
    self.radius = opts.radius or 10
    self.colors = opts.colors or {
        bg       = {0.19,0.23,0.33},
        normal   = {0.17, 0.27, 0.41},
        hover    = {0.25, 0.47, 0.79},
        selected = {0.32, 0.60, 1.00},
        outline  = {0.32, 0.41, 0.57},
        text     = {1, 1, 1},
    }
    self.hovered = nil
    return self
end

function TabBar:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = nil
    for i = 1, #self.tabs do
        local tx = self.x + (i-1)*self.tabW
        if mx >= tx and mx <= tx + self.tabW and my >= self.y and my <= self.y + self.tabH then
            self.hovered = i
        end
    end
end

function TabBar:draw()
    love.graphics.setFont(self.font)
    for i, tab in ipairs(self.tabs) do
        local tx = self.x + (i-1)*self.tabW
        local color
        if self.selected == i then
            color = self.colors.selected
        elseif self.hovered == i then
            color = self.colors.hover
        else
            color = self.colors.normal
        end
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", tx, self.y, self.tabW, self.tabH, self.radius, self.radius)

        love.graphics.setColor(self.colors.outline)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", tx, self.y, self.tabW, self.tabH, self.radius, self.radius)

        love.graphics.setColor(self.colors.text)
        love.graphics.printf(tab, tx, self.y + self.tabH/2 - self.font:getHeight()/2, self.tabW, "center")
    end
end

function TabBar:mousepressed(x, y, button)
    if button ~= 1 then return false end
    for i = 1, #self.tabs do
        local tx = self.x + (i-1)*self.tabW
        if x >= tx and x <= tx + self.tabW and y >= self.y and y <= self.y + self.tabH then
            if self.selected ~= i then
                self.selected = i
                self.onChange(i, self.tabs[i])
            end
            return true
        end
    end
    return false
end

function TabBar:getSelected()
    return self.selected, self.tabs[self.selected]
end

function TabBar:setSelected(idx)
    if idx >= 1 and idx <= #self.tabs then
        self.selected = idx
        if self.onChange then self.onChange(idx, self.tabs[idx]) end
    end
end

return TabBar
