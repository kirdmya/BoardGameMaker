local Player = require("core.entities.player")
local Deck = require("core.entities.deck")
local Card = require("core.entities.card")
local CardFlipAnimator = require("core.animations.card_flip_animator")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local sceneManager = require("utils.scene_manager")
local Logger = require("utils.logger")

local game = {}

local deck, players, current, winner, popup, buttons
local flip_anims, ai_thinking, ai_timer
local reveal_ai = false

local function count_points(hand)
    local total, aces = 0, 0
    for _, card in ipairs(hand) do
        if card.rank == "A" then
            total = total + 11
            aces = aces + 1
        elseif card.rank == "K" or card.rank == "Q" or card.rank == "J" then
            total = total + 10
        else
            total = total + tonumber(card.rank)
        end
    end
    while total > 21 and aces > 0 do
        total = total - 10
        aces = aces - 1
    end
    return total
end

local function deal_card(p, animate)
    local c = deck:draw()
    if c then
        c:set_face(false)
        table.insert(p.hand, c)
        flip_anims[c] = CardFlipAnimator.new(c, 0.5)
        flip_anims[c]:flip(function()
            c:set_face(true)
        end)
        Logger.log("Игрок " .. p.name .. " получил карту: " .. c:get_display_name())
    end
end

local function check_end()
    local player_pts = count_points(players[1].hand)
    local ai_pts = count_points(players[2].hand)

    local function is_double_ace(hand)
        return #hand == 2 and hand[1].rank == "A" and hand[2].rank == "A"
    end

    if is_double_ace(players[1].hand) then
        winner = 1; popup = "Вы выиграли (два туза)!"
        reveal_ai = true
        return true
    elseif is_double_ace(players[2].hand) then
        winner = 2; popup = "Компьютер выиграл (два туза)!"
        reveal_ai = true
        return true
    end

    if player_pts > 21 then
        winner = 2; popup = "Вы проиграли (перебор)!"
        reveal_ai = true
        return true
    end

    if current == 2 and (winner == nil) then
        if ai_pts > 21 then
            winner = 1; popup = "Компьютер перебрал — Вы выиграли!"
        elseif player_pts > ai_pts then
            winner = 1; popup = "Вы выиграли!"
        elseif player_pts < ai_pts then
            winner = 2; popup = "Компьютер выиграл!"
        elseif player_pts == ai_pts then
            if player_pts == 21 then
                winner = 1; popup = "Оба 21! Вы выиграли!"
            else
                winner = 0; popup = "Ничья!"
            end
        end
        reveal_ai = true
        return true
    end
    return false
end

local function ai_play()
    ai_thinking = true
    ai_timer = 0.8
end

function game.load()
    deck = Deck.new("21 Deck")
    local suits = {"spades", "hearts", "diamonds", "clubs"}
    local ranks = {"A", "2","3","4","5","6","7","8","9","10","J","Q","K"}
    for _, s in ipairs(suits) do
        for _, r in ipairs(ranks) do
            deck:add(Card.new(s, r, {face_up=false}))
        end
    end
    deck:shuffle()

    players = {
        {name="Игрок", hand={}},
        {name="Компьютер", hand={}},
    }
    current = 1
    winner = nil
    popup = nil
    reveal_ai = false
    ai_thinking = false
    flip_anims = {}

    for _=1,2 do
        deal_card(players[1], true)
        deal_card(players[2], true)
    end

    buttons = {}
    local btnW, btnH = 260, 56
    local gap = 30
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local btnY = sh - 170

    buttons[1] = Button.new("Взять карту",
        sw/2 - btnW - gap/2, btnY, btnW, btnH,
        function()
            if not winner and current == 1 then
                deal_card(players[1], true)
            end
        end, {font=Fonts.normal})

    buttons[2] = Button.new("Остановиться",
        sw/2 + gap/2, btnY, btnW, btnH,
        function()
            if not winner and current == 1 then
                current = 2
                ai_play()
            end
        end, {font=Fonts.normal})

    buttons[3] = Button.new("Заново",
        sw/2 - btnW/2, btnY + btnH + 32, btnW, btnH,
        function() game.load() end,
        {font=Fonts.normal})

end

function game.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
    for card, anim in pairs(flip_anims) do
        if anim:is_flipping() then
            anim:update(dt)
        else
            flip_anims[card] = nil
        end
    end

    local any_flipping = false
    for _, anim in pairs(flip_anims) do
        if anim:is_flipping() then any_flipping = true break end
    end
    if any_flipping then return end

    if ai_thinking and not winner then
        ai_timer = ai_timer - dt
        if ai_timer <= 0 then
            local pts = count_points(players[2].hand)
            if pts < 17 then
                deal_card(players[2], true)
                ai_timer = 0.8
            elseif pts < 20 and math.random() < 0.5 then
                deal_card(players[2], true)
                ai_timer = 0.8
            else
                ai_thinking = false
                current = 1
                check_end()
            end
            check_end()
        end
    else
        if not winner then
            check_end()
        end
    end
end

local card_sprites = {}
local function get_sprite(card)
    if not card_sprites[card:get_sprite_name()] then
        local path = "assets/entities/cards/" .. card:get_sprite_name() .. ".png"
        if love.filesystem.getInfo(path) then
            card_sprites[card:get_sprite_name()] = love.graphics.newImage(path)
        else
            card_sprites[card:get_sprite_name()] = love.graphics.newImage("assets/entities/cards/card_empty.png")
        end
    end
    return card_sprites[card:get_sprite_name()]
end

function game.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Игра 21", 0, 40, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("Ваши карты ("..count_points(players[1].hand)..")", sw/2-340, 150, 240, "center")
    for i, card in ipairs(players[1].hand) do
        local x = sw/2-340 + (i-1)*55
        local y = 220
        local sprite = get_sprite(card)
        love.graphics.push()
        love.graphics.translate(x+32, y+32)
        if flip_anims[card] and flip_anims[card]:is_flipping() then
            local scale_x = flip_anims[card]:get_scale_x()
            love.graphics.scale(scale_x, 1)
        end
        love.graphics.draw(sprite, -32, -32, 0, 1, 1)
        love.graphics.pop()
    end

    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("Карты компьютера", sw/2+90, 150, 240, "center")
    for i, card in ipairs(players[2].hand) do
        local x = sw/2+90 + (i-1)*55
        local y = 220
        local sprite
        if reveal_ai or winner then
            sprite = get_sprite(card)
        else
            sprite = get_sprite({get_sprite_name = function() return "card_back" end})
        end
        love.graphics.push()
        love.graphics.translate(x+32, y+32)
        if flip_anims[card] and flip_anims[card]:is_flipping() then
            local scale_x = flip_anims[card]:get_scale_x()
            love.graphics.scale(scale_x, 1)
        end
        love.graphics.draw(sprite, -32, -32, 0, 1, 1)
        love.graphics.pop()
    end

    if popup then
        love.graphics.setFont(Fonts.big)
        love.graphics.setColor(0.12,0.13,0.18,0.88)
        love.graphics.rectangle("fill", sw*0.23, sh*0.31, sw*0.54, 100, 22,22)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(popup, sw*0.23, sh*0.31+22, sw*0.54, "center")
    end

    for _, btn in ipairs(buttons) do btn:draw() end
    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.7,0.8,1)
    love.graphics.printf("ESC — назад", 0, sh-50, sw, "center")
end

function game.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end
end
function game.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousereleased(x, y, button) end
end
function game.keypressed(key)
    if key == "escape" then sceneManager.load("games/game_list") end
end
function game.textinput() end

return game
