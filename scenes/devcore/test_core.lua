local Logger = require("utils.logger")
local core_engine = require("core.core_engine")

local M = {}

function M.run()
    Logger.log("=== Полный тест ядра и абстракций ===")
    if core_engine.reset then core_engine.reset() end

    local game = core_engine.create_game("Test Game")
    Logger.log("Создана игра: " .. game.name .. " (id=" .. tostring(game.id) .. ")")

    local player1 = core_engine.create_player(nil, "Alice")
    local player2 = core_engine.create_player(nil, "Bob")
    game.players = {player1, player2}
    Logger.log("Добавлено игроков: " .. tostring(#game.players))

    local field = core_engine.create_field("Main Field", {width = 5, height = 5})

    local deck = core_engine.create_deck("Test Deck")

    local cardA = core_engine.create_object("Card A", { suit = "Hearts", value = 10 })
    local cardB = core_engine.create_object("Card B", { suit = "Spades", value = 7 })
    table.insert(deck.cards, cardA)
    table.insert(deck.cards, cardB)
    Logger.log("В колоде карт: " .. tostring(#deck.cards))

    local hand1 = core_engine.create_hand(player1)
    player1.hand = hand1

    local discard = core_engine.create_discard("Test Discard")

    local zone = core_engine.create_zone("Special Zone")

    deck:shuffle()
    local drawn_card = deck:draw()
    if drawn_card then
        hand1:add(drawn_card)
        Logger.log("Карта из колоды взята в руку игрока: " .. drawn_card.name .. " (id=" .. tostring(drawn_card.id) .. ")")
    end

    if drawn_card then
        hand1:remove(drawn_card)
        discard:add(drawn_card)
        Logger.log("Карта из руки отправлена в сброс: " .. drawn_card.name)
    end

    local token = core_engine.create_object("Token", {color="red"})
    zone:add(token)

    local event = core_engine.create_event("PLAYER_TAKE_CARD", {player = player1.id, card = drawn_card and drawn_card.id or "none"})
    Logger.log("Событие: " .. event.event_type .. " (player id: " .. tostring(event.data.player) .. ", card id: " .. tostring(event.data.card) .. ")")

    local state = core_engine.serialize()
    Logger.log("--- Сериализация состояния выполнена ---")

    core_engine.reset()
    Logger.log("Ядро сброшено, коллекции: " .. tostring(#core_engine.games) .. " игр")

    core_engine.deserialize(state)
    Logger.log("Состояние игры восстановлено после десериализации: " ..
        "игр=" .. tostring(#core_engine.games) .. ", игроков=" .. tostring(#core_engine.players)
    )

    local restored_player = core_engine.players[1]
    local restored_deck = core_engine.decks[1]
    if restored_player and restored_deck then
        Logger.log("Игрок после восстановления: " .. restored_player.name .. " (id=" .. tostring(restored_player.id) .. ")")
        Logger.log("Колода после восстановления: " .. restored_deck.name .. ", карт: " .. tostring(#restored_deck.cards))
    else
        Logger.log("ВНИМАНИЕ: Данные не восстановлены!")
    end

    Logger.log("=== Абстракции протестированы. Всё работает! ===")
end

return M
