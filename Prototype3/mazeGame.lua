-- maze_minigame.lua
-- A Maze minigame that extends the base Minigame class

local Minigame = require "minigame"
local MazeMinigame = setmetatable({}, { __index = Minigame })
MazeMinigame.__index = MazeMinigame

-- Predefined simple maze layout (1=wall, 0=empty)
local MAZES = {
    {
        grid ={
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1},
            {1,1,1,0,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1},
            {1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1},
            {1,0,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,0,1},
            {1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0,1,0,1},
            {1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,0,1},
            {1,0,1,0,0,0,1,0,0,0,0,0,1,0,1,0,1,0,1},
            {1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,0,1},
            {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        },
        meta = {StartX = 2, StartY = 4, ExitX = 19, ExitY = 10}
    },
    {
        grid ={
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,1},
            {1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1,1,0,1},
            {1,0,0,0,1,0,0,0,1,0,0,0,1,0,1,0,0,0,1},
            {1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,0,1,1,1},
            {1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,1},
            {1,0,1,0,1,1,1,1,1,0,1,1,1,0,1,1,1,0,1},
            {1,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0,0,0,1},
            {1,0,1,1,1,0,1,0,1,0,1,0,1,1,1,0,1,0,1},
            {1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        },
        meta = {StartX = 2, StartY = 2, ExitX = 16, ExitY = 2}
    },
    {
        grid ={
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1},
            {1,1,1,1,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1},
            {1,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1},
            {1,0,1,1,1,1,1,0,1,0,1,1,1,0,1,1,1,0,1},
            {1,0,1,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1},
            {1,0,1,1,1,1,1,0,1,1,1,0,1,0,1,0,1,1,1},
            {1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1},
            {1,0,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1},
            {1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        },
        meta = {StartX = 18, StartY = 2, ExitX = 2, ExitY = 2}
    },

}

function MazeMinigame:new(playerId)
    -- call base constructor
    local instance = Minigame.new(self, playerId)
    local choice = MAZES[ math.random( #MAZES ) ]
    local grid  = choice.grid
    local meta  = choice.meta
    -- maze dimensions
    instance.cols    = #grid[1]
    instance.rows    = #grid
    instance.grid    = grid
    -- start and exit positions
    instance.startX  = meta.StartX
    instance.startY  = meta.StartY
    instance.exitX   = meta.ExitX
    instance.exitY   = meta.ExitY
    -- current cursor
    instance.curX    = instance.startX
    instance.curY    = instance.startY
    return instance
end

function MazeMinigame:draw(viewW, viewH)
    -- background & base UI
    Minigame.draw(self, viewW, viewH)
    if self.completed then return end

    -- set up the drawing area
    local margin    = 24  -- for instructions at top
    local avaH      = viewH - margin - 4
    local avaW      = viewW

    -- compute cellSize just like before
    local cellW     = avaW / self.cols
    local cellH     = avaH / self.rows
    local cellSize  = math.floor(math.min(cellW, cellH))
    self.cellSize   = cellSize

    -- compute the maze's pixel dimensions
    local mazeW     = cellSize * self.cols
    local mazeH     = cellSize * self.rows

    -- compute offsets to center it
    local offsetX   = (avaW - mazeW) / 2
    local offsetY   = margin + ((avaH - mazeH) / 2)

    -- draw walls and exit
    for y,row in ipairs(self.grid) do
        for x,cell in ipairs(row) do
        local px = offsetX + (x-1)*cellSize
        local py = offsetY + (y-1)*cellSize
        if cell == 1 then
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill", px, py, cellSize-2, cellSize-2)
        elseif x == self.exitX and y == self.exitY then
            love.graphics.setColor(0,1,0)
            love.graphics.rectangle("fill", px, py, cellSize-2, cellSize-2)
        end
        end
    end

    -- draw the red cursor
    local cx = offsetX + (self.curX-1)*cellSize
    local cy = offsetY + (self.curY-1)*cellSize
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", cx+4, cy+4, cellSize-8, cellSize-8)

    -- draw the instruction on top
    love.graphics.setColor(1,1,1)
    love.graphics.printf(
        "Get to the green box",
        0, 4, viewW, "center"
    )
    end

-- handle arrow or WASD movement, plus base completion key
function MazeMinigame:handleInput(key)    
    Minigame.handleInput(self, key)
    
    -- movement based on player
    local dx, dy = 0, 0
    if self.playerId == 1 then
        if key == "w" then dy = -1 end
        if key == "s" then dy =  1 end
        if key == "a" then dx = -1 end
        if key == "d" then dx =  1 end
    else
        if key == "up"   then dy = -1 end
        if key == "down" then dy =  1 end
        if key == "left" then dx = -1 end
        if key == "right"then dx =  1 end
    end

    -- attempt move
    if dx ~= 0 or dy ~= 0 then
        local nx = self.curX + dx
        local ny = self.curY + dy
        -- check bounds & wall
        if nx >= 1 and nx <= self.cols
        and ny >= 1 and ny <= self.rows
        and self.grid[ny][nx] == 0 then
            self.curX, self.curY = nx, ny
            -- check for victory
            if nx == self.exitX and ny == self.exitY then
                self.completed = true
            end
        end
    end
end

return MazeMinigame
