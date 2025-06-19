local Logger = require("utils.logger")

local assets = {
    cards = {
        large = {}
    },
    ui = {
        icons = {}
    },
    sounds = {
        click = {},
        switch = {},
        tap = {}
    }
}

function assets.loadAll()
    Logger.log("Загрузка ассетов...")
    assets.loadCards("assets/entities/cards")
    assets.loadUI("assets/ui")
    assets.loadUIIcons("assets/ui/Blue/Double")
    assets.loadSounds("assets/sounds")
    Logger.log("Ассеты загружены")
end

function assets.loadCards(path)
    if love.filesystem.getInfo(path) then
        for _, filename in ipairs(love.filesystem.getDirectoryItems(path)) do
            if filename:match("%.png$") or filename:match("%.jpg$") or filename:match("%.jpeg$") then
                local name = filename:gsub("%..+$", "")
                assets.cards.large[name] = love.graphics.newImage(path.."/"..filename)
                Logger.log("Загружена карта: "..path.."/"..filename)
            end
        end
    else
        Logger.log("Папка с картами не найдена: "..path)
    end
end

function assets.loadUI(basePath)
    local colors = {"Blue", "Green", "Grey", "Red", "Yellow", "Extra"}
    local variants = {"Default", "Double"}

    for _, color in ipairs(colors) do
        assets.ui[color] = {}

        for _, variant in ipairs(variants) do
            local path = basePath.."/"..color.."/"..variant
            if love.filesystem.getInfo(path) then
                assets.ui[color][variant] = {}

                for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
                    if file:match("%.png$") then
                        local name = file:gsub("%.png$", "")
                        assets.ui[color][variant][name] = love.graphics.newImage(path.."/"..file)
                        Logger.log(("Загружен UI-ассет: %s/%s/%s"):format(color, variant, file))
                    end
                end
            else
                Logger.log("Папка UI не найдена: "..path)
            end
        end
    end
end

function assets.loadUIIcons(path)
    local iconFiles = {
        "check_round_color.png",
        "check_round_round_circle.png",
        "icon_outline_circle.png",
        "icon_circle.png",
        "icon_checkmark.png",
        "icon_cross.png",
        "icon_outline_checkmark.png",
        "icon_outline_cross.png",
        "icon_square.png",
        "icon_outline_square.png"
    }

    for _, file in ipairs(iconFiles) do
        local fullPath = path .. "/" .. file
        local name = file:gsub("%.png$", "")
        if love.filesystem.getInfo(fullPath) then
            assets.ui.icons[name] = love.graphics.newImage(fullPath)
            Logger.log("Загружена иконка: "..fullPath)
        else
            Logger.log("❌ Не найден файл иконки: "..fullPath)
        end
    end
end

function assets.loadSounds(path)
    if not love.filesystem.getInfo(path) then
        Logger.log("Папка со звуками не найдена: "..path)
        return
    end

    local soundFiles = love.filesystem.getDirectoryItems(path)

    for _, file in ipairs(soundFiles) do
        if file:match("%.ogg$") then
            local category = file:match("^(%a+)-")
            if category and assets.sounds[category] then
                local fullPath = path.."/"..file
                local sound = love.audio.newSource(fullPath, "static")
                table.insert(assets.sounds[category], sound)
                Logger.log("Загружен звук: "..fullPath)
            else
                Logger.log("Не удалось определить категорию для звука: "..file)
            end
        end
    end
end

return assets
