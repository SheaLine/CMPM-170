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
    instance.facingRight = true

    -- Load player sprite depending on player ID
    if id == 1 then
        instance.sprite = love.graphics.newImage("assets/player1_defaultLeft.png")
    else
        instance.sprite = love.graphics.newImage("assets/player2_defaultRight.png")
    end

    return instance
end

function Player:update(dt)
    if not self.inMinigame then
        local speed = self.speed * dt
        if love.keyboard.isDown(self.controls.left) then
            self:move(-speed, 0)
            self.facingRight = false
        elseif love.keyboard.isDown(self.controls.right) then
            self:move(speed, 0)
            self.facingRight = true
        end

        if love.keyboard.isDown(self.controls.up) then
            self:move(0, -speed)
        elseif love.keyboard.isDown(self.controls.down) then
            self:move(0, speed)
        end
    end
end


function Player:draw()
    if self.sprite then
        local facingRight = self.facingRight
        if self.playerId == 1 then
            -- Player 1's sprite is drawn facing left, so invert the flip logic
            facingRight = not facingRight
        end
        
        local scaleX = facingRight and 1 or -1
        local offsetX = facingRight and 0 or self.sprite:getWidth()
        

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            self.sprite,
            self.x - self.width / 2 + offsetX,
            self.y - self.height / 2,
            0,          -- rotation
            scaleX,     -- scaleX (flip if -1)
            1           -- scaleY
        )
    else
        -- fallback rectangle if sprite is missing
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
    end
end


function Player:handleInput(key) end

return Player