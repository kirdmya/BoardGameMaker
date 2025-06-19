local TextInput = {}
TextInput.__index = TextInput

local Fonts = require("assets.fonts")

function TextInput.new(x, y, w, h, opts)
    opts = opts or {}
    local self = setmetatable({}, TextInput)
    self.x, self.y = x, y
    self.w, self.h = w or 180, h or 40
    self.text = opts.text or ""
    self.placeholder = opts.placeholder or ""
    self.onChange = opts.onChange or function(_) end
    self.active = false
    self.font = opts.font or Fonts.normal
    self.maxLength = opts.maxLength or 32
    self.validator = opts.validator -- function(char) -> true/false
    self.textColor = opts.textColor or {1, 1, 1}
    self.bgColor = opts.bgColor or {0.22, 0.27, 0.38}
    self.activeColor = opts.activeColor or {0.35, 0.49, 0.69}
    self.outlineColor = opts.outlineColor or {0.32, 0.41, 0.57}
    self.radius = opts.radius or 8
    self.cursorPos = #self.text + 1
    self.cursorTimer = 0
    self.cursorVisible = true
    return self
end

function TextInput:update(dt)
    if self.active then
        self.cursorTimer = self.cursorTimer + dt
        if self.cursorTimer >= 0.5 then
            self.cursorVisible = not self.cursorVisible
            self.cursorTimer = 0
        end
    else
        self.cursorVisible = false
        self.cursorTimer = 0
    end
end

function TextInput:draw()
    love.graphics.setFont(self.font)
    love.graphics.setLineWidth(2)

    love.graphics.setColor(self.active and self.activeColor or self.bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.radius, self.radius)
    love.graphics.setColor(self.outlineColor)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.radius, self.radius)

    local textDisplay = self.text
    if #textDisplay == 0 and not self.active and #self.placeholder > 0 then
        love.graphics.setColor(0.7, 0.7, 0.7, 0.6)
        textDisplay = self.placeholder
    else
        love.graphics.setColor(self.textColor)
    end
    love.graphics.printf(textDisplay, self.x + 8, self.y + self.h / 2 - self.font:getHeight() / 2, self.w - 16, "left")

    if self.active and self.cursorVisible then
        local sub = self.text:sub(1, self.cursorPos - 1)
        local tw = self.font:getWidth(sub)
        love.graphics.setColor(1, 1, 1, 1)
        local cx = self.x + 8 + tw
        local cy = self.y + self.h / 2 - self.font:getHeight() / 2
        love.graphics.rectangle("fill", cx, cy, 2, self.font:getHeight())
    end
end

function TextInput:mousepressed(x, y, button)
    if button == 1 then
        self.active = (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h)
        if self.active then
            local relx = x - self.x - 8
            local minDist, pos = math.huge, 1
            for i = 0, #self.text do
                local w = self.font:getWidth(self.text:sub(1, i))
                if math.abs(relx - w) < minDist then
                    minDist = math.abs(relx - w)
                    pos = i + 1
                end
            end
            self.cursorPos = pos
        end
    else
        self.active = false
    end
end

function TextInput:textinput(t)
    if self.active then
        if self.validator and not self.validator(t) then return end
        if #self.text < self.maxLength then
            self.text = self.text:sub(1, self.cursorPos - 1) .. t .. self.text:sub(self.cursorPos)
            self.cursorPos = self.cursorPos + 1
            self.onChange(self.text)
        end
    end
end

function TextInput:keypressed(key)
    if not self.active then return end
    if key == "backspace" then
        if self.cursorPos > 1 then
            self.text = self.text:sub(1, self.cursorPos - 2) .. self.text:sub(self.cursorPos)
            self.cursorPos = math.max(1, self.cursorPos - 1)
            self.onChange(self.text)
        end
    elseif key == "delete" then
        self.text = self.text:sub(1, self.cursorPos - 1) .. self.text:sub(self.cursorPos + 1)
        self.onChange(self.text)
    elseif key == "left" then
        self.cursorPos = math.max(1, self.cursorPos - 1)
    elseif key == "right" then
        self.cursorPos = math.min(#self.text + 1, self.cursorPos + 1)
    elseif key == "home" then
        self.cursorPos = 1
    elseif key == "end" then
        self.cursorPos = #self.text + 1
    elseif key == "return" or key == "kpenter" then
        self.active = false
    elseif key == "escape" then
        self.active = false
    end
end

function TextInput:setText(text)
    self.text = text or ""
    self.cursorPos = #self.text + 1
end

function TextInput:getText()
    return self.text
end

return TextInput
