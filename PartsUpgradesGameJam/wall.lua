-- wall.lua
-- Wall entity derived from base Entity

local Entity = require("entity")

local Wall = {}
Wall.__index = Wall
setmetatable(Wall, {__index = Entity})

function Wall:new(x, y, width, height, wallType, followEntity, xOffset)
    local instance = Entity:new(x, y)
    setmetatable(instance, self)
    
    -- Wall-specific properties
    instance.type       = "wall"
    instance.width      = width or 100
    instance.height     = height or 20
    instance.health     = 100
    instance.maxHealth  = 100
    instance.wallType   = wallType or "standard"
    
    -- Set color based on wall type
    if instance.wallType == "damaging" then
        instance.color = {133/255, 28/255, 49/255}  -- Red for damaging walls
    elseif instance.wallType == "healing" then
        instance.color = {167/255, 247/255, 126/255}  -- Green for healing walls
    elseif instance.wallType == "standard" then
        instance.color = {255/255, 105/255, 180/255}  -- Pink for standard walls
    else
    end

    instance.follow = followEntity
    instance.xOffset =  xOffset or 0
    
    return instance
end

function Wall:draw()
    -- Set color and draw rectangle
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, 
                            self.width, self.height)
    -- Draw entity type
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.type .. " " .. self.wallType, self.x - self.width/2 + 5, self.y - 5)
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Wall:update(dt)
    -- keep the wall aligned to its follow target
    if self.follow then
        self.y = self.follow.y
    end
end

function Wall:onCollision(other)
    -- skip walls
    if other.type == "wall" then return end

    -- calculate delta between centers
    local dx = other.x - self.x
    local dy = other.y - self.y

    -- half-sizes
    local halfW = (self.width  + other.width)  / 2
    local halfH = (self.height + other.height) / 2

    -- how much they’re overlapping on each axis
    local overlapX = halfW - math.abs(dx)
    local overlapY = halfH - math.abs(dy)

    if overlapX < overlapY then
        -- resolve on X axis only
        if dx > 0 then
            other.x = other.x + overlapX
        else
            other.x = other.x - overlapX
        end
    else
        -- resolve on Y axis only
        if dy > 0 then
            other.y = other.y + overlapY
        else
            other.y = other.y - overlapY
        end
    end

    if self.wallType == "damaging" then
        -- apply damage to the other entity
        if (other.type == "player" or other.type == "enemy") and not (other.health == 0) then
            other.health = other.health - 1
        end
    end

    if self.wallType == "healing" then
        -- apply damage to the other entity
        if (other.type == "player" or other.type == "enemy")  and not (other.health == other.maxHealth) then
            other.health = other.health + 1
        end
    end
end

return Wall