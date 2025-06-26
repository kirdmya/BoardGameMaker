local Dice = require("core.entities.dice")
local DiceAnimator = require("core.animations.dice_animator")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local Logger = require("utils.logger")
local sceneManager = require("utils.scene_manager")

local dice_multi_test = {}

local dice_list = {}
local animators = {}
local buttons = {}
local dice_sprites = {}

local function load_dice_sprites()
    for i = 1, 6 do
        dice_sprites[i] = love.graphics.newImage("assets/entities/dice/dice_"..i..".png")
    end
    dice_sprites["empty"] = love.graphics.newImage("assets/entities/dice/dice_empty.png")
    dice_sprites["question"] = love.graphics.newImage("assets/entities/dice/dice_question.png")
end

function dice_multi_test.load()
    dice_list = {}
    animators = {}
    buttons = {}

    load_dice_sprites()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local btnW, btnH = 220, 48
    local btnX = sw/2 - btnW/2 
    local y = sh*0.68

    for i = 1, 3 do
        dice_list[i] = Dice.new("D" .. i)
        animators[i] = DiceAnimator.new(dice_list[i])
    end

    table.insert(buttons, Button.new("Бросить", btnX, y, btnW, btnH, function()
        for i, anim in ipairs(animators) do
            anim:start(function(value)
                Logger.log(string.format("Кубик #%d выпал: %s", i, tostring(value)))
            end)
        end
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Сбросить", btnX, y+btnH+16, btnW, btnH, function()
        for i, dice in ipairs(dice_list) do
            dice:reset()
            animators[i].animating = false
        end
    end, { font = Fonts.normal }))
end

function dice_multi_test.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
    for _, animator in ipairs(animators) do animator:update(dt) end
end

function dice_multi_test.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Мульти-анимация кубиков", 0, 50, sw, "center")

    for i, dice in ipairs(dice_list) do
        local x = sw/2 - 140 + (i-1)*140
        local y = sh*0.38
        local sprite
        if dice.state == "question" then
            sprite = dice_sprites["question"]
        elseif dice.state == "empty" then
            sprite = dice_sprites["empty"]
        else
            sprite = dice_sprites[dice.value] or dice_sprites["empty"]
        end
        love.graphics.setColor(1,1,1)
        love.graphics.draw(sprite, x, y, 0, 2, 2)
        love.graphics.setFont(Fonts.small)
        love.graphics.setColor(0.85,0.9,1)
        love.graphics.printf(dice.name, x - 50, y + 100, 128, "center")
        if dice.state == "rolled" then
            love.graphics.setColor(0.8,1,0.8)
            love.graphics.printf("Выпало: " .. tostring(dice.value), x - 40, y + 146, 128, "center")
        end
    end

    for _, btn in ipairs(buttons) do btn:draw() end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 50, sw, "center")
end

function dice_multi_test.keypressed(key)
    if key == "escape" then
        sceneManager.load("deventity_list")
    end
end

function dice_multi_test.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end
end

function dice_multi_test.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousereleased(x, y, button) end
end

function dice_multi_test.textinput(t) end

return dice_multi_test
