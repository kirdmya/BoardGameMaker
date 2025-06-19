local I18N = require("locales")
local sceneManager = require("utils.scene_manager")
local Fonts = require("assets.fonts")
local Button = require("ui.button")
local Logger = require("utils.logger")

local devmode = {}

local categories = {
    { key = "ui" },
    { key = "core" },
    { key = "entities" }, 
    { key = "entity_tests" },
}
local buttons = {}

function devmode.load()
    buttons = {}
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local buttonW, buttonH = 320, 60
    local startY = sh * 0.28

    for i, cat in ipairs(categories) do
        local btn = Button.new(
            I18N.t("devmode." .. cat.key),
            sw/2 - buttonW/2,
            startY + (i - 1) * (buttonH + 24),
            buttonW,
            buttonH,
            function()
                if cat.key == "ui" then
                    Logger.log("[devmode] Переключение на playground UI компонентов")
                    sceneManager.load("devui_components")
                elseif cat.key == "core" then
                    Logger.log("[devmode] Переключение на playground ядра")
                    sceneManager.load("devcore_engine")
                elseif cat.key == "entities" then
                    Logger.log("[devmode] Переключение на playground игровых сущностей")
                    sceneManager.load("deventity_playground")
                elseif cat.key == "entity_tests" then
                    Logger.log("[devmode] Переключение на список тестов сущностей")
                    sceneManager.load("deventity_list")
                end
            end,
            {
                font = Fonts.normal
            }
        )
        table.insert(buttons, btn)
    end
end

function devmode.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
end

function devmode.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("menu.dev_mode"), 0, 52, sw, "center")
    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function devmode.keypressed(key)
    if key == "escape" then
        sceneManager.load("menu")
    end
end

function devmode.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousepressed(x, y, button)
    end
end

function devmode.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousereleased(x, y, button)
    end
end

function devmode.textinput(t) end

return devmode
