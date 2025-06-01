-- Requires
local Player    = require "player"
local Map       = require "map"
local Minigame  = require "minigame"
local Timer    = require "lib.timer"
local Countdown = require "countdown"
local MazeMinigame = require "mazeGame"
local GuessMinigame = require "guessGame"
Tutorial = require "tutorial"

-- Globals
local mapEntity, players, p1Minigame, p2Minigame, viewports, blankEntity1, blankEntity2
local tutor = tutor or Tutorial:new()
local p1FirstDone, p2FirstDone = false, false


-- auto scale the game to fit the window
local Viewport = {}
Viewport.__index = Viewport
function Viewport:new(x, y, w, h, entity)
    local v = setmetatable({}, self)
    v.x, v.y, v.w, v.h = x, y, w, h
    v.entity = entity
    return v
end
function Viewport:update(dt)
    if self.entity and self.entity.update then
        self.entity:update(dt)
    end
end

function Viewport:draw()
    -- Clip to this viewport’s rectangle
    love.graphics.push()
    love.graphics.setScissor(self.x, self.y, self.w, self.h)

    -- Shift the origin so (0,0) is the top‑left of this viewport
    love.graphics.translate(self.x, self.y)

    -- Draw whatever Entity lives here (map, minigame, blank, or tutorial)
    if self.entity and self.entity.draw then
        self.entity:draw(self.w, self.h)
    end

    if self.entity.type == "map" then
        gameTimer:draw(self.w/2, 10)
    end

    if self.entity and self.entity.type == "blank" then
        love.graphics.setFont(SmallFont)
        love.graphics.printf(
            string.format("No current Player %d Minigame.", self.entity.playerId),
            0, self.h/2, self.w, "center"
        )
        love.graphics.printf(
            "Go try to fix something in the city!",
            0, self.h/2 + 20, self.w, "center"
        )
    end

    if self.entity.type == "tutorial" then
        if self.entity.state == "normal" then
            love.graphics.setColor(1,1,1)
            love.graphics.printf(
                ":) Tutorial :)",
                0, 10, self.w, "center"
            )
        else 
            love.graphics.setColor(1,0,0)
            love.graphics.printf(
                ">:( Tutorial >:(",
                0, 10, self.w, "center"
            )
        end
    end

    -- Un‑translate
    love.graphics.pop()

    -- Reset clipping
    love.graphics.setScissor()

    -- Draw a debug border so you can see the split‑screen regions
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
    love.graphics.setColor(1,1,1)
end


function Viewport:handleInput(key)
    if self.entity and self.entity.handleInput then
        self.entity:handleInput(key)
    end
end

-- Blank placeholder entity for empty minigame slots
local Blank = {}
Blank.__index = Blank
function Blank:new(playerId)
    local instance = setmetatable({}, self)
    instance.type = "blank"
    instance.playerId = playerId
    return instance 
end
function Blank:update() end
function Blank:draw(w, h)
    -- draw neutral background
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1,1,1)
end
function Blank:handleInput() end

function generateViewports()
    local W, H       = love.graphics.getDimensions()
    local topH       = H * 0.30              
    local tutorialH  = topH * 0.50          
    local mapH       = H - topH - tutorialH  

    blankEntity1 = blankEntity1 or Blank:new(1)
    blankEntity2 = blankEntity2 or Blank:new(2)

    viewports = {
      Viewport:new(0,         0, W * 0.5, topH, p1Minigame or blankEntity1),
      Viewport:new(W * 0.5,   0, W * 0.5, topH, p2Minigame or blankEntity2),
      Viewport:new(0,      topH,   W,     mapH,   mapEntity),
      Viewport:new(0, topH + mapH, W, tutorialH, tutor),
    }
end

function love.load()
    math.randomseed(os.time())

    -- Fonts
    ReallyBigFont = love.graphics.newFont(72)
    DefaultFont = love.graphics.newFont(16)
    SmallFont = love.graphics.newFont(12)
    love.graphics.setFont(DefaultFont)

    -- instantiate players
    players = {
        Player:new(1, 100, 150, {up="w", down="s", left="a", right="d", action="q"}, {1,0,0}),
        Player:new(2, 200, 150, {up="up", down="down", left="left", right="right", action="/"}, {0,0,1})
    }
    -- map
    mapEntity = Map:new(800, 600, 64, players)
    p1Minigame, p2Minigame = nil, nil

    -- countdown timer
    local TIMER_DURATION = 300
    gameTimer = Countdown:new(TIMER_DURATION, nil, function()
        GameOver()
    end)
    gameTimer:start()

    -- first tutorial message
    tutor:queueMessages(
    {"Hey there friend! Do you mind helping me turn on the lights in here I am at City Hall",
    "Red Player, use WASD to move around the city and Q to start a minigame.",
    "Blue Player, use the arrow keys to move around the city and / to start a minigame.",
    "Once you successfully complete a minigame, whatever was broken will be fixed!",
    "Just come over here and press Q if you are Red or / if you are Blue to fix City Hall!",
    "Once you complete the minigame, the lights will turn on. Please hurry, I am getting scared!"},
        7
    )
    
    generateViewports()
end

function love.resize(w, h)
    generateViewports()
end

function love.update(dt)
    Timer.update(dt) -- update timers

    for _, vp in ipairs(viewports) do vp:update(dt) end

    -- auto-exit minigame when completed after 5 seconds
    if p1Minigame and p1Minigame.completed and not p1Minigame.exitScheduled then
        p1Minigame.exitScheduled = true
        Timer.after(5, function()
            players[1].inMinigame = false
            p1Minigame = nil
            generateViewports()
        end)
    end
    if p2Minigame and p2Minigame.completed and not p2Minigame.exitScheduled then
        p2Minigame.exitScheduled = true
        Timer.after(5, function()
            players[2].inMinigame = false
            p2Minigame = nil
            generateViewports()
        end)
    end

    if p1Minigame and p1Minigame.completed and not p1FirstDone then
        print("Player 1 first minigame done")
        p1FirstDone = true
    end

    if p2Minigame and p2Minigame.completed and not p2FirstDone then
        print("Player 2 first minigame done")
        p2FirstDone = true
    end

    if not tutor.angry and p1FirstDone and p2FirstDone then
        print("HERE")
        tutor.angry = true
        tutor.state   = "angry"
        tutor:queueMessages(
            {"Haha! I lied—I’m free now and will destroy this city!",
            "ahahahahah! You thought you could help me? No way!",
            "Now you must play my twisted minigames to save the city!",
            "I will break everything in this city if you don’t stop me!",
            "The only way to stop me is to complete my minigames!",
            "Or Don't! I don't care! haha!"},
            5
        )
    end
end

function love.draw()
    for _, vp in ipairs(viewports) do vp:draw() end
end

function love.keypressed(key)
    -- trigger minigame creation
    for _, p in ipairs(players) do
        if key == p.controls.action and not p.inMinigame then
            if p.playerId == 1 then
                local minigames = {MazeMinigame, GuessMinigame}
                local chosenMinigame = minigames[math.random(#minigames)]
                p1Minigame = chosenMinigame:new(1)
            elseif p.playerId == 2 then
                local minigames = {GuessMinigame, MazeMinigame}
                local chosenMinigame = minigames[math.random(#minigames)]
                p2Minigame = chosenMinigame:new(2)
            end
            p.inMinigame = true
            generateViewports()
        end
    end
    -- forward input
    for _, vp in ipairs(viewports) do
        vp:handleInput(key)
    end
end

function GameOver()
    print("Game Over!")
    love.event.quit()
end