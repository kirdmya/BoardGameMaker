local M = {}

local loadedLocales = {}
local currentLocale = nil
local currentLang = "ru" 

local function loadLocale(lang)
    if not loadedLocales[lang] then
        local ok, locale = pcall(require, "locales." .. lang)
        if ok then
            loadedLocales[lang] = locale
        else
            error("Locale load error: " .. tostring(locale))
        end
    end
    return loadedLocales[lang]
end

function M.setLanguage(lang)
    currentLang = lang
    currentLocale = loadLocale(lang)
end

function M.getLanguage()
    return currentLang
end

function M.availableLanguages()
    return {"ru", "en"}
end

function M.t(key)
    if not currentLocale then
        currentLocale = loadLocale(currentLang)
    end
    local t = currentLocale
    for k in string.gmatch(key, "[^%.]+") do
        t = t[k]
        if not t then return "??"..key.."??" end
    end
    return t
end

return M
