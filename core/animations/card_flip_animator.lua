local CardFlipAnimator = {}
CardFlipAnimator.__index = CardFlipAnimator

function CardFlipAnimator.new(card, duration)
    local self = setmetatable({}, CardFlipAnimator)
    self.card = card
    self.duration = duration or 0.35
    self.timer = 0
    self.flipping = false
    self.progress = 0
    self.callback = nil
    self._swapped = false
    return self
end

function CardFlipAnimator:flip(callback)
    if self.flipping then return end
    self.flipping = true
    self.timer = 0
    self.progress = 0
    self.callback = callback
    self._swapped = false
end

function CardFlipAnimator:update(dt)
    if not self.flipping then return end
    self.timer = self.timer + dt
    self.progress = math.min(self.timer / self.duration, 1)
    if self.progress >= 0.5 and not self._swapped then
        self.card:flip()
        self._swapped = true
    end
    if self.progress >= 1 then
        self.flipping = false
        self.progress = 1
        -- Исправление здесь: вызываем callback только если это функция!
        if type(self.callback) == "function" then
            self.callback()
        end
        self.callback = nil
    end
end

function CardFlipAnimator:get_scale_x()
    if self.flipping then
        local t = self.progress
        if t < 0.5 then
            return 1 - t * 2
        else
            return (t - 0.5) * 2
        end
    else
        return 1
    end
end

function CardFlipAnimator:is_flipping()
    return self.flipping
end

return CardFlipAnimator
