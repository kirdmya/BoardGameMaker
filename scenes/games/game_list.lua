local sceneManager = require("utils.scene_manager")
local Button = require("ui.button")
local Fonts = require("assets.fonts")

local games = {
    {name = "21", scene = "games/twentyone"},
    {name = "Boardgame", scene = "games/boardgame"},
    {name = "Memory Card", scene = "games/memory"},
}

local game_list = {}
local buttons = {}

function game_list.load()
    buttons = {}
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    for i, g in ipairs(games) do
        local btn = Button.new(g.name, sw/2-120, 120 + i*80, 240, 60, function()
            sceneManager.load(g.scene)
        end, {font=Fonts.normal})
        table.insert(buttons, btn)
    end
end

function game_list.update(dt) for _, btn in ipairs(buttons) do btn:update(dt) end end
function game_list.draw()
    local sw = love.graphics.getWidth()
    love.graphics.setFont(Fonts.big)
    love.graphics.printf("Выберите игру", 0, 32, sw, "center")
    for _, btn in ipairs(buttons) do btn:draw() end
end
function game_list.mousepressed(x, y, button) for _, btn in ipairs(buttons) do btn:mousepressed(x, y, button) end end
function game_list.mousereleased(x, y, button) for _, btn in ipairs(buttons) do btn:mousereleased(x, y, button) end end
function game_list.keypressed(key) if key == "escape" then sceneManager.load("menu") end end
function game_list.textinput() end

return game_list
