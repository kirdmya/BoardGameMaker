local Fonts = require("assets.fonts")
local Button = require("ui.button")
local sceneManager = require("utils.scene_manager")
local I18N = require("locales")

local deventity_list = {}

local buttons = {}
local entities = { "Dice", "Card", "DeckHand", "ZoneDiscard", "DiceRule", "PlayersHand"}

function deventity_list.load()
    buttons = {}
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local buttonW, buttonH = 260, 44
    local startY = sh * 0.22
    local btnX = sw/2 - buttonW/2

    for i, name in ipairs(entities) do
        local btn = Button.new(
            name,
            btnX,
            startY + (i-1) * (buttonH + 16),
            buttonW,
            buttonH,
            function()
                sceneManager.load("deventity." .. name:lower())
            end,
            { font = Fonts.normal }
        )
        table.insert(buttons, btn)
    end
end

function deventity_list.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
end

function deventity_list.draw()
    local sw = love.graphics.getWidth()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18N.t("entities.test_list_title", "Entity Test List"), 0, 50, sw, "center")

    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.7, 0.7, 0.9)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, love.graphics.getHeight() - 52, sw, "center")
end

function deventity_list.keypressed(key)
    if key == "escape" then
        sceneManager.load("devmode")
    end
end

function deventity_list.mousepressed(x, y, button)
    for i, btn in ipairs(buttons) do
        btn:mousepressed(x, y, button)
    end
end

function deventity_list.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousereleased(x, y, button)
    end
end

function deventity_list.textinput(t) end

return deventity_list
