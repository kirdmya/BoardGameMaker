local Logger = require("utils.logger")

local sceneManager = {
    current = nil
}

function sceneManager.load(sceneName)
    local ok, result = pcall(require, "scenes." .. sceneName)
    if ok then
        if result == nil then
            Logger.log("Ошибка загрузки сцены: возвращён nil из scenes/" .. sceneName .. ".lua")
        else
            sceneManager.current = result
            if sceneManager.current.load then
                sceneManager.current.load()
            end
        end
    else
        Logger.log("Ошибка загрузки сцены: " .. tostring(result))
    end
end

function sceneManager.update(dt)
    if sceneManager.current and sceneManager.current.update then
        sceneManager.current.update(dt)
    end
end

function sceneManager.draw()
    if sceneManager.current and sceneManager.current.draw then
        sceneManager.current.draw()
    end
end

function sceneManager.keypressed(key)
    if sceneManager.current and sceneManager.current.keypressed then
        sceneManager.current.keypressed(key)
    end
end

function sceneManager.mousepressed(x, y, button)
    if sceneManager.current and sceneManager.current.mousepressed then
        sceneManager.current.mousepressed(x, y, button)
    end
end

function sceneManager.mousereleased(x, y, button)
    if sceneManager.current and sceneManager.current.mousereleased then
        sceneManager.current.mousereleased(x, y, button)
    end
end


function sceneManager.textinput(t)
    if sceneManager.current and sceneManager.current.textinput then
        sceneManager.current.textinput(t)
    end
end


function sceneManager.mousemoved(x, y, dx, dy, istouch)
    if sceneManager.current and sceneManager.current.mousemoved then
        sceneManager.current.mousemoved(x, y, dx, dy, istouch)
    end
end

function sceneManager.wheelmoved(x, y)
    if sceneManager.current and sceneManager.current.wheelmoved then
        sceneManager.current.wheelmoved(x, y)
    end
end

return sceneManager
