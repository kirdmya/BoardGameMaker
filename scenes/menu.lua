local Button = require("ui.button")
local Fonts = require("assets.fonts")
local Logger = require("utils.logger")
local sceneManager = require("utils.scene_manager")
local L = require("locales").t

local menu = {}
local strips = {}
local titleFont
local buttons = {}

function menu.load()
    buttons = {}
    titleFont = Fonts.big

    strips = {}
    local screenHeight = love.graphics.getHeight()
    local screenWidth = love.graphics.getWidth()
    for i = 1, 15 do
        local direction = love.math.random() > 0.5 and 1 or -1
        local speed = love.math.random(20, 60)
        table.insert(strips, {
            x = direction == 1 and -100 or screenWidth + 100,
            y = love.math.random(0, screenHeight),
            width = love.math.random(50, 200),
            height = love.math.random(1, 3),
            speed = speed * direction,
            alpha = love.math.random(10, 30) / 100
        })
    end

    local buttonWidth = 260
    local buttonHeight = 56
    local startY = love.graphics.getHeight() * 0.35
    local screenWidth = love.graphics.getWidth()
    local menuItems = {
        {text = L("menu.games_list"), action = function() sceneManager.load("games/game_list") end},
        {text = L("menu.settings"), action = function() sceneManager.load("settings") end},
        {text = L("menu.dev_mode"), action = function() sceneManager.load("devmode") end},
        {text = L("menu.exit"), action = function() love.event.quit() end}
    }
    for i, item in ipairs(menuItems) do
        local btn = Button.new(
            item.text,
            screenWidth / 2 - buttonWidth / 2,
            startY + (i - 1) * 80,
            buttonWidth,
            buttonHeight,
            item.action
        )
        table.insert(buttons, btn)
    end
end

function menu.update(dt)
    local screenWidth = love.graphics.getWidth()
    for _, strip in ipairs(strips) do
        strip.x = strip.x + strip.speed * dt
        if strip.speed > 0 and strip.x > screenWidth + 100 then
            strip.x = -100
            strip.y = love.math.random(0, love.graphics.getHeight())
        elseif strip.speed < 0 and strip.x < -100 then
            strip.x = screenWidth + 100
            strip.y = love.math.random(0, love.graphics.getHeight())
        end
    end
    for _, btn in ipairs(buttons) do
        btn:update(dt)
    end
end

function menu.draw()
    love.graphics.setColor(0.08, 0.08, 0.12)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    for _, strip in ipairs(strips) do
        love.graphics.setColor(1, 1, 1, strip.alpha)
        love.graphics.rectangle("fill", strip.x, strip.y, strip.width, strip.height)
    end
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() * 0.15, love.graphics.getWidth(), love.graphics.getHeight() * 0.75)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1)
    local title = L("app_name")
    local titleWidth = titleFont:getWidth(title)
    love.graphics.print(title, love.graphics.getWidth() / 2 - titleWidth / 2, love.graphics.getHeight() * 0.1)
    for _, btn in ipairs(buttons) do
        btn:draw()
    end
end

function menu.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousepressed(x, y, button)
    end
end

function menu.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousereleased(x, y, button)
    end
end

function menu.keypressed(key) end

return menu
