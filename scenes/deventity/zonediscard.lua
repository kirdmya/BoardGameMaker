local Card = require("core.entities.card")
local Deck = require("core.entities.deck")
local Discard = require("core.entities.discard")
local Zone = require("core.entities.zone")
local Hand = require("core.entities.hand")
local CardFlipAnimator = require("core.animations.card_flip_animator")
local DeckShuffleAnimator = require("core.animations.deck_shuffle_animator")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local Logger = require("utils.logger")
local sceneManager = require("utils.scene_manager")

local test = {}

local deck, discard, zone, hand, deck_anim, flip_anims, hover_scales, hovered
local card_sprites = {}

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

function test.load()
    deck = Deck.new("Deck")
    discard = Discard.new("Discard")
    zone = Zone.new("Zone")
    hand = Hand.new({name="Player"})
    deck_anim = DeckShuffleAnimator.new(deck, 1.2)
    flip_anims = {}
    hover_scales = {}
    hovered = nil

    local samples = {
        {"hearts", "A"}, {"spades", "A"},
        {"clubs", "10"}, {"diamonds", "10"},
        {"hearts", "J"}, {"spades", "J"},
    }
    for _, pair in ipairs(samples) do
        local c = Card.new(pair[1], pair[2], {face_up = false})
        deck:add(c)
    end
end

local buttons = {}

function test.init_buttons(sw, sh)
    buttons = {}
    local btnW, btnH = 220, 40
    local btnX = sw - 240
    local y = sh * 0.50

    table.insert(buttons, Button.new("Перемешать", btnX, y, btnW, btnH, function()
        deck_anim:start()
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Взять карту", btnX, y + btnH + 16, btnW, btnH, function()
        if not deck_anim:is_active() and #deck.cards > 0 then
            local c = deck:draw()
            c:set_face(false)               
            hand:add(c)
            flip_anims[c] = CardFlipAnimator.new(c, 0.5)
            flip_anims[c]:flip(true)       
            flip_anims[c].on_finish = function()
                c:set_face(true)
                flip_anims[c] = nil
            end
        end
    end, { font = Fonts.normal }))


    table.insert(buttons, Button.new("Сбросить все", btnX, y + 2 * (btnH + 16), btnW, btnH, function()
        for i = #zone.items, 1, -1 do
            local card = zone.items[i]
            flip_anims[card] = CardFlipAnimator.new(card, 0.5)
            flip_anims[card]:flip(false)
            flip_anims[card].on_finish = function()
                card:set_face(false)
                zone:remove(card)
                discard:add(card)
                flip_anims[card] = nil
            end
        end
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Перемешать", btnX, y + 3 * (btnH + 16), btnW, btnH, function()
        while #discard.items > 0 do
            local c = discard:take()
            c:set_face(false)
            deck:add(c)
        end
        deck:shuffle()
        deck_anim:start()
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Очистить всё", btnX, y + 4 * (btnH + 16), btnW, btnH, function()
        deck.cards = {}
        zone:clear()
        hand.items = {}
        discard:clear()
        local samples = {
            {"hearts", "A"}, {"spades", "A"},
            {"clubs", "10"}, {"diamonds", "10"},
            {"hearts", "J"}, {"spades", "J"},
        }
        for _, pair in ipairs(samples) do
            local c = Card.new(pair[1], pair[2], {face_up = false})
            deck:add(c)
        end
    end, { font = Fonts.normal }))
end

function test.update(dt)
    if not buttons or #buttons == 0 then
        test.init_buttons(love.graphics.getWidth(), love.graphics.getHeight())
    end
    for _, btn in ipairs(buttons) do btn:update(dt) end
    deck_anim:update(dt)
    for card, anim in pairs(flip_anims) do
        if anim:is_flipping() then
            anim:update(dt)
        else
            if anim.on_finish then
                anim.on_finish()
                anim.on_finish = nil
            end
        end
    end
    for i, c in ipairs(hand.items) do
        hover_scales[i] = hover_scales[i] or 1
        if hovered == i then
            hover_scales[i] = math.min(hover_scales[i] + dt * 4, 1.18)
        else
            hover_scales[i] = math.max(hover_scales[i] - dt * 4, 1)
        end
    end
end

