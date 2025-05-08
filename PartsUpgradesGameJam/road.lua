-- road.lua
local Entity = require "entity"
local Road   = setmetatable({}, { __index = Entity })
Road.__index = Road

function Road:new(laneX, laneWidth, player)
    local instance = Entity.new(self, laneX, player.y)
    instance.type      = "road"
    instance.color     = {0.3,0.3,0.3}
    instance.laneWidth = laneWidth
    instance.player    = player
    instance.laneX     = laneX
    -- roads span the full screen, so we can ignore width/height
    return instance
end

function Road:update(dt)
    -- reposition vertically with player
    self.y = self.player.y
end

function Road:draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    -- main asphalt
    love.graphics.setColor(self.color)
    love.graphics.rectangle(
      "fill",
      self.laneX - self.laneWidth/2,
      self.player.y - sh/2,
      self.laneWidth, sh
    )
    -- center dashes
    love.graphics.setColor(1,1,1)
    local spacing, dashH, dashW = 40, 20, 6
    local top    = self.player.y - sh/2
    local bottom = self.player.y + sh/2
    local startY = math.floor(top/spacing)*spacing
    for y = startY, bottom, spacing do
        love.graphics.rectangle(
          "fill",
          self.laneX - dashW/2, y,
          dashW, dashH
        )
    end
    love.graphics.setColor(1,1,1)
end

return Road
