-- player.lua
local Entity = require "entity"
local Player = setmetatable({}, { __index = Entity })
Player.__index = Player

function Player:new(x, y, playerNumber)
    local instance = Entity.new(self, x, y)
    instance.type                   = "player"
    instance.playerNumber           = playerNumber
    instance.color                  ={0.2, 0.6, 1}


    -- physics
    instance.velX                   = 0
    instance.velY                   = 0

    -- base stats
    instance.baseSpeed              = 120 --360
    instance.baseAcceleration       = 200
    instance.baseFriction           = 800

    -- stats
    instance.speed                  = instance.baseSpeed
    instance.acceleration           = instance.baseAcceleration
    instance.diagonalBoost          = 1
    instance.friction               = instance.baseFriction

    -- upgrade levels
    instance.engineLevel            = 0
    instance.turboLevel             = 0
    instance.tireLevel              = 0

    -- DELETE THIS LATER
    instance.upgrade                = 1
    instance.partsCollected         = 0
    instance.partsForNextUpgrade    = 3
    return instance
end

function Player:update(dt)
    local ix, iy = 0, 0
    if self.playerNumber == 1 then
        if love.keyboard.isDown("w") then iy = iy - 1 end
        if love.keyboard.isDown("s") then iy = iy + 1 end
        if love.keyboard.isDown("a") then ix = ix - 1 end
        if love.keyboard.isDown("d") then ix = ix + 1 end
    else
        if love.keyboard.isDown("up")   then iy = iy - 1 end
        if love.keyboard.isDown("down") then iy = iy + 1 end
        if love.keyboard.isDown("left") then ix = ix - 1 end
        if love.keyboard.isDown("right")then ix = ix + 1 end
    end

    -- 2) Apply acceleration (with diagonal boost)
    if ix~=0 or iy~=0 then
        local acc = self.acceleration
        if ix~=0 and iy~=0 then
            acc = acc * self.diagonalBoost
        end
        -- normalize direction
        local len = math.sqrt(ix*ix + iy*iy)
        ix, iy = ix/len, iy/len

        -- increase velocity
        self.velX = self.velX + ix * acc * dt
        self.velY = self.velY + iy * acc * dt
    end

    -- 3) Apply friction on axes with no input
    if ix == 0 then
        if self.velX > 0 then
            self.velX = math.max(self.velX - self.friction*dt, 0)
        elseif self.velX < 0 then
            self.velX = math.min(self.velX + self.friction*dt, 0)
        end
    end
    if iy == 0 then
        if self.velY > 0 then
            self.velY = math.max(self.velY - self.friction*dt, 0)
        elseif self.velY < 0 then
            self.velY = math.min(self.velY + self.friction*dt, 0)
        end
    end

    -- 4) Clamp combined speed to maxSpeed (self.speed)
    local vmag = math.sqrt(self.velX^2 + self.velY^2)
    if vmag > self.speed then
        local scale = self.speed / vmag
        self.velX = self.velX * scale
        self.velY = self.velY * scale
    end

    -- 5) Move the player
    self.x = self.x + self.velX * dt
    self.y = self.y + self.velY * dt

end

function Player:collectPart(part)
    if part.type == "engine" then
        self.engineLevel = self.engineLevel + 1
        self.speed = self.baseSpeed * (1 + 0.20 * self.engineLevel)
        print(string.format(
            "P%d: Engine Level %d → maxSpeed = %.1f",
            self.playerNumber,
            self.engineLevel,
            self.speed
        ))
        

    elseif part.type == "turbo" then
        if self.tireLevel < 5 then
            self.turboLevel = self.turboLevel + 1
            self.acceleration = self.baseAcceleration * (1 + 0.30 * self.turboLevel)
            self.friction = self.baseFriction * (1 - 0.20 * self.tireLevel)
            print(string.format(
                "P%d: Turbo Charger Level %d → Acceleration = %.1f",
                self.playerNumber,
                self.turboLevel,
                self.acceleration
            ))
        end

    elseif part.type == "tire" then
        self.tireLevel = self.tireLevel + 1
        self.diagonalBoost = 1 + 5 * self.tireLevel
        print(string.format(
            "P%d: Tire Level %d → Friction = %.1f → Diagonal Boost = %.1f",
            self.playerNumber,
            self.tireLevel,
            self.friction,
            self.diagonalBoost
        ))
    end
end

function Player:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, 10)
end

return Player
