local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local Dropdown = require("ui.dropdown")
local Button = require("ui.button")

local demo = {}

local langDropdown
local difficultyDropdown
local logMsg = ""
local btnLog

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    logMsg = ""
    local langOptions = {
        I18N.getLanguage() == "ru" and "Русский" or "Russian",
        I18N.getLanguage() == "ru" and "Английский" or "English"
    }
    local langIdx = (I18N.getLanguage() == "ru") and 1 or 2
    langDropdown = Dropdown.new(
        sw/2 - 160, sh*0.28, 320, 44, langOptions, langIdx
    )
    langDropdown:setOnChange(function(val, idx)
        logMsg = I18N.t("devui.dropdown_lang_log") .. val
    end)

    difficultyDropdown = Dropdown.new(
        sw/2 - 160, sh*0.28 + 90, 320, 44,
        {I18N.t("devui.dropdown_easy"), I18N.t("devui.dropdown_medium"), I18N.t("devui.dropdown_hard")},
        2
    )
    difficultyDropdown:setOnChange(function(val, idx)
        logMsg = I18N.t("devui.dropdown_difficulty_log") .. val
    end)

    btnLog = Button.new(
        I18N.t("devui.dropdown_log_btn"),
        sw/2 - 150, sh*0.28 + 180, 300, 44,
        function()
            logMsg = I18N.t("devui.dropdown_selected") ..
                langDropdown:getSelected() .. ", " .. difficultyDropdown:getSelected()
        end,
        { font = Fonts.normal }
    )
end

function demo.update(dt)
    langDropdown:update(dt)
    difficultyDropdown:update(dt)
    btnLog:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.dropdown_demo_title"), 0, 48, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(I18N.t("devui.dropdown_lang"), sw/2 - 160, sh*0.28 - 34, 320, "left")
    langDropdown:drawBox()
    love.graphics.printf(I18N.t("devui.dropdown_difficulty"), sw/2 - 160, sh*0.28 + 56, 320, "left")
    difficultyDropdown:drawBox()

    btnLog:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(logMsg, 0, sh*0.28 + 240, sw, "center")

    langDropdown:drawMenu()
    difficultyDropdown:drawMenu()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function demo.mousepressed(x, y, button)
    langDropdown:mousepressed(x, y, button)
    difficultyDropdown:mousepressed(x, y, button)
    btnLog:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnLog:mousereleased(x, y, button)
end

function demo.keypressed(key)
    langDropdown:keypressed(key)
    difficultyDropdown:keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput() end

return demo
