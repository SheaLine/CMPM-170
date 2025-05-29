-- Requires
local Player    = require "player"
local Map       = require "map"
local Minigame  = require "minigame"
local Timer    = require "lib.timer"
local Countdown = require "countdown"

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
    -- 1) Clip to this viewport’s rectangle
    love.graphics.setScissor(self.x, self.y, self.w, self.h)

    -- 2) Shift the origin so (0,0) is the top‑left of this viewport
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- 3) Draw whatever Entity lives here (map or minigame)
    if self.entity and self.entity.draw then
        -- pass the viewport’s width/height so your draw(viewW, viewH) works
        self.entity:draw(self.w, self.h)
    end

    if self.entity.type == "map" then
        gameTimer:draw(self.w/2, 10)
    end

    -- 4) Un‑translate
    love.graphics.pop()

    -- 5) Reset clipping
    love.graphics.setScissor()

    -- 6) Draw a debug border so you can see the split‑screen regions
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
function Blank:new() return setmetatable({}, self) end
function Blank:update() end
function Blank:draw(w, h)
    -- draw neutral background
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1,1,1)
end
function Blank:handleInput() end

-- Globals
local mapEntity, players, p1Minigame, p2Minigame, viewports, blankEntity

function generateViewports()
    local W, H = love.graphics.getDimensions()
    local topH = H * 0.3
    local botH = H - topH
    blankEntity = blankEntity or Blank:new()
    viewports = {
        Viewport:new(0,0, W * 0.5, topH, p1Minigame or blankEntity),
        Viewport:new(W * 0.5,0, W * 0.5, topH, p2Minigame or blankEntity),
        Viewport:new(0,topH,W, botH, mapEntity)
    }
end

function love.load()
    -- instantiate players
    players = {
        Player:new(1, 100, 150, {up="w", down="s", left="a", right="d", action="q"}, {1,0,0}),
        Player:new(2, 200, 150, {up="up", down="down", left="left", right="right", action="/"}, {0,0,1})
    }
    -- map
    mapEntity = Map:new(800, 600, 64, players)
    p1Minigame, p2Minigame = nil, nil

    -- countdown timer
    local TIMER_DURATION = 60
    gameTimer = Countdown:new(TIMER_DURATION, nil, function()
        GameOver()
    end)
    gameTimer:start()
    generateViewports()
end

function love.resize(w, h)
    generateViewports()
end

function love.update(dt)
    Timer.update(dt) -- update timers

    for _, vp in ipairs(viewports) do vp:update(dt) end

    -- auto-exit minigame when completed after 5 seconds
    if p1Minigame and p1Minigame.completed then
        Timer.after(5, function()
            players[1].inMinigame = false
            p1Minigame = nil
            generateViewports()
        end)
    end
    if p2Minigame and p2Minigame.completed then
        Timer.after(5, function()
            players[2].inMinigame = false
            p2Minigame = nil
            generateViewports()
        end)
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
                p1Minigame = Minigame:new(1)
            elseif p.playerId == 2 then
                p2Minigame = Minigame:new(2)
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