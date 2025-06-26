local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local TabBar = require("ui.tabbar")
local Button = require("ui.button")

local demo = {}

local tabbar
local logMsg = ""
local btnBack

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    logMsg = ""
    tabbar = TabBar.new(
        sw/2 - 420, sh*0.25, 840,
        {
            I18N.t("devui.tabbar_tab1"),
            I18N.t("devui.tabbar_tab2"),
            I18N.t("devui.tabbar_tab3")
        },
        {
            selected = 2,
            tabH = 86,
            font = Fonts.normal,
            onChange = function(idx, name)
                logMsg = (I18N.getLanguage() == "ru" and "Выбрана вкладка: " or "Selected tab: ") .. tostring(name)
            end
        }
    )

    btnBack = Button.new(
        I18N.t("settings.back"),
        sw/2-60, sh*0.25+200, 120, 44,
        function() sceneManager.load("devui_components") end,
        {font = Fonts.normal}
    )
end

function demo.update(dt)
    tabbar:update(dt)
    btnBack:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.tabbar_demo_title") or "TabBar", 0, 48, sw, "center")

    tabbar:draw()
    btnBack:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(logMsg, 0, sh*0.25+140, sw, "center")
end

function demo.mousepressed(x, y, button)
    tabbar:mousepressed(x, y, button)
    btnBack:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnBack:mousereleased(x, y, button)
end

function demo.keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.textinput() end

return demo
