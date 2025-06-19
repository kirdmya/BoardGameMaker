local Card = require("core.entities.card")
local CardFlipAnimator = require("core.animations.card_flip_animator")
local Button = require("ui.button")
local Dropdown = require("ui.dropdown")
local Slider = require("ui.slider")
local Fonts = require("assets.fonts")
local sceneManager = require("utils.scene_manager")

local game = {}

local num_pairs = 8
local grid_cols = 4
local grid_rows = 4
local cards = {}
local flip_anims = {}
local flipped = {}
local matched = {}
local state = "waiting"
local first_flipped = nil
local second_flipped = nil
local moves = 0
local buttons = {}
local difficulty_dropdown
local slider
local message = ""
local reveal_timer = 0

local card_sprites = {}
local function get_sprite(name)
    if not card_sprites[name] then
        local path = "assets/entities/cards/"..name..".png"
        if love.filesystem.getInfo(path) then
            card_sprites[name] = love.graphics.newImage(path)
        else
            card_sprites[name] = love.graphics.newImage("assets/entities/cards/card_empty.png")
        end
    end
    return card_sprites[name]
end

local function generate_grid()
    cards = {}
    flip_anims = {}
    flipped = {}
    matched = {}
    state = "waiting"
    moves = 0
    message = ""
    first_flipped = nil
    second_flipped = nil

    local available_suits = {"spades", "hearts", "clubs", "diamonds"}
    local available_ranks = {"A","K","Q","J","10","09","08","07","06","05","04","03","02"}
    local deck = {}

    math.randomseed(os.time())
    for i=1,num_pairs do
        local suit = available_suits[((i-1)%#available_suits)+1]
        local rank = available_ranks[((i-1)%#available_ranks)+1]
        table.insert(deck, {suit=suit, rank=rank})
    end

    local all = {}
    for i=1,#deck do
        table.insert(all, deck[i])
        table.insert(all, {suit=deck[i].suit, rank=deck[i].rank})
    end
    for i = #all, 2, -1 do
        local j = math.random(i)
        all[i], all[j] = all[j], all[i]
    end

    for i = 1, grid_rows * grid_cols do
        local card_info = all[i]
        local card = Card.new(card_info.suit, card_info.rank, {face_up = false})
        cards[i] = card
        flip_anims[i] = nil
        flipped[i] = false
        matched[i] = false
    end
end

function game.load()
    grid_cols = 4
    grid_rows = 4
    num_pairs = 8
    generate_grid()

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    buttons = {}
    table.insert(buttons, Button.new("Заново", sw-220, 60, 160, 48, function()
        generate_grid()
    end, {font=Fonts.normal}))

    difficulty_dropdown = Dropdown.new(60, 56, 180, 42, {"4 пары", "6 пар", "8 пар", "10 пар", "12 пар"}, 3)
    difficulty_dropdown:setOnChange(function(_, idx)
        local opts = {4,6,8,10,12}
        num_pairs = opts[idx] or 8
        grid_cols = 4
        grid_rows = math.ceil(num_pairs*2/4)
        generate_grid()
    end)

    slider = Slider.new(60, 120, 180, 32, 85, function(val) end)
end

function game.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
    difficulty_dropdown:update(dt)
    slider:update(dt)

    for i, anim in pairs(flip_anims) do
        if anim and anim:is_flipping() then
            anim:update(dt)
        end
    end

    if state == "flipping" then
        local done = true
        if first_flipped and flip_anims[first_flipped] and flip_anims[first_flipped]:is_flipping() then
            done = false
        end
        if second_flipped and flip_anims[second_flipped] and flip_anims[second_flipped]:is_flipping() then
            done = false
        end
        if done then
            local card1 = cards[first_flipped]
            local card2 = cards[second_flipped]
            if card1.suit == card2.suit and card1.rank == card2.rank then
                matched[first_flipped] = true
                matched[second_flipped] = true
                message = "Совпадение!"
            else
                flip_anims[first_flipped] = CardFlipAnimator.new(card1, 0.4)
                flip_anims[first_flipped]:flip(function() card1:set_face(false) end)
                flip_anims[second_flipped] = CardFlipAnimator.new(card2, 0.4)
                flip_anims[second_flipped]:flip(function() card2:set_face(false) end)
                message = "Не совпало!"
            end
            state = "pause"
            reveal_timer = 0.7
        end
    elseif state == "pause" then
        reveal_timer = reveal_timer - dt
        if reveal_timer <= 0 then
            first_flipped, second_flipped = nil, nil
            state = "waiting"
            message = ""
        end
    end

    local all_matched = true
    for i=1,#matched do
        if not matched[i] then all_matched = false; break end
    end
    if all_matched and state ~= "win" then
        state = "win"
        message = "Победа! За " .. tostring(moves) .. " ходов!"
    end
end

function game.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Memory Game", 0, 20, sw, "center")

    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(0.85, 0.98, 1)
    love.graphics.printf("Сложность:", 60, 30, 180, "left")
    love.graphics.printf("Размер карты:", 60, 100, 180, "left")

    for _, btn in ipairs(buttons) do btn:draw() end
    difficulty_dropdown:drawBox()
    difficulty_dropdown:drawMenu()
    slider:draw()

    local cell_size = math.max(85, math.floor(slider:getValue() * 1.6))
    local offset_x = sw/2 - (grid_cols*cell_size)/2
    local offset_y = sh/2 - (grid_rows*cell_size)/2 + 30

    for i = 1, grid_rows do
        for j = 1, grid_cols do
            local idx = (i-1)*grid_cols + j
            if idx > #cards then break end
            local card = cards[idx]
            local x = offset_x + (j-1)*cell_size
            local y = offset_y + (i-1)*cell_size
            local scale = cell_size/128

            if (first_flipped == idx or second_flipped == idx) and state ~= "win" then
                love.graphics.setColor(0.6,1,0.7, 0.55)
                love.graphics.rectangle("fill", x+4, y+4, cell_size-8, cell_size-8, 18, 18)
            end

            love.graphics.push()
            love.graphics.translate(x+cell_size/2, y+cell_size/2)
            if flip_anims[idx] and flip_anims[idx]:is_flipping() then
                local scale_x = flip_anims[idx]:get_scale_x()
                love.graphics.scale(scale_x, 1)
            end
            local sprite = get_sprite(card:get_sprite_name())
            love.graphics.setColor(matched[idx] and {0.77, 1, 0.8} or {1,1,1})
            love.graphics.draw(sprite, -64, -64, 0, scale, scale)
            love.graphics.pop()
        end
    end

    love.graphics.setFont(Fonts.normal)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Ходов: "..tostring(moves), sw-200, 120, 160, "right")
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — назад", 0, sh - 46, sw, "center")

    if message ~= "" then
        love.graphics.setFont(Fonts.big)
        love.graphics.setColor(1,1,1,0.93)
        love.graphics.printf(message, 0, sh*0.72, sw, "center")
    end
end

function game.mousepressed(x, y, button)
    if button ~= 1 then return end
    for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end
    difficulty_dropdown:mousepressed(x, y, button)
    slider:mousepressed(x, y, button)

    if state ~= "waiting" then return end

    local cell_size = math.max(85, math.floor(slider:getValue() * 1.6))
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local offset_x = sw/2 - (grid_cols*cell_size)/2
    local offset_y = sh/2 - (grid_rows*cell_size)/2 + 30

    for i = 1, grid_rows do
        for j = 1, grid_cols do
            local idx = (i-1)*grid_cols + j
            if idx > #cards then break end
            local x = offset_x + (j-1)*cell_size
            local y = offset_y + (i-1)*cell_size
            if x <= x and x <= x+cell_size and
               y <= y and y <= y+cell_size then
                local mx, my = love.mouse.getPosition()
                if mx >= x and mx <= x+cell_size and my >= y and my <= y+cell_size then
                    if not matched[idx] and not (first_flipped == idx or second_flipped == idx) then
                        if not first_flipped then
                            first_flipped = idx
                            flip_anims[idx] = CardFlipAnimator.new(cards[idx], 0.4)
                            flip_anims[idx]:flip(function() cards[idx]:set_face(true) end)
                        elseif not second_flipped then
                            second_flipped = idx
                            flip_anims[idx] = CardFlipAnimator.new(cards[idx], 0.4)
                            flip_anims[idx]:flip(function() cards[idx]:set_face(true) end)
                            moves = moves + 1
                            state = "flipping"
                        end
                    end
                end
            end
        end
    end
end

function game.mousereleased(x, y, button)
    slider:mousereleased(x, y, button)
end

function game.mousemoved(x, y, dx, dy)
    slider:mousemoved(x, y, dx, dy)
end

function game.keypressed(key)
    if key == "escape" then
        sceneManager.load("games_list")
    end
    difficulty_dropdown:keypressed(key)
    slider:keypressed(key)
end

function game.textinput(t) end

return game
