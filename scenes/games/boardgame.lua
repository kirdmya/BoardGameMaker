local Field = require("core.entities.field")
local Item  = require("core.entities.item")
local Player = require("core.entities.player")
local Dice = require("core.entities.dice")
local DiceAnimator = require("core.animations.dice_animator")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local sceneManager = require("utils.scene_manager")

local game = {}

local field
local players
local current_player
local dice
local dice_anim
local winner
local move_anim
local effect_message, effect_timer

local buttons = {}
local dice_sprites = {}

local function load_dice_sprites()
    for i = 1, 6 do
        dice_sprites[i] = love.graphics.newImage("assets/entities/dice/dice_"..i..".png")
    end
    dice_sprites["empty"] = love.graphics.newImage("assets/entities/dice/dice_empty.png")
    dice_sprites["question"] = love.graphics.newImage("assets/entities/dice/dice_question.png")
end

local function set_move_anim(p, from, to, duration, on_finish)
    move_anim = {
        from = from,
        to = to,
        timer = 0,
        total = duration,
        player = current_player,
        on_finish = on_finish
    }
end

local function randomize_cells(field)
    local n = 20
    local function pick(set, count)
        local res = {}
        while #res < count do
            local i = math.random(2, n-1)
            if not set[i] then
                set[i] = true
                table.insert(res, i)
            end
        end
        return res
    end
    local used = {}
    local bonuses = pick(used, 3)
    local penalties = pick(used, 3)
    local skips = pick(used, 2)
    for i = 1, n do
        field.cells[i] = {}
    end
    for _, idx in ipairs(bonuses) do
        field.cells[idx].bonus = math.random(2, 4)
    end
    for _, idx in ipairs(penalties) do
        field.cells[idx].penalty = math.random(2, 4)
    end
    for _, idx in ipairs(skips) do
        field.cells[idx].skip = true
    end
end

function game.load()
    load_dice_sprites()
    field = Field.new("Поле", {width=20, height=1})
    randomize_cells(field)

    players = {
        {name = "Игрок 1", pos = 1, color = {1,0.3,0.3}, skip=false, anim_pos=1, shape="circle"},
        {name = "Игрок 2", pos = 1, color = {0.3,0.5,1}, skip=false, anim_pos=1, shape="square"},
    }
    current_player = 1
    winner = nil
    effect_message, effect_timer = nil, 0

    dice = Dice.new()
    dice_anim = DiceAnimator.new(dice, {duration=1.5, frame_time=0.18})
    move_anim = nil

    buttons = {}
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    table.insert(buttons, Button.new("Бросить кубик", 44, sh*0.85, 220, 72, function()
        if winner or dice_anim.animating or move_anim then return end
        local player = players[current_player]
        if player.skip then
            player.skip = false
            effect_message = "Пропуск хода!"
            effect_timer = 1.3
            current_player = 3 - current_player
            return
        end
        dice_anim:start(function(value)
            local p = players[current_player]
            local target = math.min(p.pos + value, 20)
            move_anim = {
                from = p.pos, to = target, timer = 0, total = math.abs(target - p.pos)*0.23 + 0.2,
                player = current_player,
                on_finish = function()
                    p.pos = target
                    p.anim_pos = target
                    local cell = field.cells[target]
                    if target >= 20 then
                        winner = p.name
                        return
                    end
                    if cell.bonus then
                        local bonus_to = math.min(target + cell.bonus, 20)
                        effect_message = ("Бонус! +"..cell.bonus)
                        effect_timer = 1.1
                        move_anim = {
                            from = target, to = bonus_to, timer = 0, total = math.abs(bonus_to - target)*0.19 + 0.16,
                            player = current_player,
                            on_finish = function()
                                p.pos = bonus_to
                                p.anim_pos = bonus_to
                                if bonus_to >= 20 then
                                    winner = p.name
                                else
                                    current_player = 3 - current_player
                                end
                            end
                        }
                        return
                    elseif cell.penalty then
                        local penalty_to = math.max(1, target - cell.penalty)
                        effect_message = ("Штраф! -" .. cell.penalty)
                        effect_timer = 1.1
                        move_anim = {
                            from = target, to = penalty_to, timer = 0, total = math.abs(penalty_to - target)*0.19 + 0.16,
                            player = current_player,
                            on_finish = function()
                                p.pos = penalty_to
                                p.anim_pos = penalty_to
                                current_player = 3 - current_player
                            end
                        }
                        return
                    elseif cell.skip then
                        effect_message = "Пропуск следующего хода!"
                        effect_timer = 1.1
                        p.skip = true
                        current_player = 3 - current_player
                    else
                        current_player = 3 - current_player
                    end
                end
            }
        end)
    end, {font=Fonts.big, radius=24, colors = {
        normal   = {0.15,0.25,0.43},
        hover    = {0.28,0.5,1},
        pressed  = {0.13,0.2,0.31},
        disabled = {0.45,0.45,0.45},
        shadow   = {0, 0, 0, 0.19},
        outline  = {0.45,0.8,1},
    }}))

    table.insert(buttons, Button.new("Заново", sw-264, sh*0.85, 220, 72, function()
        game.load()
    end, {font=Fonts.big, radius=24, colors={
        normal = {0.2,0.34,0.24},
        hover = {0.22,0.7,0.36},
        pressed = {0.17,0.2,0.13},
        disabled = {0.45,0.45,0.45},
        shadow   = {0, 0, 0, 0.13},
        outline  = {0.4,1,0.8},
    }}))
end

