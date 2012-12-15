-- 1d role playing game (like)

local game = {}

local res = {}

local yuusha = {}
local mob = {}

-- because some resources are best set here in game:init, so I put it up here to 
-- see it more clearly

function game:init()
  self.objs = {}
  
  res.yuusha_img = love.graphics.newImage("img/yuusha1.png")
  res.mob1_img   = love.graphics.newImage("img/mob1.png")
  
  self:add(yuusha.new()) -- at least have 1 yuusha at the beginning
end

-- definition of yuusha

function yuusha.new(o)
  o = o or {} 
  o.body_ = res.yuusha_img
  o.x_ = love.graphics.getWidth()/2
  o.y_ = love.graphics.getHeight()/2
  o.ox_ = o.body_:getWidth()/2 
  o.oy_ = o.body_:getHeight()/2 
  setmetatable(o, {__index = yuusha})
  return o 
end

function yuusha:update()
end

function yuusha:draw()
  love.graphics.draw(self.body_, self.x_, self.y_, 0, 1, 1, self.ox_, self.oy_)
end

-- definition of mob

function mob.new(o)
  o = o or {}
  o.body_ = res.mob1_img
  o.x_      = o.x_ or 50
  o.y_      = love.graphics.getHeight()/2
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2 
  setmetatable(o, {__index = mob})
  return o
end

function mob:update(dt)
  local halfw = love.graphics.getWidth()/2
  if self.x_ > halfw then
    self.x_ = self.x_ - 200 * dt
  else
    self.x_ = self.x_ + 200 * dt
  end
  
  -- some arbitrary dying condition
  if self.x_ >= halfw - 1 and self.x_ <= halfw + 1 then
    game:remove(self)
  end
end

function mob:draw()
  love.graphics.draw(self.body_,    -- ref to img
                     self.x_,       -- x
                     self.y_,       -- y
                     0,             -- orientation (radians)
                     self.facing_,  -- scale x
                     1,             -- scale y
                     self.ox_,      -- origin x
                     self.oy_)      -- origin y
end

-- definition of game object below

function game:update(dt)
  if type(self.objs) ~= 'table' then return end
  
  for _, v in ipairs(self.objs) do
    v:update(dt)
  end
  
  -- after update we sort the objs table to prepare for ordered drawing
  table.sort(self.objs, function(a, b)
    return a.x_ < b.x_
  end)
end

function game:draw()
  if type(self.objs) ~= 'table' then return end
  
  for _, v in ipairs(self.objs) do
    v:draw()
  end
end

function game:add(o)
  self.objs[#self.objs+1] = o
end

function game:remove(o)
  -- for simplicity's sake, we swap it with the last object
  for i = 1, #self.objs do 
    if o == self.objs[i] then
      self.objs[i] = self.objs[#self.objs]
      self.objs[#self.objs] = nil
      break
    end
  end
end

function game:keyreleased(key)
  if key == 'z' then
    self:add(mob.new{ x_ = 0 })
  elseif key == 'x' then
    self:add(mob.new{ x_ = love.graphics.getWidth(), facing_ = -1 })
  end
end

return game
