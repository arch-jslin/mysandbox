-- 1d role playing game (like)

local len_sq = require 'helper'.len_sq

local res = {}

local function draw_hp(hp_percent, total_len, x, y)
  if hp_percent <= 0 then return end
  love.graphics.setColor(255, 50, 50, 255)
  love.graphics.setLine(6)
  love.graphics.line(x, y-5, x+total_len, y-5)
  love.graphics.setColor(100, 255, 100, 255)
  love.graphics.setLine(4)
  love.graphics.line(x+1, y-5, x+(total_len*hp_percent)-2, y-5)
end

local function draw_level(level, x, y)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(res.font1)
  love.graphics.print("Lv "..level, x, y - 25)
end

local game = {}
local yuusha = {}
local mob = {}

-- because some resources are best set here in game:init, so I put it up here to 
-- see it more clearly

function game:init()
  self.mobs = {}
  
  res.yuusha_img = love.graphics.newImage("img/yuusha1.png")
  res.mob1_img   = love.graphics.newImage("img/mob1.png")
  res.font1      = love.graphics.newFont("img/Exo-Medium.ttf", 12)
  
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
  o.max_hp_ = 30
  o.hp_     = o.max_hp_
  o.dmg_    = 5
  o.state_  = 'normal'
  
  o.cooldown_ = 0 -- in seconds 
  o.level_  = 1
  o.max_exp_= 4
  o.exp_    = 0
  
  setmetatable(o, {__index = yuusha})
  return o 
end

function yuusha:update(dt)
  -- Since before drawing, game will re-sort the mob list again,
  -- so if performance is not a problem, we should be able to sort the list to yuusha's favor...
  self:cooldown(dt)
  if self:is_cooldown() then
    self.state_ = 'normal'
    self.color_.b = 255
  end
  
  if #game.mobs < 1 then return end
  
  table.sort(game.mobs, function(a, b)
    local death_penalty_a = a:is_dying() and 1000 or 0
    local death_penalty_b = b:is_dying() and 1000 or 0
    return math.abs(a.x_ - self.x_) + death_penalty_a < math.abs(b.x_ - self.x_) + death_penalty_b
  end)

  if self.state_ == 'normal' then
    
        -- special case to trigger rampage state
    if #game.mobs >= 4 and game.mobs[1].facing_ == game.mobs[3].facing_ and 
       game.mobs[1].facing_ ~= game.mobs[2].facing_ and game.mobs[2].facing_ == game.mobs[4].facing_ and
       game.mobs[1].facing_ == self.facing_ then
      self.state_ = 'rampage'
      self.color_.b = 0
      self.cooldown_ = self.cooldown_ + 2.5 -- for rampage countdown
    end
    
    if self:is_cooldown() then
      self.facing_ = -game.mobs[1].facing_
      self.cooldown_ = self.cooldown_ + 0.5 -- in seconds
    end
  elseif self.state_ == 'rampage' then
    -- in rampage don't account for cooldown
    self.facing_ = -game.mobs[1].facing_
  end
end

function yuusha:cooldown(dt) 
  if self.cooldown_ > 0 then
    self.cooldown_ = self.cooldown_ - dt -- in seconds 
    return 
  end
  self.cooldown_ = 0
end

function yuusha:is_cooldown()
  return self.cooldown_ == 0
end

function yuusha:draw()
  draw_hp(self.hp_ / self.max_hp_, 
          self.body_:getWidth(), 
          self.x_ - self.ox_, 
          self.y_ - self.oy_)
  if self.hp_ > 0 then
    draw_level(self.level_, self.x_ - self.ox_, self.y_ - self.oy_)
  end
  love.graphics.setColor(self.color_.r, self.color_.g, self.color_.b, self.color_.a)
  love.graphics.draw(self.body_, self.x_, self.y_, 0, self.facing_, 1, self.ox_, self.oy_)
end

function yuusha:attack(o)
  o.hp_ = o.hp_ - self.dmg_ 
end

function yuusha:getexp(n)
  self.exp_ = self.exp_ + n
  if self.exp_ >= self.max_exp_ then
    self:levelup(1)
  end
end

function yuusha:levelup(n)
  for i = 1, n do 
    self.level_  = self.level_ + 1
    self.max_hp_ = self.max_hp_ + 15 * (1+self.level_/10)
    self.hp_     = self.max_hp_
    self.dmg_    = self.dmg_ + 5 * (1+self.level_/10)
    self.max_exp_= self.max_exp_ + 2
    self.exp_    = 0
  end
end

-- definition of mob

function mob.new(o)
  o = o or {}
  o.body_   = res.mob1_img
  o.x_      = o.x_ or 50
  o.y_      = love.graphics.getHeight()/2 + (math.random() - 0.5)*20
  o.rad_    = 0
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2
  
  o.color_  = {r=255, g=255, b=255, a=255} 
  o.max_hp_ = 6
  o.hp_     = o.max_hp_
  o.dmg_    = 1
  
  o.vx_     = 200
  o.vy_     = 0
  o.vrad_   = 0
  o.state_  = 'move'
  o.level_  = 1
  
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
      self.vy_   = (math.random() - 0.5) * 300 
      self.vrad_ = (math.random() - 0.5) * 10
    end
  elseif self.state_ == 'dying' then
    self.rad_ = self.rad_ + self.vrad_ * dt
    if self.color_.a > 255 * dt then 
      self.color_.a = self.color_.a - 255 * dt
    end
  end
  self.x_ = self.x_ + (self.vx_ * dt)
  self.y_ = self.y_ + (self.vy_ * dt)
end

function mob:draw()
  draw_hp(self.hp_ / self.max_hp_, 
          self.body_:getWidth(), 
          self.x_ - self.ox_, 
          self.y_ - self.oy_)
  if self.hp_ > 0 then
    draw_level(self.level_, self.x_ - self.ox_, self.y_ - self.oy_)
  end
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

function mob:levelup(n)
  for i = 1, n do 
    self.level_  = self.level_ + 1
    self.max_hp_ = self.max_hp_ + 5 * (1+self.level_/10)
    self.hp_     = self.max_hp_
    self.dmg_    = self.dmg_ + 1 * (1+self.level_/10)
  end
end

-- definition of game object below

function game:process_battle(v) 
  if not v:is_dying() and math.abs( v.x_ - self.yuusha.x_ ) < 50 then
    if v.facing_ * self.yuusha.facing_ < 0 then -- means they have different facing
      self.yuusha:attack(v)
    elseif v.facing_ * self.yuusha.facing_ > 0 then -- means they have the same facing
      v:attack(self.yuusha)
    else -- huh?
      print("Game1: Huh?")
    end
    if v.hp_ > 0 then
      v.x_ = v.x_ - (100 * v.facing_) -- back off for a bit after attacking
    else
      self.yuusha:getexp(1)
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
    local m = mob.new{ x_ = 0 } 
    m:levelup( self.yuusha.level_ - 1 )
    self:addmob(m)
  elseif key == 'x' then
    local m = mob.new{ x_ = love.graphics.getWidth(), facing_ = -1 } 
    m:levelup( self.yuusha.level_ - 1 )
    self:addmob(m)
  end
end

return game
