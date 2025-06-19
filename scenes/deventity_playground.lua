local Logger = require("utils.logger")
local core_engine = require("core.core_engine")
local Button = require("ui.button")
local Fonts = require("assets.fonts")
local I18N = require("locales")
local sceneManager = require("utils.scene_manager")

local deventity_playground = {}

local buttons = {}
local created_objects = {}
local last_log = ""

local function summary()
    return string.format(
        "Games: %d   Players: %d   Objects: %d   Decks: %d   Hands: %d   Zones: %d",
        #(core_engine.entities.game or {}),
        #(core_engine.entities.player or {}),
        #(core_engine.entities.object or {}),
        #(core_engine.entities.deck or {}),
        #(core_engine.entities.hand or {}),
        #(core_engine.entities.zone or {})
    )
end

function deventity_playground.load()
    buttons = {}
    created_objects = {}
    last_log = ""

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local buttonW, buttonH = 300, 48
    local startY = sh * 0.24
    local btnX = sw / 2 - buttonW / 2

    local add_y = 0

    local function add_btn(label, action)
        local btn = Button.new(label, btnX, startY + add_y, buttonW, buttonH, function()
            action()
        end, { font = Fonts.normal })
        table.insert(buttons, btn)
        add_y = add_y + buttonH + 16
    end

    add_btn(I18N.t("entities.add_player", "Add Player"), function()
        local p = core_engine.create_player(nil, "Test Player " .. tostring(#core_engine.entities.player + 1))
        table.insert(created_objects, p)
        last_log = "Создан игрок: " .. p.name .. " (id=" .. tostring(p.id or "?") .. ")"
        Logger.log(last_log)
    end)

    add_btn(I18N.t("entities.add_object", "Add Object"), function()
        local o = core_engine.create_object("Object " .. tostring(#core_engine.entities.object + 1), {value=math.random(100)})
        table.insert(created_objects, o)
        last_log = "Создан объект: " .. o.name .. " (id=" .. tostring(o.id or "?") .. ")"
        Logger.log(last_log)
    end)

    add_btn(I18N.t("entities.add_deck", "Add Deck"), function()
        local d = core_engine.create_deck("Deck " .. tostring(#core_engine.entities.deck + 1))
        table.insert(created_objects, d)
        last_log = "Создана колода: " .. d.name .. " (id=" .. tostring(d.id or "?") .. ")"
        Logger.log(last_log)
    end)

    add_btn(I18N.t("entities.clear", "Clear All"), function()
        if core_engine.reset then core_engine.reset() end
        created_objects = {}
        last_log = "Все сущности сброшены."
        Logger.log(last_log)
    end)
end

function deventity_playground.update(dt)
    for _, btn in ipairs(buttons) do
        btn:update(dt)
    end
end

function deventity_playground.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.big)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(I18N.t("entities.playground_title", "Entities Playground"), 0, 44, sw, "center")

    for _, btn in ipairs(buttons) do
        btn:draw()
    end

    local summary_y = sh * 0.24 + (#buttons) * (48 + 16) + 20
    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.7, 1, 0.9)
    love.graphics.printf(summary(), 0, summary_y, sw, "center")

    love.graphics.setColor(0.85, 0.87, 1)
    love.graphics.printf(last_log or "", 0, summary_y + 32, sw, "center")

    love.graphics.setFont(Fonts.small)
    love.graphics.setColor(0.72, 0.72, 0.82)
    love.graphics.printf("ESC — " .. (I18N.getLanguage() == "ru" and "назад" or "back"), 0, sh - 50, sw, "center")
end

function deventity_playground.keypressed(key)
    if key == "escape" then
        sceneManager.load("devmode")
    end
end

function deventity_playground.mousepressed(x, y, button)
    for i, btn in ipairs(buttons) do
        btn:mousepressed(x, y, button)
    end
end

function deventity_playground.mousereleased(x, y, button)
    for _, btn in ipairs(buttons) do
        btn:mousereleased(x, y, button)
    end
end

function deventity_playground.textinput(t) end

return deventity_playground
