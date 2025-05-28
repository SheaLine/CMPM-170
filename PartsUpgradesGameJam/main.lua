-- main.lua

local Player = require "player"
local Part   = require "part"
local Road   = require "road"
local Finish = require "finish"
local TirePart = require "tirePart"
local TurboPart = require "turboPart"
local EnginePart = require "enginePart"

-- a flat list of all active entities
local entities = {}

-- convenience for spawning
local function addEntity(e)
    table.insert(entities, e)
end

-- part‑spawn timer
local partTimer, partSpawnInterval

local screenWidth, screenHeight = love.graphics.getDimensions()
local centerX, centerY = screenWidth/2, screenHeight/2

function initGame()
    -- Global variables
    _G.finishY = -15000
    _G.GAME_OVER = false
    _G.winner = 0

    -- clear out previous entities & timers
    entities        = {}
    partTimer       = 0
    partSpawnInterval = 2

    local road1X = centerX - 300/2 - 50
    local road2X = centerX + 300/2 + 50
    -- 1) Create the players
    local player1 = Player:new(road1X, 300, 1)
    -- store player in a global so HUD and Road entity can see it
    _G.player1 = player1

    local player2 = Player:new(road2X, 300, 2)
    _G.player2 = player2
    
    -- 2) Create the roads passing in the player so it can follow vertically
    local road1 = Road:new(road1X, 300, player1)
    _G.road1 = road1
    local road2 = Road:new(road2X, 300, player2)
    _G.road2 = road2

    -- 3) Create the Finish Line
    local finish1 = Finish:new(road1X, player1.y + finishY, road1.laneWidth, player1)
    finish1.onFinish = function(pl)
        gameOver(1)
    end

    local finish2 = Finish:new(road2X, player2.y + finishY, road2.laneWidth, player2)
    finish2.onFinish = function(pl)
        gameOver(2)
    end

    -- 4) Add all entities to the list in order of drawing
    addEntity(road1)
    addEntity(road2)
    addEntity(finish1)
    addEntity(finish2)
    addEntity(player1)
    addEntity(player2)
end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    math.randomseed(os.time())
    initGame()    
end

local function drawCamera(cam, vx, vy, vw, vh)
    love.graphics.setScissor(vx, vy, vw, vh)
    love.graphics.push()
    -- center camera on the player within this viewport
    love.graphics.translate(vx + vw/2 - cam.x, vy + vh/2 - cam.y)

    -- only draw entities belonging to this player’s lane
    for _, e in ipairs(entities) do
        if     e == cam                   -- draw the road
            or e == cam.player            -- draw the player
            or e.player == cam.player     -- draw that player’s parts
        then
            e:draw()
        end
    end
    love.graphics.pop()

    -- show stats only when P1 hits Q or P2 hits /
    local showP1 = cam.player.playerNumber == 1 and love.keyboard.isDown("q")
    local showP2 = cam.player.playerNumber == 2 and love.keyboard.isDown("/")
    if showP1 or showP2 then
        local p    = cam.player
        local levels = {    
            {"Engine", p.engineLevel},
            {"Turbo",  p.turboLevel},
            {"Tires",  p.tireLevel},
        }
        local stats = {    
            {"Max Speed",  math.floor(p.speed)},
            {"Acceleration", math.floor(p.acceleration)},
            {"Friction", math.floor(p.friction)},
            {"Diagonal Boost", math.floor(p.diagonalBoost)},
        }

        local ox, oy = vx + 10, vy + 10
        local boxW   = 210
        local boxH   = #stats * 60 - 20
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.rectangle("fill", ox-5, oy-5, boxW, boxH)
        love.graphics.setColor(1,1,0)
        love.graphics.print("Player " .. p.playerNumber .. " Car Part Levels:\n", ox, oy)
        love.graphics.setColor(1,1,1)
        for i, row in ipairs(levels) do
        local name, val = row[1], row[2] or 0
        love.graphics.print(
            name .. ": " .. val,
            ox,
            oy + 30 + (i-1)*20
        )
        end
        love.graphics.setColor(1,1,0)
        love.graphics.print("Player " .. p.playerNumber .. " Car Stats:\n", ox, oy + 30 + (4-1)*20 + 10)
        love.graphics.setColor(1,1,1)
        for i, row in ipairs(stats) do
            local name, val = row[1], row[2] or 0
            love.graphics.print(
                name .. ": " .. val,
                ox,
                oy + 120 + (i-1)*20
            )
            end
    end
    love.graphics.setScissor()  -- turn off scissor
