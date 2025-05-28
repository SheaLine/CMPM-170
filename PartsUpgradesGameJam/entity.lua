-- entity.lua
-- Base Entity class for all game objects

local Entity = {}
Entity.__index = Entity

-- Constructor
function Entity:new(x, y)
    local instance = {}
    setmetatable(instance, self)
    
    -- Common properties for all entities
    instance.x      = x or 0
    instance.y      = y or 0
    instance.width  = 32
    instance.height = 32
    instance.speed  = 100
    instance.color  = {1, 1, 1}
    instance.type   = "entity"
    instance.active = true
    instance.id     = tostring(math.random(1000000))
    
    return instance
end

-- Common methods for all entities
function Entity:update(dt)
    -- Base update logic (override in subclasses)
end

function Entity:draw()
    -- Draw bounding box
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
      "fill",
      self.x - self.width/2, self.y - self.height/2,
      self.width, self.height
    )
    
    -- Label with type
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.type,
      self.x - self.width/2 + 5,
      self.y - 5
    )
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Entity:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Entity:checkCollision(other)
    return  self.x + self.width/2 > other.x - other.width/2 and
            self.x - self.width/2 < other.x + other.width/2 and
            self.y + self.height/2 > other.y - other.height/2 and
            self.y - self.height/2 < other.y + other.height/2
end

function Entity:onCollision(other)
    -- Base collision behavior (override in subclasses)
end

function Entity:getInfo()
    return {
        type     = self.type,
        position = { x = self.x, y = self.y },
        size     = { width = self.width, height = self.height },
        id       = self.id
    }
end

return Entity
