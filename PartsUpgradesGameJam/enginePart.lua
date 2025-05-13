local Part = require "part"
local EnginePart = setmetatable({}, { __index = Part })
EnginePart.__index = EnginePart

function EnginePart:new(x, y, player)
    local p = Part.new(self, x, y, player)
    p.type   = "engine"
    p.color  = {1,0,0}
    p.radius = 10
    p.width  = p.radius*2; p.height = p.radius*2
    return p
end

return EnginePart
