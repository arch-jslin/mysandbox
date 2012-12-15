-- 1d role playing game (like)

local len_sq = require 'helper'.len_sq

local game = {}

local res = {}

local yuusha = {}
local mob = {}

-- because some resources are best set here in game:init, so I put it up here to 
-- see it more clearly

function game:init()
  self.mobs = {}
  
  res.yuusha_img = love.graphics.newImage("img/yuusha1.png")
  res.mob1_img   = love.graphics.newImage("img/mob1.png")
  
  self.yuusha = yuusha.new() 
end

-- definition of yuusha

function yuusha.new(o)
  o = o or {} 
  o.body_   = res.yuusha_img
  o.x_      = love.graphics.getWidth()/2
  o.y_      = love.graphics.getHeight()/2
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2 
  
  o.color_  = {r=255, g=255, b=255, a=255}
  o.hp_     = 300
  o.dmg_    = 10
  
  setmetatable(o, {__index = yuusha})
  return o 
end

function yuusha:update()
  -- Since before drawing, game will re-sort the mob list again,
  -- so if performance is not a problem, we should be able to sort the list to yuusha's favor...
  
  if #game.mobs < 1 then return end
  
  table.sort(game.mobs, function(a, b)
    return math.abs(a.x_ - self.x_) < math.abs(b.x_ - self.x_)
  end)
  
  -- make it invincible first
  if game.mobs[1].x_ > self.x_ then 
    self.facing_ = 1
  else
    self.facing_ = -1
  end
end

function yuusha:draw()
  love.graphics.setColor(self.color_.r, self.color_.g, self.color_.b, self.color_.a)
  love.graphics.draw(self.body_, self.x_, self.y_, 0, self.facing_, 1, self.ox_, self.oy_)
end

function yuusha:attack(o)
  o.hp_ = o.hp_ - self.dmg_ 
end

-- definition of mob

function mob.new(o)
  o = o or {}
  o.body_   = res.mob1_img
  o.x_      = o.x_ or 50
  o.y_      = love.graphics.getHeight()/2
  o.rad_    = 0
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2
  
  o.color_  = {r=255, g=255, b=255, a=255} 
  o.hp_     = 1
  o.dmg_    = 1
  
  o.vx_     = 200
  o.vy_     = 0
  o.vrad_   = 0
  o.state_  = 'move'
  
  setmetatable(o, {__index = mob})
  return o
end

function mob:update(dt)
  if self.state_ == 'move' then 
    local halfw = love.graphics.getWidth()/2
    if self.x_ > halfw then
      self.vx_ = -200
    else
      self.vx_ = 200
    end
    
    if self.hp_ <= 0 then
      self.state_ = 'dying'
      self.vx_   = self.vx_ * -0.8
      self.vy_   = (math.random() - 0.5) * 200 
      self.vrad_ = (math.random() - 0.5) * 10
    end
  elseif self.state_ == 'dying' then
    self.rad_ = self.rad_ + self.vrad_ * dt
    if self.color_.a > 0 then 
      self.color_.a = self.color_.a - 0.33
    end
  end
  self.x_ = self.x_ + (self.vx_ * dt)
  self.y_ = self.y_ + (self.vy_ * dt)
end

function mob:draw()
  love.graphics.setColor(self.color_.r, self.color_.g, self.color_.b, self.color_.a)
  love.graphics.draw(self.body_,    -- ref to img
                     self.x_,       -- x
                     self.y_,       -- y
                     self.rad_,     -- orientation (radians)
                     self.facing_,  -- scale x
                     1,             -- scale y
                     self.ox_,      -- origin x
                     self.oy_)      -- origin y
end

function mob:is_dying()
  return self.state_ == 'dying' 
end

function mob:attack(o)
  o.hp_ = o.hp_ - self.dmg_ 
end

-- definition of game object below

function game:process_battle(v) 
  if not v:is_dying() and math.abs( v.x_ - self.yuusha.x_ ) < 50 then
    if v.facing_ * self.yuusha.facing_ < 0 then -- means they have different facing
      self.yuusha:attack(v)
    elseif v.facing_ * self.yuusha.facing_ > 0 then -- means they have the same facing
      v:attack(self.yuusha)
      v.x_ = v.x_ - (100 * v.facing_) -- back off for a bit after attacking
    else -- huh?
      print("Game1: Huh?")
    end
  end 
end

function game:update(dt)
  local object_to_be_removed_this_frame = {}
  
  self.yuusha:update(dt)
  for _, v in ipairs(self.mobs) do
    -- process who attack who here: 
    self:process_battle(v)
    v:update(dt)
    
    if v:is_dying() and len_sq(self.yuusha, v) > 90000 then -- length squared! don't use sqrt
      table.insert(object_to_be_removed_this_frame, v) 
    end
  end
  
  -- obj cleanup here
  for _, v in ipairs(object_to_be_removed_this_frame) do
    self:remove(v)
  end
  
  -- after update we sort the objs table to prepare for ordered drawing
  table.sort(self.mobs, function(a, b)
    return a.x_ < b.x_
  end)
end

function game:draw()
  self.yuusha:draw()  
  for _, v in ipairs(self.mobs) do
    v:draw()
  end
end

function game:addmob(o)
  self.mobs[#self.mobs+1] = o
end

function game:remove(o)
  -- for simplicity's sake, we swap it with the last object
  for i = 1, #self.mobs do 
    if o == self.mobs[i] then
      self.mobs[i] = self.mobs[#self.mobs]
      self.mobs[#self.mobs] = nil
      break
    end
  end
end

function game:keyreleased(key)
  if key == 'z' then
    self:addmob(mob.new{ x_ = 0 })
  elseif key == 'x' then
    self:addmob(mob.new{ x_ = love.graphics.getWidth(), facing_ = -1 })
  end
end

return game
