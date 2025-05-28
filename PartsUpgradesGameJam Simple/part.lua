-- part.lua
local Entity = require "entity"
local Part   = setmetatable({}, { __index = Entity })
Part.__index = Part

function Part:new(x, y, player)
    local instance = Entity.new(self, x, y)
    instance.type               = "part"
    instance.color              = {0, 1, 0}
    instance.radius             = 8
    -- for collision we’ll just shrink width/height
    instance.width, instance.height    = instance.radius*2, instance.radius*2
    instance.player             = player
    instance.collectThreshold2  = (instance.radius + player.width/2)^2
    return instance
end

function Part:update(dt)
    if self:checkCollision(self.player) then
        self.active = false
        self.player:collectPart()
    end
end

function Part:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1,1,1)
end

return Part
