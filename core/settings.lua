local settings = {
    language = "ru",
    volume = 100,
}

local filename = "settings.lua"

function settings.save()
    local out = {"return {\n"}
    for k, v in pairs(settings) do
        local key = string.format("  [%q] = ", tostring(k))
        local val
        if type(v) == "number" or type(v) == "boolean" then
            val = tostring(v)
        else
            val = string.format("%q", tostring(v))
        end
        table.insert(out, key .. val .. ",\n")
    end
    table.insert(out, "}\n")
    love.filesystem.write(filename, table.concat(out))
end

function settings.load()
    if love.filesystem.getInfo(filename) then
        local chunk = love.filesystem.load(filename)
        local t = chunk()
        if t then
            for k,v in pairs(t) do
                settings[k] = v
            end
        end
    end
end

return settings
