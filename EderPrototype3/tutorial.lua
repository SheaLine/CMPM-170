local Entity = require "entity"
local Tutorial = setmetatable({}, { __index = Entity })
Tutorial.__index = Tutorial

function Tutorial:new()
  local inst = Entity.new(self, 0, 0)
  inst.type        = "tutorial"
  inst.queue       = {}      -- holds { msg = str, duration = n } entries
  inst.currentMsg  = nil
  inst.msgTimer    = 0
  inst.active      = false
  inst.state       = "normal"
  return inst
end

-- enqueue a batch of messages
function Tutorial:queueMessages(messages, duration)
  for _, msg in ipairs(messages) do
    table.insert(self.queue, { msg = msg, duration = duration })
  end
  -- if nothing is showing right now, start immediately
  if not self.currentMsg then
    self:advance()
  end
end

-- advance to the next message in the queue
function Tutorial:advance()
  local nextEntry = table.remove(self.queue, 1)
  if nextEntry then
    self.currentMsg = nextEntry.msg
    self.msgTimer   = nextEntry.duration
    self.active     = true
  else
    -- no more messages
    self.currentMsg = nil
    self.active     = false
  end
end

function Tutorial:update(dt)
  if self.currentMsg then
    self.msgTimer = self.msgTimer - dt
    if self.msgTimer <= 0 then
      -- time’s up, move on
      self.active = false
      self:advance()
    end
  end
end

function Tutorial:draw()
    if not self.active or not self.currentMsg then return end
    local color = (self.state == "normal") and {1, 1, 1} or {1, 0, 0}
    love.graphics.setColor(color)
    love.graphics.printf(
        self.currentMsg,
        0, 40, love.graphics.getWidth(), "center"
    )
    love.graphics.setColor(1,1,1)
end

return Tutorial