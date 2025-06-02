-- map.lua
local Entity = require "entity"
local Map = setmetatable({}, {__index = Entity})
local cityHall = love.graphics.newImage("assets/cityHall.png")
local hospital = love.graphics.newImage("assets/hospital.png")
local school   = love.graphics.newImage("assets/school.png")

Map.__index = Map


local DestructionZone = {}
DestructionZone.__index = DestructionZone

function DestructionZone:new(name, x, y, w, h, active)
    return setmetatable({
        name = name,
        x = x, y = y,
        w = w, h = h,
        active = active or false,
        completed = false
    }, DestructionZone)
end

function DestructionZone:draw()
    local color = self.active and {1, 0, 0} or {0.4, 0.4, 0.4}
    love.graphics.setColor(color)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1,1,1)
end

function DestructionZone:contains(px, py)
    return self.active and not self.completed and
           px >= self.x and px <= self.x + self.w and
           py >= self.y and py <= self.y + self.h
end


function Map:new(width, height, tileSize, players)
    local instance = Entity.new(self, 0, 0)
    instance.type      = "map"
    instance.width     = width
    instance.height    = height
    instance.tileSize  = tileSize
    instance.players   = players or {}
    instance.zoneSpawnTimer = 0
    instance.zoneSpawnInterval = 10  -- seconds between new zone activations
    instance.zonesSpawning = false   -- starts false, toggles true after tutorial


    instance.zonesCompleted = 0

    instance.buildings = {
        {name = "Fire Station", x = 50,   y = 150, w = 100, h = 80},
        {name = "Hospital",     x = 200,  y = 100, w = 100, h = 80},
        {name = "School",       x = 450,  y = 100, w = 100, h = 80},
        {name = "Airport",      x = 800,  y = 100, w = 100, h = 80},
    
        {name = "City Hall",    x = 400,  y = 220, w = 100, h = 80},
    
        {name = "Stadium",      x = 100,  y = 300, w = 100, h = 80},
        {name = "Mall",         x = 400,  y = 320, w = 100, h = 80},
        {name = "Library",      x = 700,  y = 300, w = 100, h = 80},
    }
    

    instance.zones = {
        DestructionZone:new("Fire Station", 50,   150, 100, 80),
        DestructionZone:new("Hospital",     200,  100, 100, 80),
        DestructionZone:new("School",       450,  100, 100, 80),
        DestructionZone:new("Airport",      800,  100, 100, 80),
        
        DestructionZone:new("City Hall",    400,  220, 100, 80, true),
    
        DestructionZone:new("Stadium",      100,  300, 100, 80),
        DestructionZone:new("Mall",         400,  320, 100, 80),
        DestructionZone:new("Library",      700,  300, 100, 80),
    }
    

    instance:refreshZones()  -- Activate 3 random ones

    return instance
end



function Map:update(dt)
    for _, p in ipairs(self.players) do
        p:update(dt)
    end
    -- Timer-based zone spawning
    if self.zonesSpawning then
        self.zoneSpawnTimer = self.zoneSpawnTimer + dt
        if self.zoneSpawnTimer >= self.zoneSpawnInterval then
            self.zoneSpawnTimer = 0
            for _, z in ipairs(self.zones) do
                if not z.active and not z.completed then
                    z.active = true
                    break
                end
            end
        end
    end

end

function Map:refreshZones()
    for _, z in ipairs(self.zones) do
        if not z.active and not z.completed then
            z.active = true
            break -- activate only one
        end
    end
end



function Map:draw(viewW, viewH)
    -- background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, viewW, viewH)

    -- Draw paths manually for the layout
    local function drawPathBetween(a, b)
        local ax, ay = a.x + a.w / 2, a.y + a.h / 2
        local bx, by = b.x + b.w / 2, b.y + b.h / 2
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.setLineWidth(8)
        love.graphics.line(ax, ay, bx, by)
    end

    local nameToBuilding = {}
    for _, b in ipairs(self.buildings) do
        nameToBuilding[b.name] = b
    end

    -- Path connections 
    local pathPairs = {
        {"City Hall", "Fire Station"},
        {"City Hall", "Hospital"},
        {"City Hall", "School"},
        {"City Hall", "Airport"},
        {"City Hall", "Stadium"},
        {"City Hall", "Mall"},
        {"City Hall", "Library"},
    }


    for _, pair in ipairs(pathPairs) do
        local a = nameToBuilding[pair[1]]
        local b = nameToBuilding[pair[2]]
        if a and b then drawPathBetween(a, b) end
    end

    love.graphics.setLineWidth(1)



    -- draw buildings
    for _, b in ipairs(self.buildings) do
        local sprite = nil
    
        if b.name == "City Hall" then
            sprite = cityHall
        elseif b.name == "Hospital" then
            sprite = hospital
        elseif b.name == "School" then
            sprite = school
        end
    
        if sprite then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprite, b.x, b.y, 0, b.w / sprite:getWidth(), b.h / sprite:getHeight())
        else
            love.graphics.setColor(0.3, 0.3, 0.5)
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
        end
    
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h)
        love.graphics.printf(b.name, b.x, b.y + b.h/2 - 6, b.w, "center")
    end
    
    

    -- Draw zones
    for _, zone in ipairs(self.zones) do
        zone:draw()
    end


    -- players
    for _, p in ipairs(self.players) do
        p:draw()
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Zones Fixed: " .. tostring(self.zonesCompleted), 10, 10)

end

function Map:handleInput(key)
    -- Not used for now
end

return Map
