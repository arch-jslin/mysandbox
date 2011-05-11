
local Cube = {}

function Cube:new(color_idx, x, y)
  local o = setmetatable({}, {__index = self})
  o:init(color_idx)
  if x then o:setX(x) end
  if y then o:setY(y) end
  return o
end

function Cube:init(color_idx)
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

function Cube:setPos(x, y)
  self.body.x = x
  self.body.y = y
end

function Cube:setX(x) self.body.x = x end
function Cube:setY(y) self.body.y = y end
function Cube:removeBody() self.body:removeSelf() end

return Cube