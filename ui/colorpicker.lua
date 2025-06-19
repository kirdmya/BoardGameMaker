local ColorPicker = {}
ColorPicker.__index = ColorPicker

local Fonts = require("assets.fonts")

function ColorPicker.new(x, y, w, h, color, onChange)
    local self = setmetatable({}, ColorPicker)
    self.x, self.y = x, y
    self.w, self.h = w or 220, h or 130
    self.onChange = onChange or function() end

    color = color or {1, 0, 0, 1}
    self.color = {color[1], color[2], color[3], color[4] or 1}
    self.hue = 0          
    self.sat = 1          
    self.val = 1           
    self.alpha = self.color[4]
    self:_fromRGB(self.color)
    self.dragMode = nil  
    return self
end

function ColorPicker:_fromRGB(rgb)
    local r, g, b = rgb[1], rgb[2], rgb[3]
    local max, min = math.max(r,g,b), math.min(r,g,b)
    local h, s, v
    v = max
    local d = max - min
    if max == 0 then
        s = 0
        h = 0
    else
        s = d / max
        if max == min then
            h = 0
        elseif max == r then
            h = (g-b)/d % 6
        elseif max == g then
            h = (b-r)/d + 2
        else
            h = (r-g)/d + 4
        end
        h = h / 6
        if h < 0 then h = h + 1 end
    end
    self.hue, self.sat, self.val = h, s, v
end

function ColorPicker:_hsv2rgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r,g,b = v,t,p
    elseif i == 1 then r,g,b = q,v,p
    elseif i == 2 then r,g,b = p,v,t
    elseif i == 3 then r,g,b = p,q,v
    elseif i == 4 then r,g,b = t,p,v
    else r,g,b = v,p,q end
    return {r, g, b}
end

function ColorPicker:getColor()
    local rgb = self:_hsv2rgb(self.hue, self.sat, self.val)
    return {rgb[1], rgb[2], rgb[3], self.alpha}
end

function ColorPicker:setColor(r, g, b, a)
    self:_fromRGB({r,g,b})
    self.alpha = a or 1
end

function ColorPicker:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h
    local svW, svH = w-32, h-32
    for i=0,svW-1,4 do
        for j=0,svH-1,4 do
            local sat = i/(svW-1)
            local val = 1 - j/(svH-1)
            local rgb = self:_hsv2rgb(self.hue, sat, val)
            love.graphics.setColor(rgb[1], rgb[2], rgb[3])
            love.graphics.rectangle("fill", x+i, y+j, 4, 4)
        end
    end
    local circX = x + self.sat * (svW-1)
    local circY = y + (1-self.val) * (svH-1)
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", circX, circY, 8)

    for i=0,svH-1,2 do
        local h_ = i/(svH-1)
        local rgb = self:_hsv2rgb(h_, 1, 1)
        love.graphics.setColor(rgb[1], rgb[2], rgb[3])
        love.graphics.rectangle("fill", x+svW+8, y+i, 16, 2)
    end
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", x+svW+6, y+self.hue*(svH-1)-3, 20, 8)

    local aY = y+svH+12
    for i=0,svW-1,4 do
        local alpha = i/(svW-1)
        love.graphics.setColor(self:_hsv2rgb(self.hue, self.sat, self.val)[1], self:_hsv2rgb(self.hue, self.sat, self.val)[2], self:_hsv2rgb(self.hue, self.sat, self.val)[3], alpha)
        love.graphics.rectangle("fill", x+i, aY, 4, 16)
    end
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", x, aY, svW, 16)

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", x+self.alpha*(svW-1)-2, aY-2, 4, 20)

    love.graphics.setColor(self:getColor())
    love.graphics.rectangle("fill", x+svW+40, y, 36, 36)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", x+svW+40, y, 36, 36)

    love.graphics.setFont(Fonts.small)
    local rgb = self:getColor()
    local hex = ("#%02X%02X%02X"):format(math.floor(rgb[1]*255), math.floor(rgb[2]*255), math.floor(rgb[3]*255))
    love.graphics.setColor(1,1,1)
    love.graphics.print(hex, x+svW+40, y+44)
end

function ColorPicker:update(dt) end

function ColorPicker:mousepressed(mx, my, button)
    local x, y, w, h = self.x, self.y, self.w, self.h
    local svW, svH = w-32, h-32
    if mx >= x and mx <= x+svW and my >= y and my <= y+svH then
        self.dragMode = "sv"
        self:_updateSV(mx, my)
        return true
    elseif mx >= x+svW+8 and mx <= x+svW+24 and my >= y and my <= y+svH then
        self.dragMode = "hue"
        self:_updateHue(mx, my)
        return true
    elseif mx >= x and mx <= x+svW and my >= y+svH+12 and my <= y+svH+28 then
        self.dragMode = "alpha"
        self:_updateAlpha(mx, my)
        return true
    end
    self.dragMode = nil
    return false
end

function ColorPicker:mousereleased(mx, my, button)
    self.dragMode = nil
end

function ColorPicker:mousemoved(mx, my, dx, dy, istouch)
    if not self.dragMode then return end
    if self.dragMode == "sv" then
        self:_updateSV(mx, my)
    elseif self.dragMode == "hue" then
        self:_updateHue(mx, my)
    elseif self.dragMode == "alpha" then
        self:_updateAlpha(mx, my)
    end
end

function ColorPicker:_updateSV(mx, my)
    local svW, svH = self.w-32, self.h-32
    self.sat = math.min(1, math.max(0, (mx - self.x) / (svW-1)))
    self.val = 1 - math.min(1, math.max(0, (my - self.y) / (svH-1)))
    self:_changed()
end

function ColorPicker:_updateHue(mx, my)
    local svH = self.h-32
    self.hue = math.min(1, math.max(0, (my - self.y) / (svH-1)))
    self:_changed()
end

function ColorPicker:_updateAlpha(mx, my)
    local svW = self.w-32
    self.alpha = math.min(1, math.max(0, (mx - self.x) / (svW-1)))
    self:_changed()
end

function ColorPicker:_changed()
    local c = self:getColor()
    self.onChange(c)
end

return ColorPicker
