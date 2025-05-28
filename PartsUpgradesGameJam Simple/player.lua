-- player.lua
local Entity = require "entity"
local Player = setmetatable({}, { __index = Entity })
Player.__index = Player

function Player:new(x, y)
    local instance = Entity.new(self, x, y, playerNumber)
    instance.type               = "player"
    instance.playerNumber       = playerNumber
    instance.color              = {0.2, 0.6, 1}
    instance.speed              = 120
    instance.upgrade            = 1
    instance.partsCollected     = 0
    instance.partsForNextUpgrade= 3
    return instance
end

function Player:update(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("up")    then dy = -1 end
    if love.keyboard.isDown("down")  then dy =  1 end
    if love.keyboard.isDown("left")  then dx = -1 end
    if love.keyboard.isDown("right") then dx =  1 end
    if dx~=0 or dy~=0 then
        local len = math.sqrt(dx*dx + dy*dy)
        self:move(dx/len * self.speed * dt, dy/len * self.speed * dt)
    end
end

function Player:collectPart()
    self.partsCollected = self.partsCollected + 1
    if self.partsCollected >= self.partsForNextUpgrade and self.upgrade < 3 then
        self.upgrade = self.upgrade + 1
        self.speed   = self.speed + 50
        self.partsCollected = 0
        self.partsForNextUpgrade = 5
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    if self.upgrade == 1 then
        love.graphics.circle("fill", self.x, self.y, 10)
    elseif self.upgrade == 2 then
        love.graphics.rectangle("fill", self.x - 10, self.y - 5, 20, 10)
    elseif self.upgrade == 3 then
        love.graphics.rectangle("fill", self.x - 15, self.y - 8, 30, 16)
    end
end

return Player
