local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local Slider = require("ui.slider")
local NumberInput = require("ui.number_input")
local Button = require("ui.button")

local demo = {}

local slider
local numberInput
local btnReset
local logMsg = ""

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local startVal = 42

    logMsg = ""

    slider = Slider.new(sw/2 - 150, sh/2 - 32, 300, 36, startVal, function(val)
        numberInput.value = tostring(val)
        numberInput.lastValid = tostring(val)
        logMsg = I18N.t("devui.slider_onchange") .. tostring(val)
    end)

    numberInput = NumberInput.new(sw/2 - 48, sh/2 + 36, 96, 40, startVal, function(val)
        slider:setValue(val)
        logMsg = I18N.t("devui.slider_oninput") .. tostring(val)
    end)

    btnReset = Button.new(
        I18N.t("devui.slider_reset"),
        sw/2 - 60, sh/2 + 90, 120, 42,
        function()
            slider:setValue(0)
            logMsg = I18N.t("devui.slider_reset_log")
        end,
        { font = Fonts.small }
    )
end

function demo.update(dt)
    slider:update(dt)
    numberInput:update(dt)
    btnReset:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.slider_demo_title"), 0, 56, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(I18N.t("devui.slider_label"), sw/2 - 160, sh/2 - 200, 320, "left")
    slider:draw()
    numberInput:draw()
    btnReset:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18N.t("devui.slider_value") .. slider:getValue(), 0, sh/2 + 144, sw, "center")
    love.graphics.setColor(0.7, 0.7, 1)
    love.graphics.printf(logMsg or "", 0, sh/2 + 170, sw, "center")

    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.setFont(Fonts.small)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function demo.mousepressed(x, y, button)
    slider:mousepressed(x, y, button)
    numberInput:mousepressed(x, y, button)
    btnReset:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    slider:mousereleased(x, y, button)
    btnReset:mousereleased(x, y, button)
end

function demo.mousemoved(x, y, dx, dy, istouch)
    slider:mousemoved(x, y, dx, dy, istouch)
end

function demo.keypressed(key)
    numberInput:keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput(t)
    numberInput:textinput(t)
end

return demo
