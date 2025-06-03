-- map.lua
local Entity = require "entity"
local Map = setmetatable({}, {__index = Entity})
local buildingSprites = {
    ["City Hall"]    = love.graphics.newImage("assets/cityHall.png"),
    ["Hospital"]     = love.graphics.newImage("assets/hospital.png"),
    ["School"]       = love.graphics.newImage("assets/school.png"),
    ["Airport"]      = love.graphics.newImage("assets/airport.png"),
    ["Fire Station"] = love.graphics.newImage("assets/fireStation.png"),
    ["Library"]      = love.graphics.newImage("assets/libraryUpdate.png"),
    ["Stadium"]      = love.graphics.newImage("assets/stadium.png"),
    ["Mall"]         = love.graphics.newImage("assets/mall.png")
}
local lampPost = love.graphics.newImage("assets/lampost.png")



local grassTiles = {
    love.graphics.newImage("assets/grassTile1.png"),
    love.graphics.newImage("assets/grassTile2.png"),
    love.graphics.newImage("assets/grassTile3.png"),
    love.graphics.newImage("assets/grassTile4.png"),
    love.graphics.newImage("assets/grassTile5.png"),
}


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

    -- Fixed random seed for consistent layout of grass
    math.randomseed(412102209)

    -- Create grass tile map
    instance.tileGrid = {}
    local rows = math.ceil(height / tileSize) + 100
    local cols = math.ceil(width / tileSize) + 100

    for y = 1, rows do
        instance.tileGrid[y] = {}
        for x = 1, cols do
            -- Bias towards tile 3 (normal grass))
            local roll = math.random()
            local tileIndex
            if roll < 0.6 then
                tileIndex = 3
            else
                tileIndex = math.random(1, 5)
            end
            instance.tileGrid[y][x] = tileIndex
        end
    end

    instance.lampPosts = {
        {x = 50, y = 100},
        {x = 380, y = 220},
        {x = 690, y = 100},
        {x = 750, y = 300},
        {x = 420, y = 320},
        {x = 100, y = 300},
        {x = 340, y = 429},
        {x = 1070, y = 330},
        {x = 1240, y = 124},
        {x = 1000, y = 570},
        {x = 1120, y = 100},
        {x = 1413, y = 320}
    }
    

    instance.zonesCompleted = 0

    instance.buildings = {
        {name = "Fire Station", x = 200,   y = 100, w = 100, h = 80},
        {name = "Hospital",     x = 450,  y = 80, w = 100, h = 80},
        {name = "School",       x = 700,  y = 80, w = 100, h = 80},
        {name = "Airport",      x = 950,  y = 100, w = 100, h = 80},
    
        {name = "City Hall",    x = 650,  y = 220, w = 100, h = 80},
    
        {name = "Stadium",      x = 250,  y = 300, w = 100, h = 80},
        {name = "Mall",         x = 650,  y = 390, w = 100, h = 80},
        {name = "Library",      x = 1050,  y = 300, w = 100, h = 80},
    }
    

    instance.zones = {
        DestructionZone:new("Fire Station", 200,   100, 100, 80),
        DestructionZone:new("Hospital",     450,  80, 100, 80),
        DestructionZone:new("School",       700,  80, 100, 80),
        DestructionZone:new("Airport",      950,  100, 100, 80),
        
        DestructionZone:new("City Hall",    650,  220, 100, 80, true),
    
        DestructionZone:new("Stadium",      250,  300, 100, 80),
        DestructionZone:new("Mall",         650,  390, 100, 80),
        DestructionZone:new("Library",      1050,  300, 100, 80),
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
    -- Draw base grass tiles
    for y, row in ipairs(self.tileGrid) do
        for x, tileIndex in ipairs(row) do
            local img = grassTiles[tileIndex]
            local scaleX = self.tileSize / img:getWidth()
            local scaleY = self.tileSize / img:getHeight()
            love.graphics.draw(
                img,
                (x - 1) * self.tileSize,
                (y - 1) * self.tileSize,
                0,         -- rotation
                scaleX,
                scaleY
            )
        end
    end



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
        local sprite = buildingSprites[b.name]
    
        if sprite then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprite, b.x, b.y, 0, b.w / sprite:getWidth(), b.h / sprite:getHeight())
        else
            love.graphics.setColor(0.3, 0.3, 0.5)
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h)
        end
    
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h)
    end
    
    
    

    -- Draw zones
    for _, zone in ipairs(self.zones) do
        zone:draw()
    end

    -- Draw lamp posts
    for _, lamp in ipairs(self.lampPosts) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(
            lampPost,
            lamp.x,
            lamp.y,
            0,
            .1, .1 -- scale down since i accidentally made the sprite the wrong dimensions oops
        )
    end
    


    -- players
    for _, p in ipairs(self.players) do
        p:draw()
    end

    love.graphics.setFont(DefaultFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Zones Fixed: " .. tostring(self.zonesCompleted), 10, 10)

end

function Map:handleInput(key)
    -- Not used for now
end

return Map
