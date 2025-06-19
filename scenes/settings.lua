local I18N = require("locales")
local Dropdown = require("ui.dropdown")
local sceneManager = require("utils.scene_manager")
local Logger = require("utils.logger")
local Fonts = require("assets.fonts")

local settings = {}
local langDropdown

function settings.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local langs = I18N.availableLanguages()
    local currentIdx = 1
    for i, code in ipairs(langs) do
        if code == I18N.getLanguage() then currentIdx = i end
    end
    local langNames = {}
    for _, code in ipairs(langs) do
        if code == "ru" then
            table.insert(langNames, "Русский")
        elseif code == "en" then
            table.insert(langNames, "English")
        else
            table.insert(langNames, code)
        end
    end
    langDropdown = Dropdown.new(sw/2 - 100, sh/2 - 30, 200, 40, langNames, currentIdx)
    langDropdown:setOnChange(function(_, idx)
        local code = langs[idx]
        I18N.setLanguage(code)
        Logger.log("Выбран язык: " .. code)
        sceneManager.load("settings") 
    end)
end

function settings.update(dt)
    if langDropdown and langDropdown.update then
        langDropdown:update(dt)
    end
end

function settings.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf(I18N.t("settings.language"), 0, love.graphics.getHeight()/2 - 70, love.graphics.getWidth(), "center")

    if langDropdown then
        langDropdown:drawBox()
        langDropdown:drawMenu()
    end

    love.graphics.setFont(Fonts.small)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, love.graphics.getHeight() - 64, love.graphics.getWidth(), "center")
end

function settings.mousepressed(x, y, button)
    if langDropdown and langDropdown.mousepressed then
        langDropdown:mousepressed(x, y, button)
    end
end

function settings.keypressed(key)
    if langDropdown and langDropdown.keypressed then
        langDropdown:keypressed(key)
    end
    if key == "escape" then
        sceneManager.load("menu")
    end
end

function settings.mousereleased(x, y, button) end

return settings
