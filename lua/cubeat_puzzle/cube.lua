
local Cube = {}

function Cube:new(color_idx, x, y)
  x = x or -1
  y = y or -1
  local o = setmetatable({}, {__index = self})
  o:init(color_idx)
  o:set_pos(x, y)
  o:update_real_pos()
  return o
end

function Cube:init(color_idx)
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
  self.body:scale(3, 3)
end

function Cube:needs_update()
  return self.body.y >= 800-self.y*72 + 72
end

function Cube:set_pos(x, y)
  self.x = x
  self.y = y
end

function Cube:update_real_pos()
  self.body.x = self.x*72
  self.body.y = 800-self.y*72
end

function Cube:setX(x) self.x = x; self:update_real_pos() end
function Cube:setY(y) self.y = y; self:update_real_pos() end
function Cube:remove_body() self.body:removeSelf() end

return Cube