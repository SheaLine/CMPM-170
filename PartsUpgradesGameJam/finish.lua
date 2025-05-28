-- finish.lua
local Entity = require "entity"
local Finish = setmetatable({}, { __index = Entity })
Finish.__index = Finish

function Finish:new(x, y, laneWidth, player)
    local instance = Entity.new(self, x, y)
    instance.type      = "finish"
    instance.color     = {0.2, 0.6, 1}
    instance.width     = laneWidth          
    instance.height    = 50                  
    instance.player    = player
    instance.onFinish  = nil                

    return instance
end

function Finish:update(dt)
    if not self.active then return end
    if self:checkCollision(self.player) then
        self.active = false
        if self.onFinish then self.onFinish(self.player) end
    end
end

function Finish:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
      "fill",
      self.x - self.width/2,
      self.y - self.height/2,
      self.width,
      self.height
    )
    local biggerFont = love.graphics.newFont(20)
    love.graphics.setFont(biggerFont)
    local font = love.graphics.getFont()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FINISH LINE", self.x - font:getWidth("FINISH LINE")/2, self.y - font:getHeight()/2)
    -- reset color
    love.graphics.setColor(1,1,1)
end

return Finish