local Logger = {}

Logger.filename = "log.txt"

Logger.devMode = true 

function Logger.log(msg)
    local line = os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(msg) .. "\n"
    if Logger.devMode then
        local ok, file = pcall(io.open, Logger.filename, "a")
        if ok and file then
            file:write(line)
            file:close()
            return
        end
    end
    if love and love.filesystem and love.filesystem.append then
        love.filesystem.append(Logger.filename, line)
    end
end


return Logger
