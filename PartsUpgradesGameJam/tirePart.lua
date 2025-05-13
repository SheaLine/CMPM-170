local Part = require "part"
local TirePart = setmetatable({}, { __index = Part })
TirePart.__index = TirePart

function TirePart:new(x, y, player)
    local p = Part.new(self, x, y, player)
    p.type   = "tire"
    p.color  = {0,1,0.2}
    p.radius = 10
    p.width, p.height = p.radius*2, p.radius*2
    return p
end

return TirePart
