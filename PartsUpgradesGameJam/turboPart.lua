local Part = require "part"
local TurboPart = setmetatable({}, { __index = Part })
TurboPart.__index = TurboPart

function TurboPart:new(x, y, player)
    local p = Part.new(self, x, y, player)
    p.type   = "turbo"
    p.color  = {1,0.5,0}
    p.radius = 10
    p.width, p.height = p.radius*2, p.radius*2
    return p
end

return TurboPart
