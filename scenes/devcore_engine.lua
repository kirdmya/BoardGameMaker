local sceneManager = require("utils.scene_manager")
local Fonts = require("assets.fonts")
local Button = require("ui.button")
local I18N = require("locales") 

local devcore_engine = {}
local buttons = {}

local test_list = {
    {
        file = "scenes.devcore.test_core",
        loc_key = "core_tests.run_basic",
        fallback = "Core Test"
    },
    {
        file = "scenes.devcore.test_interactions",
        loc_key = "core_tests.run_interactions",
        fallback = "Test Interactions"
    },
}

local function get_loc(path, fallback)
    local node = I18N.devcore
    for part in string.gmatch(path, "[^%.]+") do
        node = node and node[part]
    end
    return node or fallback
end

function devcore_engine.load()
    buttons = {}
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local buttonW, buttonH = 320, 60
    local startY = sh * 0.30

    for i, t in ipairs(test_list) do
        local btn = Button.new(
            get_loc(t.loc_key, t.fallback),
            sw/2 - buttonW/2,
            startY + (i-1) * (buttonH + 24),
            buttonW,
            buttonH,
            function()
                local ok, err = pcall(function()
                    local test_mod = require(t.file)
                    if type(test_mod.run) == "function" then
                        test_mod.run()
                    else
                        print("Ошибка: " .. t.file .. ".run не функция")
                    end
                end)
                if not ok then
                    print("Ошибка при выполнении теста: " .. tostring(err))
                end
            end,
            { font = Fonts.normal }
        )
        if not btn or type(btn) ~= "table" then
            error("Button.new вернула не объект, а: " .. tostring(btn))
        end
        table.insert(buttons, btn)
    end
end

function devcore_engine.update(dt)
    for _, btn in ipairs(buttons) do
        if btn and type(btn) == "table" and btn.update then
            btn:update(dt)
        end
    end
end

function devcore_engine.draw()
    local sw = love.graphics.getWidth()
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(get_loc("page_title", "DevCore Engine Tests"), 0, 52, sw, "center")
    for _, btn in ipairs(buttons) do
        if btn and type(btn) == "table" and btn.draw then
            btn:draw()
        end
    end
end

function devcore_engine.keypressed(key)
    if key == "escape" then
        sceneManager.load("menu")
    end
end

function devcore_engine.mousepressed(x, y, button)
    for i, btn in ipairs(buttons) do
        if btn and type(btn) == "table" and btn.mousepressed then
            btn:mousepressed(x, y, button)
        end
    end
end

function devcore_engine.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        if btn and type(btn) == "table" and btn.mousereleased then
            btn:mousereleased(x, y, button)
        end
    end
end

return devcore_engine
