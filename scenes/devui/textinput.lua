local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local TextInput = require("ui.textinput")
local Button = require("ui.button")

local demo = {}

local input, inputNum, btnClear
local logMsg = ""

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    logMsg = ""

    input = TextInput.new(
        sw/2 - 160, sh*0.28, 320, 44,
        {
            placeholder = I18N.t("devui.textinput_hint"),
            onChange = function(val) logMsg = I18N.t("devui.textinput_log") .. val end,
            maxLength = 32,
            font = Fonts.normal
        }
    )

    inputNum = TextInput.new(
        sw/2 - 160, sh*0.28 + 80, 320, 44,
        {
            placeholder = I18N.t("devui.textinput_num_hint"),
            onChange = function(val) logMsg = I18N.t("devui.textinput_num_log") .. val end,
            validator = function(char) return char:match("%d") end,
            maxLength = 6,
            font = Fonts.normal
        }
    )

    btnClear = Button.new(
        I18N.t("devui.textinput_clear_btn"),
        sw/2 - 125, sh*0.28 + 140, 250, 40,
        function()
            input:setText("")
            inputNum:setText("")
            logMsg = I18N.t("devui.textinput_cleared")
        end,
        { font = Fonts.small }
    )
end

function demo.update(dt)
    input:update(dt)
    inputNum:update(dt)
    btnClear:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.textinput_demo_title"), 0, 50, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(I18N.t("devui.textinput_label"), sw/2 - 160, sh*0.28 - 36, 320, "left")
    input:draw()
    love.graphics.printf(I18N.t("devui.textinput_num_label"), sw/2 - 160, sh*0.28 + 44, 320, "left")
    inputNum:draw()
    btnClear:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(logMsg, 0, sh*0.28 + 200, sw, "center")

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function demo.mousepressed(x, y, button)
    input:mousepressed(x, y, button)
    inputNum:mousepressed(x, y, button)
    btnClear:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnClear:mousereleased(x, y, button)
end

function demo.keypressed(key)
    input:keypressed(key)
    inputNum:keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput(t)
    input:textinput(t)
    inputNum:textinput(t)
end

return demo
