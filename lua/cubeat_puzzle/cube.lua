
local Cube = {}

function Cube:new(color_idx, x, y, orig_x, y_orient, garbage)
  x = x or -1
  y = y or -1
  local o = setmetatable({}, {__index = self})
  o:init(color_idx, x, y, orig_x, y_orient, garbage)
  return o
end

function Cube:init(color_idx, x, y, orig_x, y_orient, garbage)
  self.id = color_idx
  self.garbage = garbage or false
  
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
  
  self.y_orient = y_orient or 1
  self.orig_x = orig_x or 64
  self.pixel_size = 256
  self.scale_ratio = 0.25
  self.body:scale(self.scale_ratio, self.scale_ratio)
  self.event_handler = { owner = self }
  

  if self.garbage then
    self.garbage_body = display.newImage( "rc/cw.png" )
    self.garbage_body:scale(self.scale_ratio, self.scale_ratio)
    self.garbage_handler = { owner = self }
  end
  
  self:set_pos(x, y)
  self:update_real_pos()
  self:drop()
end

function Cube:restore()
  if self:is_garbage() then
    self.garbage = false
    self.garbage_body:removeSelf()
    self.garbage_body = nil
    if self:is_waiting() then
      self.need_check = true
    end
  end
end

function Cube:is_garbage()
  return self.garbage
end

function Cube:has_grounded()
  if not self.grounded then 
    self.drop_a_frame = function(self, now_t, last_t)
      local pos_y = self.body.y + ( 450 * 0.001 * (now_t - last_t) ) * self.y_orient
      self.body.y = pos_y
      if self:is_garbage() then self.garbage_body.y = pos_y end
    end
    self.grounded = true
  end
end

function Cube:drop_a_frame(now_t, last_t, speed)
  local pos_y = self.body.y + ( (speed or 400) * 0.001 * (now_t - last_t) ) * self.y_orient
  self.body.y = pos_y
  if self:is_garbage() then self.garbage_body.y = pos_y end
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
  self:remove_body()
end

function Cube:sink()
  self.state = "sinking"
  self.need_check = false
end

function Cube:fade(duration)
  self.state = "fading"
  self.need_check = false
  transition.to(self.body, {
    alpha = 0, 
    time = duration, 
    onComplete = function() self:die() end
  })
end

function Cube:arrived_at_logical_position()
  if self.y_orient < 0 then 
    return self.body.y <= self.y * (self.pixel_size * self.scale_ratio)
  else
    return self.body.y >= 700 - self.y * (self.pixel_size * self.scale_ratio)
  end
end

function Cube:set_pos(x, y)
  self.x = x
  self.y = y
end

function Cube:update_real_pos()
  local pos_x = self.orig_x + self.x * (self.pixel_size * self.scale_ratio)
  self.body.x = pos_x
  if self:is_garbage() then self.garbage_body.x = pos_x end
  
  local pos_y
  if self.y_orient < 0 then 
    pos_y = self.y * (self.pixel_size * self.scale_ratio)
  else
    pos_y = 700 - self.y * (self.pixel_size * self.scale_ratio)
  end
  self.body.y = pos_y
  if self:is_garbage() then self.garbage_body.y = pos_y end
end

function Cube:setX(x) self.x = x; self:update_real_pos() end
function Cube:setY(y) self.y = y; self:update_real_pos() end
function Cube:remove_body() self.body:removeSelf(); if self.garbage_body then self.garbage_body:removeSelf() end end
function Cube:is_dropping() return self.state == "dropping" end
function Cube:is_sinking() return self.state == "sinking" end
function Cube:is_waiting() return self.state == "waiting" end
function Cube:is_fading() return self.state == "fading" end
function Cube:is_dead() return self.state == "dead" end

-------------------------------------------------------------------

return Cube