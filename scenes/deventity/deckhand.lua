local Card = require("core.entities.card")
local Deck = require("core.entities.deck")
local Hand = require("core.entities.hand")
local DeckShuffleAnimator = require("core.animations.deck_shuffle_animator")
local CardFlipAnimator = require("core.animations.card_flip_animator")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local Logger = require("utils.logger")
local sceneManager = require("utils.scene_manager")

local test = {}

local deck, hand, deck_anim, flip_anims, hover_scales, hovered
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
    deck = Deck.new("Demo Deck")
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
    local btnW, btnH = 220, 48
    local btnX = sw/2 - btnW/2
    local y = sh*0.35

    table.insert(buttons, Button.new("Перемешать", btnX, y, btnW, btnH, function()
        deck_anim:start()
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Взять карту", btnX, y+btnH+12, btnW, btnH, function()
        if not deck_anim:is_active() and #deck.cards > 0 then
            local c = deck:draw()
            hand:add(c) 
            flip_anims[c] = CardFlipAnimator.new(c, 0.5)
            flip_anims[c]:flip(true) 
        end
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Вернуть карту", btnX, y+2*(btnH+12), btnW, btnH, function()
        local c = hand.items[#hand.items]
        if c and not (flip_anims[c] and flip_anims[c]:is_flipping()) then
            if c:is_face_up() then
                flip_anims[c] = CardFlipAnimator.new(c, 0.5)
                flip_anims[c]:flip(false) 
                flip_anims[c].on_finish = function()
                    hand:remove(c)
                    deck:add(c)
                    flip_anims[c] = nil
                end
            else
                hand:remove(c)
                deck:add(c)
                flip_anims[c] = nil
            end
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
        elseif anim.on_finish then
            anim.on_finish()
            anim.on_finish = nil
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
    love.graphics.printf("Deck & Hand Test", 0, 40, sw, "center")

    local deck_x, deck_y = sw/2 - 400, sh*0.2
    local top_card = deck.cards[#deck.cards]
    local deck_sprite = get_sprite(top_card and top_card:get_sprite_name() or "card_back")
    local deck_angle = 0
    if deck_anim:is_active() then
        deck_angle = math.random()*2*math.pi
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.push()
    love.graphics.translate(deck_x+64, deck_y+64)
    love.graphics.rotate(deck_angle)
    love.graphics.draw(deck_sprite, -64, -64, 0, 2, 2)
    love.graphics.pop()
    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.7,0.9,1)
    love.graphics.printf(deck.name.." ("..#deck.cards..")", deck_x-20, deck_y+130, 200, "center")

    local hand_y = sh*0.7
    local spread = 80
    for i, card in ipairs(hand.items) do
        local cx = sw/2 + (i-1.5)*spread
        local scale = hover_scales[i] or 1
        local sprite = get_sprite(card:get_sprite_name())
        local offset_y = 0
        if hovered == i then
            offset_y = -60*(scale-1)
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

    for _, btn in ipairs(buttons) do btn:draw() end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 50, sw, "center")
end

function test.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end

    if button == 1 then
        local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
        local hand_y = sh*0.7
        local spread = 80
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
                    if card:is_face_up() then
                        flip_anims[card] = CardFlipAnimator.new(card, 0.5)
                        flip_anims[card]:flip(false) -- закрыть
                        flip_anims[card].on_finish = function()
                            hand:remove(card)
                            deck:add(card)
                            flip_anims[card] = nil
                        end
                    else
                        hand:remove(card)
                        deck:add(card)
                        flip_anims[card] = nil
                    end
                end
                break
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
    local hand_y = sh*0.7
    local spread = 80
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
