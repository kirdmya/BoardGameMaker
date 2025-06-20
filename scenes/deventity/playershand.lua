local Player = require("core.entities.player")
local Card = require("core.entities.card")
local Deck = require("core.entities.deck")
local Discard = require("core.entities.discard")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local Logger = require("utils.logger")
local sceneManager = require("utils.scene_manager")

local test = {}

local players = {}
local deck
local discard
local current_player = 1
local buttons = {}
local card_sprites = {}
local hovered = nil

local function get_sprite(name)
    if not card_sprites[name] then
        local path = "assets/entities/cards/" .. name .. ".png"
        if love.filesystem.getInfo(path) then
            card_sprites[name] = love.graphics.newImage(path)
        else
            card_sprites[name] = love.graphics.newImage("assets/entities/cards/card_empty.png")
        end
    end
    return card_sprites[name]
end

local function add_full_deck(deck)
    local suits = {"spades","hearts","diamonds","clubs"}
    local ranks = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"}
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            deck:add(Card.new(suit, rank, {face_up = false}))
        end
    end
    deck:add(Card.new("joker", "joker_black", {face_up = false}))
    deck:add(Card.new("joker", "joker_red", {face_up = false}))
end

function test.load()
    players = {}
    deck = Deck.new("Demo Deck")
    discard = Discard.new("Discard Pile")
    current_player = 1
    buttons = {}
    hovered = nil

    players[1] = Player.new(nil, "Alice")
    players[2] = Player.new(nil, "Bob")
    players[1].hand = {}
    players[2].hand = {}

    add_full_deck(deck)
    deck:shuffle()

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local btnW, btnH = 320, 48
    local y = sh * 0.78 - 50
    local btnX = sw/2 + btnW/2

    table.insert(buttons, Button.new("Взять карту", btnX, y, btnW, btnH, function()
        local p = players[current_player]
        if #p.hand >= 3 then
            Logger.log("В руке игрока " .. p.name .. " уже 3 карты!")
            return
        end
        if #deck.cards > 0 then
            local c = deck:draw()
            c:set_face(true)
            table.insert(p.hand, c)
            Logger.log("Игрок " .. p.name .. " взял карту: " .. c:get_display_name())
        else
            Logger.log("В колоде не осталось карт!")
        end
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Сменить игрока", btnX, y + btnH + 18, btnW, btnH, function()
        current_player = 3 - current_player
        Logger.log("Теперь ходит: " .. players[current_player].name)
        hovered = nil
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Сбросить карту", btnX, y + 2*(btnH + 18), btnW, btnH, function()
        local p = players[current_player]
        if hovered and p.hand[hovered] then
            local card = table.remove(p.hand, hovered)
            card:set_face(true) 
            discard:add(card)
            Logger.log("Игрок " .. p.name .. " сбросил карту: " .. card:get_display_name())
            hovered = nil
        else
            Logger.log("Выберите карту для сброса (наведите и кликните)")
        end
    end, { font = Fonts.normal }))
end

function test.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
end

function test.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Игроки, руки, колода и сброс", 0, 40, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.18,0.88,0.6)
    love.graphics.printf("Сейчас ходит: " .. players[current_player].name, 0, 94, sw, "center")

    local y0 = 180
    for pidx, p in ipairs(players) do
        local y = y0 + (pidx-1)*180
        love.graphics.setFont(Fonts.normal)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(p.name .. " (рука):", 40, y-50, 240, "left")
        for i, card in ipairs(p.hand) do
            local sprite
            if pidx == current_player then
                sprite = get_sprite(card:get_sprite_name()) 
            else
                sprite = get_sprite("card_back")            
            end
            love.graphics.setColor(1,1,1)
            local cx, cy = 70 + (i-1)*130, y
            love.graphics.draw(sprite, cx, cy, 0, 2, 2)
            if pidx == current_player and hovered == i then
                love.graphics.setColor(0.15,0.68,1,0.18)
                love.graphics.rectangle("fill", cx, cy, 128, 128, 18)
            end
        end
        if #p.hand == 0 then
            love.graphics.setColor(0.65,0.67,0.7)
            love.graphics.rectangle("line", 70, y, 128, 128, 18)
        end
    end


    local deck_x = sw - 340
    local deck_y = sh*0.28
    local deck_card = deck.cards[#deck.cards]
    local deck_sprite = get_sprite(deck_card and deck_card:get_sprite_name() or "card_back")
    love.graphics.setColor(1,1,1)
    love.graphics.draw(deck_sprite, deck_x, deck_y, 0, 2, 2)
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.65,0.91,1)
    love.graphics.printf(deck.name.." ("..#deck.cards..")", deck_x-24, deck_y+140, 180, "center")

    local discard_x = sw - 180
    local discard_y = sh*0.28
    local top_discard = discard.items[#discard.items]
    local discard_sprite = get_sprite(top_discard and top_discard:get_sprite_name() or "card_empty")
    love.graphics.setColor(1,1,1)
    love.graphics.draw(discard_sprite, discard_x, discard_y, 0, 2, 2)
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.95,0.7,0.8)
    love.graphics.printf("Сброс\n("..#discard.items..")", discard_x-14, discard_y+138, 140, "center")

    for _, btn in ipairs(buttons) do btn:draw() end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 50, sw, "center")
end

function test.mousemoved(x, y, dx, dy)
    local p = players[current_player]
    hovered = nil
    local y = 180 + (current_player-1)*180
    for i, card in ipairs(p.hand) do
        local cx, cy = 70 + (i-1)*130, y
        if x >= cx and x <= cx + 128 and y >= cy and y <= cy + 128 then
            hovered = i
        end
    end
end

function test.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end
    if button == 1 then
        local p = players[current_player]
        local y = 180 + (current_player-1)*180
        for i, card in ipairs(p.hand) do
            local cx, cy = 70 + (i-1)*130, y
            if x >= cx and x <= cx + 128 and y >= cy and y <= cy + 128 then
                hovered = i
            end
        end
    end
end

function test.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousereleased(x, y, button) end
end

function test.keypressed(key)
    if key == "escape" then
        sceneManager.load("deventity_list")
    end
end

function test.textinput(t) end

return test
