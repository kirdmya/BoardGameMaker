local Settings = require("core.settings")
local I18N = require("locales")
local sceneManager = require("utils.scene_manager")

AppMode = "game"

function love.load()
    Settings.load()
    I18N.setLanguage(Settings.language or "ru")
    local Fonts = require("assets.fonts")
    Fonts.load()
    sceneManager.load("menu")
end

function love.update(dt)
    sceneManager.update(dt)   
end

function love.draw()
    sceneManager.draw()
end

function love.keypressed(key)
    sceneManager.keypressed(key)
end


function love.mousepressed(x, y, button)
    sceneManager.mousepressed(x, y, button)  
end

function love.mousereleased(x, y, button)
    sceneManager.mousereleased(x, y, button) 
end


function love.textinput(t)
    if sceneManager.textinput then
        sceneManager.textinput(t)
    end
end

function love.wheelmoved(dx, dy)
    if sceneManager.wheelmoved then
        sceneManager.wheelmoved(dx, dy)
    end
end


