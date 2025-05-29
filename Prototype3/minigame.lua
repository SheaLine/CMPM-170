local Entity = require "entity"
local Countdown = require "countdown"
local Minigame = setmetatable({}, {__index = Entity})
Minigame.__index = Minigame

function Minigame:new(playerId)
    local instance = Entity.new(self, 0, 0)
    instance.type      = "minigame"
    instance.playerId  = playerId
    instance.completed = false
    instance.debugMode = true  -- If this is true, pressing space will complete the minigame for debug purposes
    instance.exitScheduled = false
    instance.timerStarted = false
    instance.idleTimer = Countdown:new(5, "wait(%d)", function()
        instance.idleTimer:cancel()
        instance.idleTimer = nil
    end)
    return instance
end

function Minigame:update(dt)

end

function Minigame:draw(viewW, viewH)
    -- Dark background so text shows
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, viewW, viewH)

    -- Draw instructions
    love.graphics.setColor(1,1,1)
    if self.completed then
        love.graphics.setFont(DefaultFont)
        love.graphics.printf("Completed!", 0, viewH/2, viewW, "center")
        if not self.timerStarted then
            self.idleTimer:start()
            self.timerStarted = true
        end
        self.idleTimer:draw(viewW/2, viewH - 70)
    end

    _G.viewW = viewW 
    _G.viewH = viewH 
end

function Minigame:handleInput(key)
    if key == "space" and self.debugMode then
        self.completed = true
    end
end

return Minigame
