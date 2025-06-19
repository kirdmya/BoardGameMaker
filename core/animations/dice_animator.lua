-- core/animations/dice_animator.lua
-- Универсальный аниматор для кубика
local DiceAnimator = {}
DiceAnimator.__index = DiceAnimator

function DiceAnimator.new(dice, params)
    local self = setmetatable({}, DiceAnimator)
    self.dice = dice
    self.duration = params and params.duration or 1.5
    self.frame_time = params and params.frame_time or 0.33
    self.stateA = params and params.stateA or "empty"
    self.stateB = params and params.stateB or "question"
    self.timer = 0
    self.frame_timer = 0
    self.animating = false
    self.callback = nil
    self.show_stateA = true
    return self
end

function DiceAnimator:start(callback)
    self.timer = 0
    self.frame_timer = 0
    self.animating = true
    self.callback = callback
    self.show_stateA = true
    if self.dice and self.dice.reset then
        self.dice:reset()
    end
end

function DiceAnimator:update(dt)
    if not self.animating then return end
    self.timer = self.timer + dt
    self.frame_timer = self.frame_timer + dt
    if self.frame_timer >= self.frame_time then
        self.show_stateA = not self.show_stateA
        self.frame_timer = self.frame_timer - self.frame_time
    end
    if self.dice then
        if self.show_stateA then
            self.dice.state = self.stateA
        else
            self.dice.state = self.stateB
        end
    end
    if self.timer >= self.duration then
        -- Завершили анимацию — бросаем кубик и вызываем callback
        local value = self.dice and self.dice.roll and self.dice:roll() or nil
        self.animating = false
        if self.callback then self.callback(value) end
    end
end



function DiceAnimator:is_animating()
    return self.animating
end

return DiceAnimator
