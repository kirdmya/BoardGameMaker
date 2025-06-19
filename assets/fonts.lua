local Fonts = {}

Fonts.big = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf", 48)
Fonts.normal = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf", 32)
Fonts.small = love.graphics.newFont("assets/fonts/Roboto-Regular.ttf", 20)

function Fonts.load()
    love.graphics.setFont(Fonts.normal)
end

return Fonts

