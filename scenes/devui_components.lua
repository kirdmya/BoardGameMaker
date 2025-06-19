local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local Button = require("ui.button")

local devui = {}

local components = {
    {key = "button"},
    {key = "checkbox"},
    {key = "slider"},
    {key = "number_input"},
    {key = "radiobutton"},
    {key = "dropdown"},
    {key = "textinput"},
    {key = "colorpicker"},
    {key = "listview"},
    {key = "tabbar"},
    {key = "tooltip"},
    {key = "progressbar"},
}

local buttons = {}

function devui.load()
    buttons = {}
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local buttonW, buttonH = 300, 54
    local cols = 2
    local gapX = 44
    local gapY = 16

    local count = #components
    local rows = math.ceil(count / cols)
    local startX = sw/2 - buttonW - gapX/2
    local startY = sh * 0.22

    for i, comp in ipairs(components) do
        local col = ((i - 1) % cols)
        local row = math.floor((i - 1) / cols)
        local x = startX + col * (buttonW + gapX)
        local y = startY + row * (buttonH + gapY)
        local btn = Button.new(
            I18N.t("devui." .. comp.key),
            x, y,
            buttonW, buttonH,
            function()
                local exampleScene = "devui." .. comp.key
                sceneManager.load(exampleScene)
            end,
            { font = Fonts.normal }
        )
        table.insert(buttons, btn)
    end
end

function devui.update(dt)
    for _, btn in ipairs(buttons) do btn:update(dt) end
end

function devui.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.title") or "UI Components", 0, 52, sw, "center")

    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function devui.mousepressed(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousepressed(x, y, button)
    end
end

function devui.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousereleased(x, y, button)
    end
end

function devui.keypressed(key)
    if key == "escape" then
        sceneManager.load("devmode")
    end
end

function devui.textinput(t) end

return devui
