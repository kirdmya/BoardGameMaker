local Dropdown = {}
Dropdown.__index = Dropdown

local Fonts = require("assets.fonts")
local love_audio = love.audio
local clickSound

local missingSoundWarned = false

local function ensureSoundLoaded()
    if not clickSound then
        if love.filesystem.getInfo("assets/sounds/switch-b.ogg") then
            clickSound = love_audio.newSource("assets/sounds/switch-b.ogg", "static")
        else
            if not missingSoundWarned then
                if Logger then Logger.log("Dropdown: звук 'switch-b.ogg' не найден, звук не будет воспроизводиться.") end
                missingSoundWarned = true
            end
        end
    end
end


function Dropdown.new(x, y, w, h, options, defaultIndex)
    ensureSoundLoaded()
    local self = setmetatable({}, Dropdown)
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.options = options or {}
    self.selected = defaultIndex or 1
    self.open = false
    self.hovered = false
    self.optionHovered = nil
    self.onChange = nil
    return self
end

function Dropdown:drawBox()
    love.graphics.setFont(Fonts.normal or love.graphics.getFont())
    love.graphics.setColor(0.13, 0.17, 0.3, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 10, 10)

    local text = tostring(self.options[self.selected] or "-")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, self.x + 10, self.y + self.h/2 - Fonts.normal:getHeight()/2, self.w - 32, "left")

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.polygon("fill",
        self.x + self.w - 22, self.y + self.h/2 - 4,
        self.x + self.w - 10, self.y + self.h/2 - 4,
        self.x + self.w - 16, self.y + self.h/2 + 4
    )
end

function Dropdown:drawMenu()
    if not self.open then return end
    local optH = self.h
    for i, opt in ipairs(self.options) do
        local oy = self.y + i * optH
        if self.optionHovered == i then
            love.graphics.setColor(0.25, 0.45, 0.9, 1)
        else
            love.graphics.setColor(0.18, 0.22, 0.38, 1)
        end
        love.graphics.rectangle("fill", self.x, oy, self.w, optH)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(opt, self.x + 10, oy + optH/2 - Fonts.normal:getHeight()/2, self.w - 20, "left")
        love.graphics.rectangle("line", self.x, oy, self.w, optH)
    end
end



function Dropdown:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h

    self.optionHovered = nil
    if self.open then
        local optH = self.h
        for i, _ in ipairs(self.options) do
            local oy = self.y + i * optH
            if mx >= self.x and mx <= self.x + self.w and my >= oy and my <= oy + optH then
                self.optionHovered = i
            end
        end
    end
end

function Dropdown:mousepressed(x, y, button)
    if button ~= 1 then return false end

    if self.open then
        if self.optionHovered then
            self.selected = self.optionHovered
            self.open = false
            if clickSound then clickSound:stop(); clickSound:play() end
            if self.onChange then self.onChange(self.options[self.selected], self.selected) end
            return true
        else
            self.open = false
            return false
        end
    else
        if self.hovered then
            self.open = true
            if clickSound then clickSound:stop(); clickSound:play() end
            return true
        end
    end
    return false
end

function Dropdown:keypressed(key)
    if self.open then
        if key == "escape" or key == "return" or key == "kpenter" then
            self.open = false
        end
    end
end

function Dropdown:setOnChange(fn)
    self.onChange = fn
end

function Dropdown:getSelected()
    return self.options[self.selected], self.selected
end

function Dropdown:setSelected(idx)
    if idx >= 1 and idx <= #self.options then
        self.selected = idx
        if self.onChange then self.onChange(self.options[self.selected], self.selected) end
    end
end

return Dropdown
