-- map.lua
local Entity = require "entity"
local Map = setmetatable({}, {__index = Entity})
Map.__index = Map

function Map:new(width, height, tileSize, players)
    local instance = Entity.new(self, 0, 0)
    instance.type      = "map"
    instance.width     = width
    instance.height    = height
    instance.tileSize  = tileSize
    instance.players   = players or {}
    return instance
end

function Map:update(dt)
    for _, p in ipairs(self.players) do p:update(dt) end
end

function Map:draw(viewW, viewH)
    -- background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, viewW, viewH)
    -- players
    for _, p in ipairs(self.players) do p:draw() end
end

function Map:handleInput(key) end

return Map
