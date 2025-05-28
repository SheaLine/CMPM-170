-- main.lua

-- pull in your classes
local Player = require "player"
local Part   = require "part"
local Road   = require "road"

-- a flat list of all active entities
local entities = {}

-- convenience for spawning
local function addEntity(e)
    table.insert(entities, e)
end

-- part‑spawn timer
local partTimer, partSpawnInterval

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    math.randomseed(os.time())

    -- 1) Create the player
    local player = Player:new(400, 300)
    -- store player in a global so HUD and Road entity can see it
    _G.player = player

    -- 2) Create the road, passing in the player so it can follow vertically
    --    laneX = 400 (center), laneWidth = 300
    local road = Road:new(400, 300, player)
    addEntity(road)
    addEntity(player) -- add player to our entity list after road so it draws on top

    -- 3) Initialize part spawner
    partTimer = 0
    partSpawnInterval = 2

    
end

function love.update(dt)
    -- spawn a new Part around the player every few seconds
    partTimer = partTimer + dt
    if partTimer >= partSpawnInterval then
        partTimer = partTimer - partSpawnInterval
        local px = player.x + math.random(-200, 200)
        local py = player.y + math.random(-200, 200)
        addEntity(Part:new(px, py, player))
    end

    -- update & cull
    for i = #entities, 1, -1 do
        local e = entities[i]
        if e.active then
            e:update(dt)
        else
            table.remove(entities, i)
        end
    end
end

function love.draw()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

    -- camera follows player
    love.graphics.push()
      love.graphics.translate(sw/2 - player.x, sh/2 - player.y)
      for _, e in ipairs(entities) do
        e:draw()
      end
    love.graphics.pop()

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Use arrow keys to move", 10, 10)

    local labels = { "Person", "Bike", "Car" }
    love.graphics.print("Upgrade: " .. labels[player.upgrade], 10, 30)
    love.graphics.print(
      "Parts: " .. player.partsCollected .. "/" .. player.partsForNextUpgrade,
      10, 50
    )
end
