-- player.lua
local Entity = require "entity"
local Player = setmetatable({}, {__index = Entity})
Player.__index = Player

function Player:new(id, x, y, controls, color)
    local instance = Entity.new(self, x, y)
    instance.type       = "player"
    instance.playerId   = id
    instance.controls   = controls
    instance.color      = color
    instance.width      = 24
    instance.height     = 24
    instance.inMinigame = false
    return instance
end

function Player:update(dt)
    if not self.inMinigame then
        local speed = self.speed * dt
        if love.keyboard.isDown(self.controls.up)    then self:move(0, -speed) end
        if love.keyboard.isDown(self.controls.down)  then self:move(0,  speed) end
        if love.keyboard.isDown(self.controls.left)  then self:move(-speed, 0) end
        if love.keyboard.isDown(self.controls.right) then self:move( speed, 0) end
    end
end

function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(1,1,1)
end

function Player:handleInput(key) end

return Player