local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local ColorPicker = require("ui.colorpicker")
local Button = require("ui.button")

local demo = {}

local picker, logMsg, btnCopy

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    logMsg = ""
    picker = ColorPicker.new(
        sw/2 - 180, sh/2 - 110, 320, 160,
        {0.1, 0.2, 0.8, 1},
        function(c)
            logMsg = string.format(I18N.t("devui.colorpicker_log"),
                math.floor(c[1]*255), math.floor(c[2]*255), math.floor(c[3]*255), math.floor((c[4] or 1)*255))
        end
    )

    btnCopy = Button.new(
        I18N.t("devui.colorpicker_copy_btn"),
        sw/2 - 80, sh/2 + 70, 160, 40,
        function()
            local c = picker:getColor()
            local hex = ("#%02X%02X%02X"):format(math.floor(c[1]*255), math.floor(c[2]*255), math.floor(c[3]*255))
            logMsg = I18N.t("devui.colorpicker_copied") .. hex
        end,
        { font = Fonts.small }
    )
end

function demo.update(dt)
    picker:update(dt)
    btnCopy:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.colorpicker_demo_title"), 0, 48, sw, "center")

    picker:draw()
    btnCopy:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(logMsg, 0, sh * 0.7, sw, "center")

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function demo.mousepressed(x, y, button)
    picker:mousepressed(x, y, button)
    btnCopy:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    picker:mousereleased(x, y, button)
    btnCopy:mousereleased(x, y, button)
end

function demo.mousemoved(x, y, dx, dy, istouch)
    picker:mousemoved(x, y, dx, dy, istouch)
end

function demo.keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput() end

return demo
