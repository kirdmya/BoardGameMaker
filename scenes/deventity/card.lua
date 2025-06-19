local Card = require("core.entities.card")
local CardFlipAnimator = require("core.animations.card_flip_animator")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local Logger = require("utils.logger")
local sceneManager = require("utils.scene_manager")

local card_test = {}

local card
local flip_anim
local buttons = {}
local card_sprites = {}

local suits = {"spades", "hearts", "diamonds", "clubs"}
local ranks = {"A","K","Q","J","10","09","08","07","06","05","04","03","02"}

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

function card_test.load()
    card = Card.new("spades", "A", {face_up = false})
    flip_anim = CardFlipAnimator.new(card, 0.6)
    buttons = {}

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local btnW, btnH = 220, 48
    local btnX = sw/2 - btnW/2
    local y = sh*0.74

    table.insert(buttons, Button.new("Flip", btnX, y, btnW, btnH, function()
        if not flip_anim:is_flipping() then
            flip_anim:flip()
        end
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Random Card", btnX, y+btnH+16, btnW, btnH, function()
        local suit = suits[math.random(#suits)]
        local rank = ranks[math.random(#ranks)]
        card = Card.new(suit, rank, {face_up = math.random() > 0.5})
        flip_anim = CardFlipAnimator.new(card, 0.6)
    end, { font = Fonts.normal }))

    table.insert(buttons, Button.new("Joker", btnX, y+2*(btnH+16), btnW, btnH, function()
        local kind = math.random() > 0.5 and "joker_red" or "joker_black"
        card = Card.new("joker", kind, {face_up = true})
        flip_anim = CardFlipAnimator.new(card, 0.6)
    end, { font = Fonts.normal }))
end

function card_test.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
    flip_anim:update(dt)
end

function card_test.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Card Entity Test", 0, 60, sw, "center")

    local card_width = 64
    local card_height = 64
    local scale = 2
    local cx = sw/2
    local cy = sh*0.38 + card_height * scale / 2

    local sprite_name = card:get_sprite_name()
    local sprite = get_sprite(sprite_name)
    local scale_x = flip_anim:get_scale_x()

    love.graphics.push()
    love.graphics.translate(cx, cy)
    love.graphics.scale(scale_x, 1)
    love.graphics.draw(sprite, -card_width * scale / 2, -card_height * scale / 2, 0, scale, scale)
    love.graphics.pop()

    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.9,1,0.9)
    love.graphics.printf(
        card:get_display_name() .. (card:is_face_up() and " (face up)" or " (back)"),
        0, cy + card_height * scale / 2 + 16, sw, "center"
    )

    for _, btn in ipairs(buttons) do btn:draw() end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 50, sw, "center")
end



function card_test.keypressed(key)
    if key == "escape" then
        sceneManager.load("deventity_list")
    end
end

function card_test.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end
end

function card_test.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do btn:mousereleased(x, y, button) end
end

function card_test.textinput(t) end

return card_test
