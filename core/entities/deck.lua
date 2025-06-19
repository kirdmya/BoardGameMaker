local Logger = require("utils.logger")

local Deck = {}
Deck.__index = Deck

local next_deck_id = 1

function Deck.new(name)
    local self = setmetatable({}, Deck)
    self.id = next_deck_id
    next_deck_id = next_deck_id + 1

    self.name = name or "Deck"
    self.cards = {}
    self.is_animating = false
    Logger.log("Создана колода: " .. self.name)
    return self
end

function Deck:shuffle()
    local n = #self.cards
    for i = n, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
    Logger.log("Колода '" .. self.name .. "' перемешана")
end

function Deck:draw()
    local card = table.remove(self.cards)
    local name = "nil"
    if card then
        if type(card.get_display_name) == "function" then
            name = card:get_display_name()
        elseif card.name then
            name = card.name
        else
            name = tostring(card)
        end
    end
    Logger.log("Взята карта из колоды: " .. name)
    return card
end

function Deck:add(card)
    local name = "nil"
    if card then
        if type(card.get_display_name) == "function" then
            name = card:get_display_name()
        elseif card.name then
            name = card.name
        else
            name = tostring(card)
        end
    end
    table.insert(self.cards, card)
    Logger.log("В колоду добавлена карта: " .. name)
end

function Deck:serialize()
    local card_refs = {}
    for _, card in ipairs(self.cards) do
        if type(card) == "table" and card.id then
            table.insert(card_refs, card.id)
        elseif type(card) == "table" and card.name then
            table.insert(card_refs, card.name)
        else
            table.insert(card_refs, card)
        end
    end
    return {
        type = "deck",
        id = self.id,
        name = self.name,
        cards = card_refs,
    }
end

function Deck.from_table(tbl)
    local self = setmetatable({}, Deck)
    self.id = tbl.id
    self.name = tbl.name or "Deck"
    self.cards = tbl.cards or {}
    return self
end

return Deck
