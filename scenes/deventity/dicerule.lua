local Dice = require("core.entities.dice")
local DiceAnimator = require("core.animations.dice_animator")
local NumberInput = require("ui.number_input")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local sceneManager = require("utils.scene_manager")

local game = {}

local dices = {}
local animators = {}
local dice_sprites = {}
local results = {0,0,0}
local number_inputs = {}
local selected_numbers = {nil, nil}
local can_roll = false
local popup = nil
local popup_timer = 0
local pending_check = false
local check_timer = 0

local function load_dice_sprites()
    for i = 1, 6 do
        dice_sprites[i] = love.graphics.newImage("assets/entities/dice/dice_"..i..".png")
    end
    dice_sprites["empty"] = love.graphics.newImage("assets/entities/dice/dice_empty.png")
    dice_sprites["question"] = love.graphics.newImage("assets/entities/dice/dice_question.png")
end

local function get_ui_layout()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    return {
        input1 = {x = sw/2 - 140, y = sh*0.19, w = 72, h = 48},
        input2 = {x = sw/2 + 60, y = sh*0.19, w = 72, h = 48},
        roll_btn = {x = sw/2 - 110, y = sh*0.32, w = 220, h = 54},
        dice_y = sh*0.52,
        popup_y = sh*0.75
    }
end

function game.load()
    dices = {}
    animators = {}
    results = {0,0,0}
    selected_numbers = {nil, nil}
    can_roll = false
    popup = nil
    pending_check = false
    check_timer = 0

    load_dice_sprites()

    for i = 1, 3 do
        dices[i] = Dice.new()
        animators[i] = DiceAnimator.new(dices[i])
        results[i] = 1
    end

    local ui = get_ui_layout()
    number_inputs = {
        NumberInput.new(ui.input1.x, ui.input1.y, ui.input1.w, ui.input1.h, 3, function(val)
            val = math.max(3, math.min(18, val))
            selected_numbers[1] = val
        end),
        NumberInput.new(ui.input2.x, ui.input2.y, ui.input2.w, ui.input2.h, 3, function(val)
            val = math.max(3, math.min(18, val))
            selected_numbers[2] = val
        end)
    }
end

function game.update(dt)
    can_roll = selected_numbers[1] and selected_numbers[2]
        and tonumber(selected_numbers[1]) >= 3 and tonumber(selected_numbers[1]) <= 18
        and tonumber(selected_numbers[2]) >= 3 and tonumber(selected_numbers[2]) <= 18

    for i = 1, 3 do
        animators[i]:update(dt)
    end

    if pending_check then
        check_timer = check_timer - dt
        if check_timer <= 0 then
            pending_check = false
            for i = 1, 3 do
                results[i] = dices[i]:get()
            end
            local sum = results[1] + results[2] + results[3]
            if sum == tonumber(selected_numbers[1]) or sum == tonumber(selected_numbers[2]) then
                popup = "Поздравляем! Вы угадали сумму " .. tostring(sum) .. "!"
            else
                popup = "Увы! Сумма " .. tostring(sum) .. " не совпала ни с одним из выбранных чисел."
            end
            popup_timer = 2.3
        end
    end

    if popup then
        popup_timer = popup_timer - dt
        if popup_timer <= 0 then
            popup = nil
        end
    end
end

function game.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Угадай сумму трёх кубиков!", 0, 32, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("Выберите два числа от 3 до 18", sw/2-180, 98, 400, "center")

    for i = 1, 2 do
        number_inputs[i]:draw()
    end

    local ui = get_ui_layout()
    local btn_color = can_roll and {0.12,0.85,0.28} or {0.45,0.45,0.45}
    love.graphics.setColor(btn_color)
    love.graphics.rectangle("fill", ui.roll_btn.x, ui.roll_btn.y, ui.roll_btn.w, ui.roll_btn.h, 14, 14)
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("Бросить кости", ui.roll_btn.x, ui.roll_btn.y + 16, ui.roll_btn.w, "center")

    local dice_x0 = sw/2 - 120
    for i = 1, 3 do
        local dx = dice_x0 + (i-1)*120
        local sprite
        if animators[i].animating then
            sprite = math.random() < 0.5 and dice_sprites["question"] or dice_sprites["empty"]
        elseif dices[i].state == "question" then
            sprite = dice_sprites["question"]
        elseif dices[i].state == "empty" then
            sprite = dice_sprites["empty"]
        else
            sprite = dice_sprites[dices[i]:get()] or dice_sprites["empty"]
        end
        love.graphics.setColor(1,1,1)
        love.graphics.draw(sprite, dx, ui.dice_y, 0, 2, 2)
    end

    local sum = results[1] + results[2] + results[3]
    if not pending_check and (results[1] ~= 0 or results[2] ~= 0 or results[3] ~= 0) then
        love.graphics.setFont(Fonts.normal)
        love.graphics.setColor(0.8,0.95,1)
        love.graphics.printf("Сумма: " .. tostring(sum), sw/2-60, ui.dice_y+92, 120, "center")
    end

    if popup then
        love.graphics.setFont(Fonts.big)
        love.graphics.setColor(0,0,0,0.72)
        love.graphics.rectangle("fill", sw*0.18, ui.popup_y, sw*0.64, 90, 16, 16)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(popup, sw*0.18, ui.popup_y+28, sw*0.64, "center")
    end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 50, sw, "center")
end

function game.mousepressed(x, y, button)
    for _, inp in ipairs(number_inputs) do inp:mousepressed(x, y, button) end

    local ui = get_ui_layout()
    if button == 1 and can_roll then
        if x >= ui.roll_btn.x and x <= ui.roll_btn.x + ui.roll_btn.w and
           y >= ui.roll_btn.y and y <= ui.roll_btn.y + ui.roll_btn.h then
            for i = 1, 3 do
                local res = math.random(1,6)
                dices[i]:set(res)
                animators[i]:start(res)
                results[i] = 0
            end
            pending_check = true
            check_timer = 1.5
        end
    end
end

function game.textinput(t)
    for _, inp in ipairs(number_inputs) do inp:textinput(t) end
end

function game.keypressed(key)
    for _, inp in ipairs(number_inputs) do inp:keypressed(key) end
    if key == "escape" then
        sceneManager.load("deventity_list")
    end
end

return game