function game.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
    dice_anim:update(dt)
    if move_anim then
        local p = players[move_anim.player]
        move_anim.timer = move_anim.timer + dt
        local progress = math.min(move_anim.timer / move_anim.total, 1)
        p.anim_pos = move_anim.from + (move_anim.to - move_anim.from)*progress
        if progress >= 1 then
            if move_anim.on_finish then move_anim.on_finish() end
            move_anim = nil
        end
    end
    if effect_message then
        effect_timer = effect_timer - dt
        if effect_timer <= 0 then effect_message = nil end
    end
end

function game.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Бродилка", 0, 32, sw, "center")

    local dice_x, dice_y = sw/2-88, 155
    local scale = (dice_anim.animating and 4 or 2.8)
    local sprite
    if dice.state == "question" then
        sprite = dice_sprites["question"]
    elseif dice.state == "empty" then
        sprite = dice_sprites["empty"]
    else
        sprite = dice_sprites[dice.value] or dice_sprites["empty"]
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(sprite, dice_x, dice_y, 0, scale, scale)
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.85,0.9,1)
    love.graphics.printf("Кубик", dice_x-10, dice_y + 140, 180, "center")
    if dice.state == "rolled" and not dice_anim.animating then
        love.graphics.setColor(0.7,1,0.6)
        love.graphics.printf("Выпало: " .. tostring(dice.value), dice_x-10, dice_y + 176, 180, "center")
    end

    local start_x = sw/2 - 490
    local y = sh*0.52
    for i = 1, 20 do
        local cell_x = start_x + (i-1)*49
        local grad = 0.13+0.018*i
        love.graphics.setColor(grad, grad+0.10, grad+0.14, 0.97)
        love.graphics.rectangle("fill", cell_x, y, 45, 45, 14, 14)
        love.graphics.setColor(0.1,0.18,0.35, 0.22)
        love.graphics.rectangle("fill", cell_x+2, y+8, 41, 10, 10, 10)
        love.graphics.setColor(0.8,0.98,1)
        love.graphics.setLineWidth(2.5)
        love.graphics.rectangle("line", cell_x, y, 45, 45, 14, 14)

        if field.cells[i].bonus then
            love.graphics.setColor(0.15, 1, 0.25)
            love.graphics.circle("fill", cell_x+22, y-18, 15)
            love.graphics.setColor(0,0.13,0)
            love.graphics.setFont(Fonts.small)
            love.graphics.printf("+"..field.cells[i].bonus, cell_x+5, y-26, 36, "center")
        elseif field.cells[i].penalty then
            love.graphics.setColor(1,0.25,0.22)
            love.graphics.circle("fill", cell_x+22, y-18, 15)
            love.graphics.setColor(0.14,0,0)
            love.graphics.setFont(Fonts.small)
            love.graphics.printf("-"..field.cells[i].penalty, cell_x+5, y-26, 36, "center")
        elseif field.cells[i].skip then
            love.graphics.setColor(1,0.23,0.35)
            love.graphics.circle("fill", cell_x+22, y-18, 15)
            love.graphics.setColor(0.16,0,0)
            love.graphics.setFont(Fonts.small)
            love.graphics.printf("🚫", cell_x+5, y-26, 36, "center")
        end

        if i == 1 then
            love.graphics.setColor(1,1,1)
            love.graphics.printf("Старт", cell_x-6, y-36, 60, "left")
        elseif i == 20 then
            love.graphics.setColor(1,1,1)
            love.graphics.printf("Финиш", cell_x-6, y-36, 60, "left")
        end
    end

    for idx, player in ipairs(players) do
        local cell_x = start_x + ((player.anim_pos or player.pos)-1)*49 + 22.5
        local radius = 19 + (winner == player.name and 7 or 0)
        love.graphics.setColor(player.color)
        if player.shape == "circle" then
            love.graphics.circle("fill", cell_x, y+22 + (idx-1)*36, radius)
        else
            love.graphics.rectangle("fill", cell_x-radius, y+22 + (idx-1)*36-radius, radius*2, radius*2, 9, 9)
        end
        love.graphics.setFont(Fonts.small)
        love.graphics.setColor(0,0,0,0.82)
        love.graphics.printf(idx, cell_x-10, y+14 + (idx-1)*36, 20, "center")
    end

    if effect_message then
        love.graphics.setFont(Fonts.big)
        love.graphics.setColor(0.16,0.6,1, 0.89)
        love.graphics.rectangle("fill", sw*0.28, y-130, sw*0.44, 68, 14, 14)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(effect_message, sw*0.28, y-114, sw*0.44, "center")
    end

    love.graphics.setFont(Fonts.big)
    if winner then
        love.graphics.setColor(0,0,0,0.55)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
        love.graphics.setColor(0.13,1,0.43)
        love.graphics.rectangle("fill", sw*0.19, sh*0.36, sw*0.62, 158, 16, 16)
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(Fonts.big)
        love.graphics.printf("Победил: "..winner.."!", sw*0.19, sh*0.41, sw*0.62, "center")
    else
        love.graphics.setColor(0.4,1,0.9)
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("Ходит: "..players[current_player].name, 0, y+98, sw, "center")
        if players[current_player].skip then
            love.graphics.setColor(1,0.77,0.26)
            love.graphics.printf("Этот ход пропускается!", 0, y+132, sw, "center")
        end
    end

    for _, btn in ipairs(buttons) do btn:draw() end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 50, sw, "center")
end

function game.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end
end
function game.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousereleased(x, y, button) end
end
function game.keypressed(key)
    if key == "escape" then
        sceneManager.load("games/game_list")
    end
end
function game.textinput(t) end

return game
