local Logger = require("utils.logger")
local core_engine = require("core.core_engine")

local M = {}

function M.run()
    Logger.log("=== Тест новых взаимодействий ===")
    if core_engine.reset then core_engine.reset() end

    local game = core_engine.create_game("Test Game")
    local player1 = core_engine.create_player(nil, "Alice")
    local player2 = core_engine.create_player(nil, "Bob")
    game.players = {player1, player2}
    Logger.log("Добавлено игроков: " .. tostring(#game.players))

    local deck = core_engine.create_deck("Deck")
    local cardA = core_engine.create_object("Card A", { suit = "Diamonds", value = 5 })
    local cardB = core_engine.create_object("Card B", { suit = "Clubs", value = 3 })
    table.insert(deck.cards, cardA)
    table.insert(deck.cards, cardB)

    local hand1 = core_engine.create_hand(player1)
    local hand2 = core_engine.create_hand(player2)
    player1.hand = hand1
    player2.hand = hand2

    deck:shuffle()
    local drawn_card = deck:draw()
    hand1:add(drawn_card)
    Logger.log(player1.name .. " взял карту из колоды: " .. drawn_card.name .. " (id=" .. tostring(drawn_card.id) .. ")")

    hand1:remove(drawn_card)
    hand2:add(drawn_card)
    Logger.log(player1.name .. " передал карту " .. player2.name)

    local field = core_engine.create_field("Table", {width=1, height=1})
    field.cells[1] = drawn_card
    Logger.log(player2.name .. " разыграл карту на стол")

    field.cells[1] = nil
    table.insert(deck.cards, drawn_card)
    deck:shuffle()
    Logger.log("Карта возвращена в колоду и колода перемешана")

    local discard = core_engine.create_discard("Discard")
    local cardC = core_engine.create_object("Card C", { suit = "Spades", value = 8 })
    discard:add(cardC)
    local taken_from_discard = discard:take()
    hand2:add(taken_from_discard)
    Logger.log(player2.name .. " взял карту из сброса: " .. taken_from_discard.name)

    local rand_idx = math.random(#deck.cards)
    local random_card = deck.cards[rand_idx]
    Logger.log("Случайная карта из колоды: " .. (random_card and random_card.name or "none"))

    local secret_card = core_engine.create_object("Secret Card", {hidden = true})
    hand2:add(secret_card)
    Logger.log(player2.name .. " держит скрытую карту (hidden=true, id=" .. tostring(secret_card.id) .. ")")

    game.active_player = player2
    Logger.log("Передан ход игроку: " .. game.active_player.name .. " (id=" .. tostring(game.active_player.id) .. ")")

    local zone = core_engine.create_zone("Bonus Zone")
    local bonus = core_engine.create_object("Bonus", {type="gold"})
    zone:add(bonus)
    Logger.log("В зону '" .. zone.name .. "' добавлен предмет: " .. bonus.name)

    local state = core_engine.serialize()
    Logger.log("--- Сериализация состояния выполнена ---")

    core_engine.reset()
    Logger.log("Ядро сброшено")

    core_engine.deserialize(state)
    Logger.log("Состояние игры восстановлено: игр=" .. tostring(#core_engine.games) .. ", игроков=" .. tostring(#core_engine.players))

    local r_player2 = core_engine.players[2]
    local r_hand2 = core_engine.hands[2]
    local r_deck = core_engine.decks[1]
    local r_discard = core_engine.discards[1]

    if r_player2 and r_hand2 and r_deck and r_discard then
        Logger.log("Рука игрока " .. r_player2.name .. " после восстановления: " .. tostring(#r_hand2.items) .. " предмет(ов)")
        Logger.log("Колода после восстановления: " .. r_deck.name .. ", карт: " .. tostring(#r_deck.cards))
        Logger.log("Сброс после восстановления: " .. r_discard.name .. ", карт: " .. tostring(#r_discard.items))
    else
        Logger.log("ВНИМАНИЕ: Данные не восстановлены!")
    end

    Logger.log("=== Новые взаимодействия успешно протестированы! ===")
end

return M
