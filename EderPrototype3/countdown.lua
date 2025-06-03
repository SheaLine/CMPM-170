-- countdown.lua
-- A simple countdown timer class using hump.timer

local Timer = require "lib.timer"

local Countdown = {}
Countdown.__index = Countdown

--- Create a new Countdown
function Countdown:new(duration, text, onFinish)
    local instance = setmetatable({}, self)
    instance.duration     = duration or 0
    instance.timeLeft     = instance.duration
    instance.onFinish     = onFinish
    instance.handle       = nil
    instance.running      = false
    instance.text         = text or "Time Left: %d"
    return instance
end

--- Start or restart the countdown
function Countdown:start()
    -- cancel existing schedule if present
    if self.handle then
        Timer.cancel(self.handle)
        self.handle = nil
    end
    self.timeLeft  = self.duration
    self.running   = true

    -- schedule a tick every second
    self.handle = Timer.every(1, function()
        self.timeLeft = self.timeLeft - 1
        if self.timeLeft <= 0 then
            -- stop further ticks
            Timer.cancel(self.handle)
            self.handle    = nil
            self.running   = false
            -- fire finish callback
            if self.onFinish then
                self.onFinish()
            end
        end
    end)
end

--- Cancel the countdown
function Countdown:cancel()
    if self.handle then
        Timer.cancel(self.handle)
        self.handle  = nil
        self.running = false
    end
end

-- set the countdown to a specific time
function Countdown:setTime(seconds)
    self.timeLeft = seconds
end

-- get the current time remaining
function Countdown:getTime()
    return self.timeLeft
end

--- Draw the current time remaining
function Countdown:draw(x, y)
    local font = love.graphics.getFont()
    local text = string.format(self.text, math.max(0, self.timeLeft))
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(DefaultFont)
    love.graphics.print(text, x - DefaultFont:getWidth(text)/2, y)
end

return Countdown
