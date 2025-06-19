local Logger = require("utils.logger")

local Card = {}
Card.__index = Card

local next_card_id = 1

function Card.new(suit, rank, props)
    local self = setmetatable({}, Card)
    self.suit = suit
    self.rank = rank
    self.face_up = props and props.face_up or false
    self.id = props and props.id or next_card_id
    next_card_id = self.id + 1
    self.extra = props or {}
    Logger.log(string.format("Создана карта: %s %s", tostring(suit), tostring(rank)))
    return self
end

function Card:is_face_up()
    return self.face_up
end

function Card:flip()
    self.face_up = not self.face_up
    Logger.log("Карта перевёрнута: " .. tostring(self:get_display_name()))
end

function Card:set_face(up)
    self.face_up = up and true or false
end

function Card:get_display_name()
    if self.suit == "joker" then
        return self.rank == "joker_black" and "Joker Black"
            or self.rank == "joker_red" and "Joker Red"
            or "Joker"
    end
    return string.format("%s %s", tostring(self.suit), tostring(self.rank))
end

function Card:get_sprite_name()
    if not self.face_up then
        return "card_back"
    end
    if self.suit == "joker" then
        if self.rank == "joker_black" then return "card_joker_black" end
        if self.rank == "joker_red" then return "card_joker_red" end
        return "card_joker_red"
    end
    if not self.suit or not self.rank then
        return "card_empty"
    end
    local r = tostring(self.rank)
    if r:match("^%d$") then r = "0" .. r end
    return string.format("card_%s_%s", tostring(self.suit), r)
end


function Card:equals(other)
    return other
        and self.suit == other.suit
        and self.rank == other.rank
end

function Card:get_id()
    return self.id
end

function Card:clone()
    local new_props = {}
    for k, v in pairs(self.extra or {}) do new_props[k] = v end
    new_props.face_up = self.face_up
    new_props.id = self.id
    return Card.new(self.suit, self.rank, new_props)
end

function Card:get_value()
    local v = self.rank
    if tonumber(v) then return tonumber(v) end
    if v == "A" then return 11 end
    if v == "K" or v == "Q" or v == "J" then return 10 end
    return 0
end

function Card:is_suit(suit)
    return self.suit == suit
end

function Card:serialize()
    return {
        suit = self.suit,
        rank = self.rank,
        face_up = self.face_up,
        id = self.id,
        extra = self.extra,
    }
end

function Card.from_table(tbl)
    return Card.new(tbl.suit, tbl.rank, tbl)
end

function Card:__tostring()
    return string.format("[Card #%s: %s %s %s]", tostring(self.id), tostring(self.suit), tostring(self.rank), self.face_up and "face_up" or "face_down")
end

return Card
