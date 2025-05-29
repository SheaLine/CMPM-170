-- guess_minigame.lua
local Minigame = require "minigame"
local Guess     = setmetatable({}, {__index = Minigame})
Guess.__index   = Guess

function Guess:new(playerId)
    local instance = Minigame.new(self, playerId)
    instance.type      = "guess"           
    instance.current   = 0                 
    instance.max       = 20                 
    instance.target    = math.random(0, instance.max)  
    instance.feedback  = ""                
    instance.playerId  = playerId          
    return instance
end

function Guess:draw(viewW, viewH)
    -- 1) draw background + base UI (Completed!/timer)
    Minigame.draw(self, viewW, viewH)

    if self.completed then return end

    -- 2) Instructions
    love.graphics.setColor(0,1,0)
    love.graphics.setFont(SmallFont)
    local controlsText = self.playerId == 1
        and "Press W/S to choose a number, D to submit."
        or "Press UP/DOWN to choose a number, RIGHT to submit."
    local instructions = string.format(
        "Player %d, guess a number between 0 and %d.\n%s",
        self.playerId, self.max, controlsText
    )
    love.graphics.printf(
        instructions,
        0,             
        8,            
        viewW,         
        "center"
    )

    -- 3) Big current guess
    love.graphics.setColor(1,0,0)
    local txt = tostring(self.current)
    love.graphics.setFont(ReallyBigFont)
    local bw = ReallyBigFont:getWidth(txt)
    local bh = ReallyBigFont:getHeight()
    love.graphics.printf(
        txt,
        0,                  
        (viewH - bh) / 2, 
        viewW,              
        "center"
    )

    -- Feedback
    love.graphics.setColor(1,1,0)
    if self.feedback ~= "" then
        love.graphics.setFont(DefaultFont)
        local fw = DefaultFont:getWidth(self.feedback)
        local fh = DefaultFont:getHeight()
        love.graphics.printf(
            self.feedback,
            0,
            (viewH + bh) / 2 + 8,
            viewW,
            "center"
        )
    end
    love.graphics.setColor(1,1,1)
end

function Guess:handleInput(key)
    Minigame.handleInput(self, key)
    if self.completed then return end

    -- map controls per player
    if self.playerId == 1 then
        if key == "w" then
            self.current = math.min(self.current + 1, self.max)
        elseif key == "s" then
            self.current = math.max(self.current - 1, 0)
        elseif key == "d" then
            self:submit()
        end

    else  -- player 2
        if key == "up" then
            self.current = math.min(self.current + 1, self.max)
        elseif key == "down" then
            self.current = math.max(self.current - 1, 0)
        elseif key == "right" then
            self:submit()
        end
    end
end

function Guess:submit()
    if self.current == self.target then
        self.completed = true
    elseif self.current > self.target then
        self.feedback = "Too high!"
    elseif self.current < self.target then
        self.feedback = "Too low!"
    end
end

return Guess
