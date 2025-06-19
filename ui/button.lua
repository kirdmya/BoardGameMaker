local Button = {}
Button.__index = Button

local Fonts = require("assets.fonts")
local Logger = require("utils.logger")

local soundFiles = {
    click = {"assets/sounds/click-a.ogg", "assets/sounds/click-b.ogg"},
    switch = {"assets/sounds/switch-a.ogg", "assets/sounds/switch-b.ogg"},
    tap = {"assets/sounds/tap-a.ogg", "assets/sounds/tap-b.ogg"}
}

local soundPool = { click = {}, switch = {}, tap = {} }

local function initSoundPool()
    for category, files in pairs(soundFiles) do
        for _, path in ipairs(files) do
            if love.filesystem.getInfo(path) then
                local s = love.audio.newSource(path, "static")
                s:setVolume(0.7)
                table.insert(soundPool[category], s)
            else
                Logger.log(("Button: звуковой файл не найден: %s"):format(path))
            end
        end
    end
end

local missingSoundWarned = {}

local function playSound(soundType)
    local pool = soundPool[soundType]
    if not pool or #pool == 0 then
        if not missingSoundWarned[soundType] then
            Logger.log(("Button: нет звука категории '%s' — звук проигрываться не будет."):format(soundType))
            missingSoundWarned[soundType] = true
        end
        return
    end
    local sound = table.remove(pool, 1)
    sound:stop()
    sound:play()
    table.insert(pool, sound)
end


local COLORS = {
    normal   = {0.19, 0.30, 0.45},
    hover    = {0.25, 0.45, 0.75},
    pressed  = {0.16, 0.22, 0.36},
    disabled = {0.45, 0.45, 0.45},
    shadow   = {0, 0, 0, 0.19},
    outline  = {0.32, 0.41, 0.57},
}

function Button.new(label, x, y, w, h, onClick, options)
    local self = setmetatable({}, Button)
    options = options or {}

    self.label = label
    self.x, self.y, self.w, self.h = x, y, w, h
    self.onClick = onClick or function() end
    self.state = "normal"
    self.disabled = options.disabled or false

    self.colors = options.colors or COLORS
    self.font = options.font or Fonts.normal
    self.textColor = {
        normal   = options.textColor or {1, 1, 1, 1},
        hover    = options.textHoverColor or {0.95, 1, 1, 1},
        pressed  = options.textPressedColor or {0.82, 0.9, 1, 1},
        disabled = options.textDisabledColor or {0.72, 0.72, 0.72, 1},
    }
    self.shadow = options.shadow ~= false
    self.soundType = options.sound or "click"
    self.radius = options.radius or 18

    self.animationProgress = 0
    self.animationSpeed = options.animationSpeed or 10
    self.scaleEffect = options.scaleEffect or 0.97

    return self
end

function Button:draw()
    local color = self.colors[self.state] or self.colors.normal
    local textColor = self.textColor[self.state] or self.textColor.normal
    local scale = (self.state == "pressed" and self.scaleEffect) or 1
    local x = self.x + (self.w - self.w * scale) / 2
    local y = self.y + (self.h - self.h * scale) / 2
    local w = self.w * scale
    local h = self.h * scale

    if self.shadow and self.state ~= "pressed" then
        love.graphics.setColor(self.colors.shadow)
        love.graphics.rectangle("fill", x + 3, y + 6, w, h, self.radius, self.radius)
    end

    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, w, h, self.radius, self.radius)

    love.graphics.setLineWidth(2)
    love.graphics.setColor(self.colors.outline)
    love.graphics.rectangle("line", x, y, w, h, self.radius, self.radius)

    love.graphics.setFont(self.font)
    love.graphics.setColor(textColor)
    love.graphics.printf(self.label, x, y + h/2 - self.font:getHeight()/2, w, "center")
end

function Button:update(dt)
    if self.animationProgress > 0 then
        self.animationProgress = math.max(0, self.animationProgress - dt * self.animationSpeed)
    end

    local mx, my = love.mouse.getPosition()
    local isHovered = mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h

    if self.disabled then
        self.state = "disabled"
    elseif self.state == "pressed" then
        if isHovered and love.mouse.isDown(1) then
            self.state = "pressed"
        else
            self.state = isHovered and "hover" or "normal"
        end
    else
        self.state = isHovered and "hover" or "normal"
    end
end

function Button:mousepressed(x, y, button)
    if button == 1 and not self.disabled and self.state == "hover" then
        self.state = "pressed"
        self.animationProgress = 1
        playSound(self.soundType)
        return true
    end
    return false
end

function Button:mousereleased(x, y, button)
    if button == 1 and self.state == "pressed" then
        if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
            self.onClick()
        end
        self.state = "hover"
    end
end

function Button:setEnabled(enabled)
    self.disabled = not enabled
end

function Button:setText(newText)
    self.label = newText
end

function Button:setPosition(x, y)
    self.x, self.y = x, y
end

if not soundPool.initialized then
    initSoundPool()
    soundPool.initialized = true
end

return Button
