local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local Button = require("ui.button")
local Radio = require("ui.radiobutton")

local demo = {}

local group
local btnSetMedium
local lastLog = ""

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    lastLog = ""

    group = Radio.RadioGroup.new({
        { label = I18N.t("devui.radiobutton_easy"), value = "easy" },
        { label = I18N.t("devui.radiobutton_medium"), value = "medium" },
        { label = I18N.t("devui.radiobutton_hard"), value = "hard" },
    }, sw/2 - 80, sh/2 - 40, 50, "easy", false)

    group:setOnChange(function(val)
        lastLog = I18N.t("devui.radiobutton_onchange") .. val
    end)

    btnSetMedium = Button.new(
        I18N.t("devui.radiobutton_set_medium"),
        sw/2 + 60, sh/2 - 10, 140, 44,
        function()
            group:select("medium")
            lastLog = I18N.t("devui.radiobutton_onchange") .. "medium"
        end,
        { font = Fonts.small }
    )
end

function demo.update(dt)
    group:update(dt)
    btnSetMedium:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18N.t("devui.radiobutton_demo_title"), 0, 48, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(I18N.t("devui.radiobutton_choose"), sw/2 - 160, sh/2 - 98, 320, "left")

    group:draw()
    btnSetMedium:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18N.t("devui.radiobutton_selected") .. tostring(group:getValue()), 0, sh/2 + 70, sw, "center")
    love.graphics.setColor(0.7, 0.7, 1)
    love.graphics.printf(lastLog or "", 0, sh/2 + 100, sw, "center")

    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.setFont(Fonts.small)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function demo.mousepressed(x, y, button)
    group:mousepressed(x, y, button)
    btnSetMedium:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnSetMedium:mousereleased(x, y, button)
end

function demo.keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput(t) end

return demo
