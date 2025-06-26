local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local NumberInput = require("ui.number_input")
local Button = require("ui.button")

local demo = {}

local input
local btnMin, btnMax
local lastLog = ""
local value = 42

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    value = 42
    input = NumberInput.new(sw/2 - 90, sh/2 - 32, 120, 48, value, function(val)
        lastLog = I18N.t("devui.number_input_onchange") .. tostring(val)
        value = val
    end)

    btnMin = Button.new(
        I18N.t("devui.number_input_min"),
        sw/2 + 44, sh/2 - 32, 150, 48,
        function()
            input.value = "0"
            input.lastValid = "0"
            value = 0
            input.onChange(0)
        end,
        { font = Fonts.small }
    )

    btnMax = Button.new(
        I18N.t("devui.number_input_max"),
        sw/2 + 44, sh/2 + 24, 150, 48,
        function()
            input.value = "100"
            input.lastValid = "100"
            value = 100
            input.onChange(100)
        end,
        { font = Fonts.small }
    )
end

function demo.update(dt)
    input:update(dt)
    btnMin:update(dt)
    btnMax:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18N.t("devui.number_input_demo_title") or "NumberInput", 0, 48, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(I18N.t("devui.number_input_label") or "Введите число (0–100):", sw/2 - 200, sh/2 - 82, 400, "left")

    input:draw()
    btnMin:draw()
    btnMax:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18N.t("devui.number_input_current") .. tostring(value), 0, sh/2 + 90, sw, "center")
    love.graphics.setColor(0.7, 0.7, 1)
    love.graphics.printf(lastLog or "", 0, sh/2 + 120, sw, "center")

    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.setFont(Fonts.small)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function demo.mousepressed(x, y, button)
    input:mousepressed(x, y, button)
    btnMin:mousepressed(x, y, button)
    btnMax:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnMin:mousereleased(x, y, button)
    btnMax:mousereleased(x, y, button)
end

function demo.keypressed(key)
    input:keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput(t)
    input:textinput(t)
end

return demo
