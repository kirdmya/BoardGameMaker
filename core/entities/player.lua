local Logger = require("utils.logger")

local Player = {}
Player.__index = Player

local next_player_id = 1

function Player.new(id, name)
    local self = setmetatable({}, Player)
    if not id then
        self.id = next_player_id
        next_player_id = next_player_id + 1
    else
        self.id = id
        if id >= next_player_id then
            next_player_id = id + 1
        end
    end

    self.name = name or ("Player " .. tostring(self.id))
    self.hand = {}      
    self.props = {}    
    self.game = nil      
    Logger.log("Создан игрок: " .. self.name)
    return self
end

function Player:serialize()
    local hand_ids = {}
    for _, item in ipairs(self.hand) do
        if type(item) == "table" and item.id then
            table.insert(hand_ids, item.id)
        elseif type(item) == "table" and item.name then
            table.insert(hand_ids, item.name)
        else
            table.insert(hand_ids, item)
        end
    end
    return {
        type = "player",
        id = self.id,
        name = self.name,
        hand = hand_ids,
        props = self.props,
        game_id = self.game and self.game.id or nil,
    }
end

function Player.from_table(tbl)
    local self = setmetatable({}, Player)
    self.id = tbl.id
    self.name = tbl.name or ("Player " .. tostring(tbl.id))
    self.hand = tbl.hand or {}
    self.props = tbl.props or {}
    self.game = tbl.game_id 
    return self
end

return Player
