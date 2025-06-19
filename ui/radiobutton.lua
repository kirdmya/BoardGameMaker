local RadioButton = {}
RadioButton.__index = RadioButton

local Fonts = require("assets.fonts")
local love_audio = love.audio
local clickSound

local Logger = require("utils.logger")

local function ensureSoundLoaded()
    if not clickSound then
        if love.filesystem.getInfo("assets/sounds/switch-a.ogg") then
            clickSound = love_audio.newSource("assets/sounds/switch-a.ogg", "static")
        else
            Logger.log("RadioButton: звуковой файл не найден: assets/sounds/switch-a.ogg")
        end
    end
end


function RadioButton.new(label, x, y, radius, group, value)
    ensureSoundLoaded()
    local self = setmetatable({}, RadioButton)
    self.label = label
    self.x, self.y = x, y
    self.radius = radius or 16
    self.group = group
    self.value = value
    self.selected = false
    self.hovered = false
    return self
end

function RadioButton:draw()
    local bx, by = self.x, self.y
    local r = self.radius

    if self.hovered then
        love.graphics.setColor(0.3, 0.5, 1, 1)
    else
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
    end
    love.graphics.circle("fill", bx, by, r)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", bx, by, r)

    if self.selected then
        love.graphics.setColor(0.2, 0.7, 0.3, 1)
        love.graphics.circle("fill", bx, by, r * 0.55)
    end

    love.graphics.setFont(Fonts.normal or love.graphics.getFont())
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.label, bx + r + 12, by - r * 0.75)
end

function RadioButton:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = ((mx - self.x)^2 + (my - self.y)^2) <= self.radius^2
end

function RadioButton:mousepressed(x, y, button)
    if button == 1 and ((x - self.x)^2 + (y - self.y)^2) <= self.radius^2 then
        if not self.selected then
            self.group:select(self.value)
            if clickSound then clickSound:stop(); clickSound:play() end
        end
        return true
    end
    return false
end

function RadioButton:setSelected(selected)
    self.selected = selected
end

local RadioGroup = {}
RadioGroup.__index = RadioGroup

function RadioGroup.new(options, x, y, gap, defaultValue, orientation)
    local self = setmetatable({}, RadioGroup)
    self.buttons = {}
    self.selectedValue = defaultValue
    self.onChange = nil 
    self.orientation = orientation or "vertical"
    gap = gap or 36

    for i, opt in ipairs(options) do
        local bx, by = x, y
        if self.orientation == "vertical" then
            by = y + (i - 1) * gap
        else
            bx = x + (i - 1) * gap
        end
        local btn = RadioButton.new(opt.label, bx, by, 18, self, opt.value)
        btn:setSelected(opt.value == defaultValue)
        table.insert(self.buttons, btn)
    end
    return self
end


function RadioGroup:draw()
    for _, btn in ipairs(self.buttons) do
        btn:draw()
    end
end

function RadioGroup:update(dt)
    for _, btn in ipairs(self.buttons) do
        btn:update(dt)
    end
end

function RadioGroup:mousepressed(x, y, button)
    for _, btn in ipairs(self.buttons) do
        if btn:mousepressed(x, y, button) then return true end
    end
end

function RadioGroup:setOnChange(callback)
    self.onChange = callback
end

function RadioGroup:select(value)
    self.selectedValue = value
    for _, btn in ipairs(self.buttons) do
        btn:setSelected(btn.value == value)
    end
    if self.onChange then self.onChange(value) end
end

function RadioGroup:getValue()
    return self.selectedValue
end

return {
    RadioButton = RadioButton,
    RadioGroup = RadioGroup
}
