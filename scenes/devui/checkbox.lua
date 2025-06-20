local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local Checkbox = require("ui.checkbox")
local Button = require("ui.button")

local demo = {}

local checkboxes = {}
local logMsg = ""
local btnReset = nil

function demo.load()
    checkboxes = {}
    logMsg = ""
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    table.insert(checkboxes, Checkbox.new(
        sw/2 - 180, sh * 0.32, 36,
        I18N.t("devui.checkbox_main"),
        false,
        function(val)
            logMsg = val and I18N.t("devui.checkbox_checked") or I18N.t("devui.checkbox_unchecked")
        end
    ))

    table.insert(checkboxes, Checkbox.new(
        sw/2 - 180, sh * 0.32 + 60, 36,
        I18N.t("devui.checkbox_persistent"),
        true,
        function(val)
            logMsg = I18N.t("devui.checkbox_persistent_log") .. (val and "ON" or "OFF")
        end
    ))

    table.insert(checkboxes, Checkbox.new(
        sw/2 - 180, sh * 0.32 + 120, 36,
        I18N.t("devui.checkbox_disable_me"),
        false,
        function(val)
            checkboxes[1]:setDisabled(val) 
            logMsg = val and I18N.t("devui.checkbox_disabled_first") or I18N.t("devui.checkbox_enabled_first")
        end
    ))

    btnReset = Button.new(
        I18N.t("devui.checkbox_reset_btn"),
        sw/2 - 150, sh * 0.32 + 180, 300, 48,
        function()
            for _, cb in ipairs(checkboxes) do
                cb:setChecked(false)
                cb:setDisabled(false)
            end
            logMsg = I18N.t("devui.checkbox_reset_log")
        end,
        { font = Fonts.normal }
    )
end

function demo.update(dt)
    for _, cb in ipairs(checkboxes) do
        cb:update(dt)
    end
    btnReset:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.checkbox_demo_title"), 0, 48, sw, "center")

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.74, 0.95, 1)
    love.graphics.printf(I18N.t("devui.checkbox_hint"), 0, sh*0.32 - 50, sw, "center")
    love.graphics.setColor(1, 1, 1)

    for _, cb in ipairs(checkboxes) do
        cb:draw()
    end

    btnReset:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(logMsg, 0, sh*0.32 + 250, sw, "center")


    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function demo.mousepressed(x, y, button)
    for _, cb in ipairs(checkboxes) do
        cb:mousepressed(x, y, button)
    end
    btnReset:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnReset:mousereleased(x, y, button)
end

function demo.keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput() end

return demo
