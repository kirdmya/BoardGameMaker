local sceneManager = require("utils.scene_manager")
local I18N = require("locales")
local Fonts = require("assets.fonts")
local Tooltip = require("ui.tooltip")
local Button = require("ui.button")

local demo = {}

local btnInfo, btnWarn, btnBack
local tooltip

function demo.load()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    tooltip = Tooltip.new()

    btnInfo = Button.new(
        I18N.t("devui.tooltip_btn1"),
        sw/2 - 170, sh*0.33, 160, 50,
        function() end, 
        { font = Fonts.normal }
    )

    btnWarn = Button.new(
        I18N.t("devui.tooltip_btn2"),
        sw/2 + 10, sh*0.33, 160, 50,
        function() end,
        { font = Fonts.normal }
    )

    btnBack = Button.new(
        I18N.t("settings.back"),
        sw/2 - 80, sh*0.33 + 100, 160, 44,
        function() sceneManager.load("devui_components") end,
        { font = Fonts.normal }
    )
end

function demo.update(dt)
    btnInfo:update(dt)
    btnWarn:update(dt)
    btnBack:update(dt)
    tooltip:update(dt)
end

function demo.draw()
    local sw = love.graphics.getWidth()
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(Fonts.big)
    love.graphics.printf(I18N.t("devui.tooltip_demo_title"), 0, 56, sw, "center")
    love.graphics.setFont(Fonts.small)
    love.graphics.printf(I18N.t("devui.tooltip_instruction"), 0, 120, sw, "center")

    btnInfo:draw()
    btnWarn:draw()
    btnBack:draw()
    tooltip:draw()
end

function demo.mousepressed(x, y, button)
    btnInfo:mousepressed(x, y, button)
    btnWarn:mousepressed(x, y, button)
    btnBack:mousepressed(x, y, button)
end

function demo.mousereleased(x, y, button)
    btnBack:mousereleased(x, y, button)
end

function demo.keypressed(key)
    if key == "escape" then
        sceneManager.load("devui_components")
    end
end

function demo.updateTooltip(dt)
    local mx, my = love.mouse.getPosition()
    if btnInfo.state == "hover" then
        tooltip:show(I18N.t("devui.tooltip_text_info"), mx, my)
    elseif btnWarn.state == "hover" then
        tooltip:show(I18N.t("devui.tooltip_text_warn"), mx, my)
    else
        tooltip:hide()
    end
end

local oldUpdate = demo.update
function demo.update(dt)
    oldUpdate(dt)
    demo.updateTooltip(dt)
end

function demo.textinput() end

return demo
