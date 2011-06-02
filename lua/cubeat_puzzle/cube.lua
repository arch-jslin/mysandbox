
local Cube = {}

function Cube:new(color_idx, x, y)
  x = x or -1
  y = y or -1
  local o = setmetatable({}, {__index = self})
  o:init(color_idx, x, y)
  return o
end

function Cube:init(color_idx, x, y)
  self.id = color_idx
  if color_idx == 1 then
    self.body = display.newImage( "rc/cr.png" )
  elseif color_idx == 2 then
    self.body = display.newImage( "rc/cg.png" )
  elseif color_idx == 3 then
    self.body = display.newImage( "rc/cb.png" )
  elseif color_idx == 4 then
    self.body = display.newImage( "rc/cy.png" )
  else
    error("Exception at Cube:init, color_idx choosing.")
  end
  self.body:scale(2.75, 2.75)
  self.event_handler = { owner = self }
  
  self:set_pos(x, y)
  self:update_real_pos()
  self:drop()
end

function Cube:drop_a_frame(now_t, last_t)
  self.body.y = self.body.y + 7 * (1/(1000/60)) * (now_t - last_t)
end

function Cube:wait()
  self.state = "waiting"
  self.need_check = true
end

function Cube:drop()
  self.state = "dropping"
  self.need_check = false
end

function Cube:die()
  self.state = "dead"
  self.need_check = false
end

function Cube:fade(duration)
  self.state = "fading"
  self.need_check = false
  transition.to(self.body, {
    alpha = 0, 
    time = duration, 
    onComplete = function() 
      self.body:removeSelf() 
      self:die() 
    end
  })
end

function Cube:arrived_at_logical_position()
  return self.body.y >= 730 - self.y*68
end

function Cube:set_pos(x, y)
  self.x = x
  self.y = y
end

function Cube:update_real_pos()
  self.body.x = self.x*68
  self.body.y = 730 - self.y*68
end

function Cube:setX(x) self.x = x; self:update_real_pos() end
function Cube:setY(y) self.y = y; self:update_real_pos() end
function Cube:remove_body() self.body:removeSelf() end
function Cube:is_dropping() return self.state == "dropping" end
function Cube:is_waiting() return self.state == "waiting" end
function Cube:is_fading() return self.state == "fading" end
function Cube:is_dead() return self.state == "dead" end

-------------------------------------------------------------------

return Cube