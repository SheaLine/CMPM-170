-- part.lua
local Entity = require "entity"
local Part   = setmetatable({}, { __index = Entity })
Part.__index = Part

function Part:new(x, y, player, road)
    local instance = Entity.new(self, x, y)
    instance.type                   = "part"
    instance.color                  = {0, 1, 0}
    instance.radius                 = 4
    instance.width, instance.height = instance.radius*2, instance.radius*2
    instance.player                 = player
    instance.road                   = road
    instance.collectThreshold2      = (instance.radius + player.width/2)^2
    return instance
end

function Part:update(dt)
    -- Check for collision with the player
    if self:checkCollision(self.player) then
        self.active = false
        self.player:collectPart(self)
    end

    -- Despawn if off the vertical viewport
    local sh = love.graphics.getHeight()
    local halfH = sh/2 + 50
    if self.y < self.player.y - halfH
    or self.y > self.player.y + halfH then
        self.active = false
    end
end

function Part:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(0,0,0)

    -- Draw the first 2 letters of the part type in the center of the part
    love.graphics.setFont(love.graphics.newFont(16))
    local font = love.graphics.getFont()
    local text = string.upper(self.type:sub(1, 2))
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight(text)
    love.graphics.print(text, self.x - textWidth / 2 + self.width/2, self.y - textHeight / 2 + self.height/2)
    love.graphics.setColor(1,1,1)
end

return Part
