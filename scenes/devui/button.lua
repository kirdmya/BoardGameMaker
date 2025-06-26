local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local Button = require("ui.button")

local example = {}

local buttons = {}
local lastEvent = ""
local isDisabled = false
local pressCount = 0

function example.load()
    buttons = {}
    lastEvent = ""
    pressCount = 0
    isDisabled = false

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local btnW, btnH = 340, 64

    table.insert(buttons, Button.new(
        I18N.t("devui.button_default"),
        sw/2 - btnW/2,
        sh * 0.23 + 50,
        btnW,
        btnH,
        function()
            pressCount = pressCount + 1
            lastEvent = I18N.t("devui.button_clicked") .. " (" .. pressCount .. ")"
        end,
        { font = Fonts.normal }
    ))

    table.insert(buttons, Button.new(
        I18N.t("devui.button_colored"),
        sw/2 - btnW/2,
        sh * 0.23 + 140,
        btnW,
        btnH,
        function()
            lastEvent = I18N.t("devui.button_colored_clicked")
        end,
        {
            font = Fonts.normal,
            colors = {
                normal = {0.26, 0.38, 0.18},
                hover = {0.33, 0.58, 0.26},
                pressed = {0.19, 0.28, 0.13},
                disabled = {0.4, 0.4, 0.4},
                shadow = {0, 0, 0, 0.19},
                outline = {0.32, 0.41, 0.57}
            },
            sound = "switch"
        }
    ))

    table.insert(buttons, Button.new(
        I18N.t("devui.button_disable_toggle"),
        sw/2 - btnW/2,
        sh * 0.23 + 230,
        btnW,
        btnH,
        function()
            isDisabled = not isDisabled
            buttons[1]:setEnabled(not isDisabled)
            lastEvent = isDisabled and I18N.t("devui.button_now_disabled") or I18N.t("devui.button_now_enabled")
        end,
        { font = Fonts.normal, sound = "tap" }
    ))
end

function example.update(dt)
    for _, btn in ipairs(buttons) do
        btn:update(dt)
    end
end

function example.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.button_demo_title"), 0, 32, sw, "center")

    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.7, 0.93, 1)
    love.graphics.printf(I18N.t("devui.button_hint"), 0, sh*0.23 - 34, sw, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(lastEvent, 0, sh*0.23 + 400, sw, "center")

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 48, sw, "center")
end

function example.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousepressed(x, y, button)
    end
end

function example.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousereleased(x, y, button)
    end
end

function example.update(dt)
    for _, btn in ipairs(buttons) do
        btn:update(dt)
    end
end

function example.keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function example.textinput(t) end

return example