function test.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Deck, Hand, Zone, Discard", 0, 40, sw, "center")

    local deck_x, deck_y = 100, sh * 0.22
    local top_deck = deck.cards[#deck.cards]
    local deck_sprite = get_sprite(top_deck and top_deck:get_sprite_name() or "card_back")
    local deck_angle = 0
    if deck_anim:is_active() then
        deck_angle = math.random() * 2 * math.pi
    end
    love.graphics.setColor(0.7, 0.9, 1, 0.6)
    love.graphics.rectangle("fill", deck_x-10, deck_y-10, 148, 148, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.translate(deck_x+64, deck_y+64)
    love.graphics.rotate(deck_angle)
    love.graphics.draw(deck_sprite, -64, -64, 0, 2, 2)
    love.graphics.pop()
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.4,0.6,1)
    love.graphics.printf("Deck ("..#deck.cards..")", deck_x-8, deck_y+132, 140, "center")

    local discard_x, discard_y = sw-340, sh * 0.22
    local top_discard = discard.items[#discard.items]
    local discard_sprite = get_sprite(top_discard and top_discard:get_sprite_name() or "card_back")
    love.graphics.setColor(0.85,0.7,1,0.65)
    love.graphics.rectangle("fill", discard_x-10, discard_y-10, 148, 148, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(discard_sprite, discard_x, discard_y, 0, 2, 2)
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.7,0.9,1)
    love.graphics.printf("Discard ("..#discard.items..")", discard_x-10, discard_y+130, 140, "center")

    local zone_x, zone_y = sw/2, sh*0.40
    local spread = 90
    for i, card in ipairs(zone.items) do
        local cx = zone_x - 200 + (i-1.5)*spread
        local sprite = get_sprite(card:get_sprite_name())
        love.graphics.push()
        love.graphics.translate(cx, zone_y)
        if flip_anims[card] and flip_anims[card]:is_flipping() then
            local scale_x = flip_anims[card]:get_scale_x()
            love.graphics.scale(scale_x, 1)
        end
        love.graphics.draw(sprite, -64, -64, 0, 2, 2)
        love.graphics.pop()
    end
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.9,1,0.8)
    love.graphics.printf("Zone ("..#zone.items..")", zone_x-130, zone_y+80, 260, "center")

    local hand_y = sh*0.75
    for i, card in ipairs(hand.items) do
        local cx = sw/2 - 200 + (i-1.5)*spread
        local scale = hover_scales[i] or 1
        local sprite = get_sprite(card:get_sprite_name())
        local offset_y = 0
        if hovered == i then
            offset_y = -60 * (scale-1)
        end
        love.graphics.push()
        love.graphics.translate(cx, hand_y + offset_y)
        love.graphics.scale(scale, scale)
        if flip_anims[card] and flip_anims[card]:is_flipping() then
            local scale_x = flip_anims[card]:get_scale_x()
            love.graphics.scale(scale_x, 1)
        end
        love.graphics.draw(sprite, -64, -64, 0, 2, 2)
        love.graphics.pop()
    end
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.9,0.9,1)
    love.graphics.printf("Hand ("..#hand.items..")", sw/2-110, hand_y+100, 220, "center")

    for _, btn in ipairs(buttons) do btn:draw() end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 50, sw, "center")
end

function test.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local hand_y = sh*0.75
    local spread = 90

    if button == 1 then
        for i = #hand.items, 1, -1 do
            local card = hand.items[i]
            local cx = sw/2 + (i-1.5)*spread
            local scale = hover_scales[i] or 1
            local card_left = cx - 64*scale
            local card_right = cx + 64*scale
            local card_top = hand_y - 64*scale
            local card_bot = hand_y + 64*scale
            if x >= card_left and x <= card_right and y >= card_top and y <= card_bot then
                if not (flip_anims[card] and flip_anims[card]:is_flipping()) then
                    hand:remove(card)
                    zone:add(card)
                    break
                end
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

function test.update_hover(mx, my)
    hovered = nil
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local hand_y = sh*0.75
    local spread = 90
    for i, card in ipairs(hand.items) do
        local cx = sw/2 + (i-1.5)*spread
        local scale = hover_scales[i] or 1
        local card_left = cx - 64*scale
        local card_right = cx + 64*scale
        local card_top = hand_y - 64*scale
        local card_bot = hand_y + 64*scale
        if mx >= card_left and mx <= card_right and my >= card_top and my <= card_bot then
            hovered = i
        end
    end
end

function test.mousemoved(x, y, dx, dy)
    test.update_hover(x, y)
end

function test.textinput(t) end

return test
