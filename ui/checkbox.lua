local Checkbox = {}
Checkbox.__index = Checkbox

local Fonts = require("assets.fonts")
local Logger = require("utils.logger")

local soundFiles = {
    click = {"assets/sounds/click-a.ogg", "assets/sounds/click-b.ogg"}
}
local soundPool = { click = {} }

local function initSoundPool()
    for _, path in ipairs(soundFiles.click) do
        if love.filesystem.getInfo(path) then
            local s = love.audio.newSource(path, "static")
            s:setVolume(0.8)
            table.insert(soundPool.click, s)
        else
            Logger.log("Checkbox: звуковой файл не найден: " .. path)
        end
    end
end

local missingSoundWarned = false


local function playSound()
    local pool = soundPool.click
    if #pool == 0 then
        if not missingSoundWarned then
            Logger.log("Checkbox: нет звука click — звук не будет проигрываться.")
            missingSoundWarned = true
        end
        return
    end
    local sound = table.remove(pool, 1)
    sound:stop()
    sound:play()
    table.insert(pool, sound)
end


function Checkbox.new(x, y, size, label, defaultChecked, onChange)
    local self = setmetatable({}, Checkbox)
    self.x = x
    self.y = y
    self.size = size or 36
    self.label = label or ""
    self.checked = defaultChecked or false
    self.onChange = onChange or function() end
    self.hovered = false
    self.disabled = false
    self.radius = 7
    self.font = Fonts.normal
    return self
end

function Checkbox:draw()
    local boxX, boxY, boxSize = self.x, self.y, self.size

    love.graphics.setColor(0, 0, 0, 0.16)
    love.graphics.rectangle("fill", boxX + 2, boxY + 3, boxSize, boxSize, self.radius, self.radius)

    if self.disabled then
        love.graphics.setColor(0.65, 0.65, 0.65)
    elseif self.hovered then
        love.graphics.setColor(0.19, 0.52, 0.92)
    else
        love.graphics.setColor(0.19, 0.30, 0.45)
    end
    love.graphics.rectangle("fill", boxX, boxY, boxSize, boxSize, self.radius, self.radius)

    love.graphics.setColor(0.32, 0.41, 0.57)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", boxX, boxY, boxSize, boxSize, self.radius, self.radius)

    if self.checked then
        love.graphics.setColor(1, 1, 1)
        local offset = boxSize * 0.25
        love.graphics.setLineWidth(4)
        love.graphics.line(
            boxX + offset, boxY + boxSize * 0.55,
            boxX + boxSize * 0.45, boxY + boxSize - offset,
            boxX + boxSize - offset, boxY + offset
        )
    end

    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.label, boxX + boxSize + 18, boxY + boxSize / 2 - self.font:getHeight() / 2)
end

function Checkbox:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = (not self.disabled) and mx >= self.x and mx <= self.x + self.size and
                                      my >= self.y and my <= self.y + self.size
end

function Checkbox:mousepressed(x, y, button)
    if self.disabled then return false end
    if button == 1 and self.hovered then
        self.checked = not self.checked
        playSound()
        self.onChange(self.checked)
        return true
    end
    return false
end

function Checkbox:setChecked(checked)
    self.checked = checked and true or false
end

function Checkbox:isChecked()
    return self.checked
end

function Checkbox:setDisabled(disabled)
    self.disabled = disabled and true or false
end

if not soundPool.initialized then
    initSoundPool()
    soundPool.initialized = true
end

return Checkbox
