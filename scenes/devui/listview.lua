local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local ListView = require("ui.listview")
local Button = require("ui.button")

local demo = {}

local list
local logMsg = ""
local btnBack

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    logMsg = ""
    local items = {}
    for i = 1, 30 do
        table.insert(items, I18N.getLanguage() == "ru" and ("Элемент " .. i) or ("Item " .. i))
    end
    list = ListView.new(sw/2-170, sh*0.22, 340, 330, items, {
        onClick = function(val, idx)
            logMsg = (I18N.getLanguage() == "ru" and "Выбран: " or "Selected: ") .. tostring(val)
        end,
        itemHeight = 44,
        font = Fonts.normal
    })

    btnBack = Button.new(
        I18N.t("settings.back"),
        sw/2-60, sh*0.22+350, 120, 44,
        function() sceneManager.load("devui_components") end,
        {font = Fonts.normal}
    )
end

function demo.update(dt)
    list:update(dt)
    btnBack:update(dt)
end

function demo.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.listview_demo_title") or "ListView", 0, 48, sw, "center")

    list:draw()
    btnBack:draw()

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(logMsg, 0, sh*0.22+400, sw, "center")
end

function demo.mousepressed(x, y, button)
    list:mousepressed(x, y, button)
    btnBack:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnBack:mousereleased(x, y, button)
end

function demo.keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.wheelmoved(dx, dy)
    list:wheelmoved(dx, dy)
end

function demo.textinput(t) end

return demo
