local DeckShuffleAnimator = {}
DeckShuffleAnimator.__index = DeckShuffleAnimator

function DeckShuffleAnimator.new(deck, duration)
    local self = setmetatable({}, DeckShuffleAnimator)
    self.deck = deck
    self.duration = duration or 1.0
    self.timer = 0
    self.active = false
    self.progress = 0
    self.callback = nil
    return self
end

function DeckShuffleAnimator:start(callback)
    self.active = true
    self.timer = 0
    self.progress = 0
    self.callback = callback
    if self.deck then self.deck.is_animating = true end
end

function DeckShuffleAnimator:update(dt)
    if not self.active then return end
    self.timer = self.timer + dt
    self.progress = math.min(self.timer / self.duration, 1)
    -- Можно проигрывать shuffle-эффект: на progress менять случайно порядок (визуально), но не сам массив!
    if self.progress >= 1 then
        self.active = false
        if self.deck then self.deck.is_animating = false; self.deck:shuffle() end
        if self.callback then self.callback() end
    end
end

function DeckShuffleAnimator:is_active()
    return self.active
end

return DeckShuffleAnimator
