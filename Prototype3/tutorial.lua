local Entity = require "entity"
local Timer  = require "lib.timer"

local Tutorial = setmetatable({}, { __index = Entity })
Tutorial.__index = Tutorial

function Tutorial:new()
    local instance = Entity.new(self, 0, 0)
    instance.type       = "tutorial"
    return instance
end


return Tutorial
