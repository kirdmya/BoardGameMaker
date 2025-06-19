local Dropdown = require("ui.dropdown")
local Logger = require("utils.logger")
local devui = {}

local dd

function devui.load()
    dd = Dropdown.new(
        love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2 - 24,
        200, 40,
        {"Русский", "English", "Deutsch", "Español", "日本語"}, 1
    )
    dd:setOnChange(function(val, idx)
        Logger.log("Выбран язык: " .. val .. " (№" .. idx .. ")")
    end)
end

function devui.update(dt)
    dd:update(dt)
end

function devui.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Dropdown (выберите язык):", 0, 40, love.graphics.getWidth(), "center")
    dd:draw()
end

function devui.mousepressed(x, y, button)
    dd:mousepressed(x, y, button)
end

function devui.keypressed(key)
    dd:keypressed(key)
    if key == "escape" then
        local sceneManager = require("utils.scene_manager")
        sceneManager.load("menu")
    end
end

return devui
