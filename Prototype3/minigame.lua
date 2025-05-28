local Entity = require "entity"
local Minigame = setmetatable({}, {__index = Entity})
Minigame.__index = Minigame

function Minigame:new(playerId)
    local instance = Entity.new(self, 0, 0)
    instance.type      = "minigame"
    instance.playerId  = playerId
    instance.duration  = 5         -- seconds to auto-complete
    instance.timer     = 0
    instance.completed = false
    return instance
end

function Minigame:update(dt)
   if self.completed then
        love.graphics.printf("Completed!", 0, viewH/2 + 10, viewW, "center")
    end
end

function Minigame:draw(viewW, viewH)
    -- Dark background so text shows
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, viewW, viewH)
    -- Optional red border for debugging
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("line", 0, 0, viewW, viewH)

    -- Draw instructions
    love.graphics.setColor(1,1,1)
    love.graphics.printf(
        string.format("Player %d Minigame", self.playerId),
        0, viewH/2 - 10, viewW, "center"
    )
    love.graphics.printf(
        "Press SPACE to complete",
        0, viewH/2 + 10, viewW, "center"
    )
    _G.viewW = viewW 
    _G.viewH = viewH 
end

function Minigame:handleInput(key)
    if key == "space" then
        self.completed = true
    end
end

return Minigame
