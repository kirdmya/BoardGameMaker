local Logger = require("utils.logger")

local Game = {}
Game.__index = Game

local next_game_id = 1

function Game.new(name)
    local self = setmetatable({}, Game)
    self.id = next_game_id
    next_game_id = next_game_id + 1

    self.name = name or "Game"
    self.players = {}    
    self.zones = {}     
    self.state = {}      
    self.active_player = nil 
    self.phase = nil        
    Logger.log("Создана игра: " .. self.name)
    return self
end

function Game:serialize()
    local player_ids = {}
    for _, player in ipairs(self.players) do
        if type(player) == "table" and player.id then
            table.insert(player_ids, player.id)
        elseif type(player) == "table" and player.name then
            table.insert(player_ids, player.name)
        else
            table.insert(player_ids, player)
        end
    end

    local zone_ids = {}
    for _, zone in ipairs(self.zones) do
        if type(zone) == "table" and zone.id then
            table.insert(zone_ids, zone.id)
        elseif type(zone) == "table" and zone.name then
            table.insert(zone_ids, zone.name)
        else
            table.insert(zone_ids, zone)
        end
    end

    return {
        type = "game",
        id = self.id,
        name = self.name,
        players = player_ids,
        zones = zone_ids,
        state = self.state,
        active_player = self.active_player and self.active_player.id or self.active_player,
        phase = self.phase,
    }
end

function Game.from_table(tbl)
    local self = setmetatable({}, Game)
    self.id = tbl.id
    self.name = tbl.name or "Game"
    self.players = tbl.players or {} 
    self.zones = tbl.zones or {}
    self.state = tbl.state or {}
    self.active_player = tbl.active_player
    self.phase = tbl.phase
    return self
end

return Game
