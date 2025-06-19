local Game    = require("core.entities.game")
local Player  = require("core.entities.player")
local Object  = require("core.entities.object")
local Event   = require("core.entities.event")
local Field   = require("core.entities.field")
local Deck    = require("core.entities.deck")
local Hand    = require("core.entities.hand")
local Discard = require("core.entities.discard")
local Zone    = require("core.entities.zone")

local core_engine = {}

local from_table_constructors = {
    game    = Game.from_table,
    player  = Player.from_table,
    object  = Object.from_table,
    event   = Event.from_table,
    field   = Field.from_table,
    deck    = Deck.from_table,
    hand    = Hand.from_table,
    discard = Discard.from_table,
    zone    = Zone.from_table,
}

local constructors = {
    game    = Game.new,
    player  = Player.new,
    object  = Object.new,
    event   = Event.new,
    field   = Field.new,
    deck    = Deck.new,
    hand    = Hand.new,
    discard = Discard.new,
    zone    = Zone.new,

}

core_engine.entities = {}
for name in pairs(constructors) do
    core_engine.entities[name] = {}
end

for type_name, ctor in pairs(constructors) do
    core_engine["create_" .. type_name] = function(...)
        local obj = ctor(...)
        table.insert(core_engine.entities[type_name], obj)
        return obj
    end
end

core_engine.games    = core_engine.entities.game
core_engine.players  = core_engine.entities.player
core_engine.objects  = core_engine.entities.object
core_engine.events   = core_engine.entities.event
core_engine.fields   = core_engine.entities.field
core_engine.decks    = core_engine.entities.deck
core_engine.hands    = core_engine.entities.hand
core_engine.discards = core_engine.entities.discard
core_engine.zones    = core_engine.entities.zone

function core_engine.find(type_name, predicate)
    for _, obj in ipairs(core_engine.entities[type_name] or {}) do
        if predicate(obj) then
            return obj
        end
    end
end

function core_engine.remove(type_name, obj)
    local list = core_engine.entities[type_name]
    for i = #list, 1, -1 do
        if list[i] == obj then
            table.remove(list, i)
            return true
        end
    end
    return false
end

function core_engine.reset()
    for type_name in pairs(core_engine.entities) do
        core_engine.entities[type_name] = {}
    end
end

core_engine.rules = {}

function core_engine.add_rule(rule)
    table.insert(core_engine.rules, rule)
end

function core_engine.clear_rules()
    core_engine.rules = {}
end

core_engine.subscribers = {}

function core_engine.on(event_type, handler)
    core_engine.subscribers[event_type] = core_engine.subscribers[event_type] or {}
    table.insert(core_engine.subscribers[event_type], handler)
end

function core_engine.emit(event_type, data)
    for _, handler in ipairs(core_engine.subscribers[event_type] or {}) do
        handler(data)
    end
    for _, rule in ipairs(core_engine.rules) do
        local match = (rule.event == event_type)
        if not rule.event or match then
            if not rule.condition or rule.condition(data) then
                rule.action(data)
            end
        end
    end
end


function core_engine.serialize()
    local data = { meta = { version = 1 }, entities = {} }
    for type_name, list in pairs(core_engine.entities) do
        data.entities[type_name] = {}
        for _, obj in ipairs(list) do
            if obj.serialize then
                table.insert(data.entities[type_name], obj:serialize())
            else
                table.insert(data.entities[type_name], obj)
            end
        end
    end
    return data
end

function core_engine.deserialize(data)
    core_engine.reset()
    local refs = {}
    local entities = data.entities or data

    for type_name, list in pairs(entities or {}) do
        core_engine.entities[type_name] = {}
        refs[type_name] = {}
        for _, entry in ipairs(list) do
            local obj
            local from_tbl = from_table_constructors[type_name]
            if from_tbl then
                obj = from_tbl(entry)
            else
                obj = constructors[type_name](entry.name or entry.id or "")
                for k, v in pairs(entry) do
                    if k ~= "name" and k ~= "id" then obj[k] = v end
                end
            end
            table.insert(core_engine.entities[type_name], obj)
            if entry.id then refs[type_name][entry.id] = obj end
            if entry.name then refs[type_name][entry.name] = obj end
        end
    end

    for type_name, list in pairs(entities or {}) do
        for idx, entry in ipairs(list) do
            local obj = core_engine.entities[type_name][idx]
            if type_name == "player" and entry.game_id then
                obj.game = refs.game[entry.game_id]
            end
            if type_name == "hand" and entry.owner then
                obj.owner = refs.player[entry.owner]
            end
            if type_name == "game" and entry.players then
                obj.players = {}
                for _, pid in ipairs(entry.players) do
                    table.insert(obj.players, refs.player[pid])
                end
            end
            if (type_name == "deck" or type_name == "discard" or type_name == "zone" or type_name == "hand") and entry.items then
                obj.items = {}
                for _, iid in ipairs(entry.items) do
                    obj.items[#obj.items+1] = refs.object and refs.object[iid] or refs.item and refs.item[iid] or iid
                end
            end
            if type_name == "deck" and entry.cards then
                obj.cards = {}
                for _, cid in ipairs(entry.cards) do
                    obj.cards[#obj.cards+1] = refs.object and refs.object[cid] or refs.item and refs.item[cid] or cid
                end
            end
        end
    end
end


return core_engine