end

function love.update(dt)
    -- check for restart
    if GAME_OVER and love.keyboard.isDown("r") then
        initGame()
    end

    -- spawn a new Part around the player every few seconds
    partTimer = partTimer + dt
    if partTimer >= partSpawnInterval then
        partTimer = partTimer - partSpawnInterval
        for _, pl in ipairs({player1, player2}) do
            -- pick the correct road for this player
            local rd = (pl == player1) and road1 or road2

            -- X between the road edges (minus a little margin so parts don't clip)
            local minX = rd.laneX - rd.laneWidth/2 + 10
            local maxX = rd.laneX + rd.laneWidth/2 - 10
            local spawnX = love.math.random(minX, maxX)

            -- Y somewhere ahead of the player:
            -- world‐coords from top of view to just above the player
            local spawnY = love.math.random(
                math.max(pl.y - screenHeight/2, pl.y + finishY + 50),      -- no higher than finishY (or viewport top, whichever is lower)
                pl.y - 50                                                  -- 50px in front of the player
            )
            local partChoices = { EnginePart, TurboPart, TirePart } 
            local partType = partChoices[love.math.random(1, #partChoices)] -- pick a random part type to spawn
            addEntity( partType:new(spawnX, spawnY, pl, rd) )
        end
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
    local halfW = screenWidth/2

    -- camera follows player 1 on left half of screen
    drawCamera(road1, 0, 0, halfW, screenHeight)
    -- camera follows player 2 on right half of screen
    drawCamera(road2, halfW, 0, halfW, screenHeight)

    local HUD_FONT = love.graphics.newFont(18)
    love.graphics.setFont(HUD_FONT)

    local text = ""
    local font   = love.graphics.getFont()
    local fontH  = font:getHeight()

    -- Player 1 HUD
    love.graphics.setColor(1,0,0)

    text = "PLAYER 1"
    love.graphics.print(text, centerX - 300/2 - 50 - font:getWidth(text)/2, screenHeight - 90)

    text = "Use WASD keys to move"
    love.graphics.print(text, centerX - 300/2 - 50 - font:getWidth(text)/2, screenHeight - 70)

    love.graphics.setColor(1,1,0)
    local labels = { "Person", "Bike", "Car" }
    text = "Press Q To View Stats"
    love.graphics.print(text, centerX - 300/2 - 50 - font:getWidth(text)/2, screenHeight - 50)

    -- text = "Parts: " .. player1.partsCollected .. "/" .. player1.partsForNextUpgrade
    -- love.graphics.print(text, centerX - 300/2 - 50 - font:getWidth(text)/2, screenHeight - 30)

    -- Player 2 HUD
    love.graphics.setColor(1,0,0)
    text = "PLAYER 2"
    love.graphics.print(text, centerX + 300/2 + 50 - font:getWidth(text)/2, screenHeight - 90)

    text = "Use ARROW keys to move"
    love.graphics.print(text, centerX + 300/2 + 50 - font:getWidth(text)/2, screenHeight - 70)

    love.graphics.setColor(1,1,0)
    local labels = { "Person", "Bike", "Car" }
    text = "Press / To View Stats"
    love.graphics.print(text, centerX + 300/2 + 50 - font:getWidth(text)/2, screenHeight - 50)

    -- text = "Parts: " .. player2.partsCollected .. "/" .. player2.partsForNextUpgrade
    -- love.graphics.print(text, centerX + 300/2 + 50 - font:getWidth(text)/2, screenHeight - 30)

    -- Game Over
    if GAME_OVER then
        love.graphics.setColor(0.2,0.2,0.2)
        love.graphics.rectangle("fill", 0, 0, screenWidth,screenHeight)
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(love.graphics.newFont(50))
        text = "Player " .. winner .. " wins the race!"
        love.graphics.print(text, 120, centerY - font:getHeight(text)/2)

        -- play again prompt
        love.graphics.setColor(1,0,0)
        love.graphics.setFont(love.graphics.newFont(30))
        text = "Press R to play again"
        love.graphics.print(text, 250, centerY + font:getHeight(text)/2 + 50)
    end
end

-- Game Over
function gameOver(winner)
    GAME_OVER = true
    _G.winner = winner
    print("🏁🏁Game Over! Player " .. winner .. " wins!🏁🏁")
    -- stop all entities
    for _, e in ipairs(entities) do
        e.active = false
    end
    -- stop the timers
    partTimer = 0
    partSpawnInterval = 0
end
