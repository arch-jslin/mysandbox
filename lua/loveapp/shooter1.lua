
local helper = require 'helper'
local len_sq = helper.len_sq
local draw_level = helper.draw_level

local WIDTH = helper.WIDTH
local HEIGHT= helper.HEIGHT
local CENTER_P = helper.CENTER_P

local timer = {}

local res
local game = {}
local yuusha = {}
local mob = {}
local bullet = {}

local function unordered_remove(t, o)
  -- for simplicity's sake, we swap it with the last object
  for i = 1, #t do 
    if o == t[i] then
      t[i] = t[#t]
      t[#t] = nil
      break
    end
  end
end

-- because some resources are best set here in game:init, so I put it up here to 
-- see it more clearly

function game:init(resources)
  self.mobs = {}
  self.mob_bullets = {}
  self.yuu_bullets = {}
  self.timers = {}
  
  res = resources -- caution! not self! 
  
  self.yuusha = yuusha.new() 
  
  -- TEST:suppose it already leveled up
  self.yuusha:levelup(10)
end

-- definition of yuusha

function yuusha.new(o)
  o = o or {} 
  o.body_   = res.yuusha_fighter_img
  o.x_      = 30
  o.y_      = love.graphics.getHeight()/2
  o.rad_    = 0
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2 
  
  o.color_  = {r=255, g=255, b=255, a=255}
  
  o.level_  = 1
  
  setmetatable(o, {__index = yuusha})
  return o 
end

function yuusha:update(dt)

end

function yuusha:draw()
  draw_level(res.font1, self.level_, self.x_ - self.ox_ +3, self.y_ - self.oy_ +3)
  love.graphics.setColor(self.color_.r, self.color_.g, self.color_.b, self.color_.a)
  love.graphics.draw(self.body_, self.x_, self.y_, self.rad_, self.facing_, 1, self.ox_, self.oy_)
end

function yuusha:levelup(n)
  for i = 1, n do 
    self.level_  = self.level_ + 1
  end
end

-- definition of mob

function mob.new(o)
  o = o or {}
  o.body_   = res.fighter1_img
  o.x_      = o.x_ or 50
  o.y_      = love.graphics.getHeight()/2 + (math.random() - 0.5)*20
  o.rad_    = 0
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2
  
  o.color_  = {r=255, g=255, b=255, a=255} 
  
  o.vx_     = 0
  o.vy_     = 0
  o.state_  = 'move'
  o.cooldown_ = 1 -- do not shoot for the first second
  o.ammo_   = o.ammo_ or 3  -- 3 for default
  
  setmetatable(o, {__index = mob})
  return o
end

function mob:update(dt, target)
  self:cooldown(dt)
  if self.state_ == 'move' then 
    self:move_function(dt)
      
    if self:can_fire() then
      self:fire(target)
    end
      
  elseif self.state_ == 'dying' then

  end
  -- no, mob movement here isnt' dictated by normal velocity
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

function mob:cooldown(dt)
  if self.cooldown_ > 0 then
    self.cooldown_ = self.cooldown_ - dt -- in seconds 
    return 
  end
  self.cooldown_ = 0
end

function mob:can_fire()
  return self.cooldown_ == 0 and self.ammo_ > 0 
end

function mob:fire(target)
  local dx = target.x_ - self.x_
  local dy = target.y_ - self.y_
  local length = math.sqrt(len_sq(self, target)) 
  local rad = math.atan2(dy, dx)
  local nx = dx / length
  local ny = dy / length
  
  local b = bullet.new{ x_ = self.x_, y_ = self.y_, rad_ = rad, vx_ = 100*nx, vy_ = 100*ny }
  game:add_mob_bullet(b)
  
  self.cooldown_ = self.cooldown_ + 0.3
  self.ammo_ = self.ammo_ - 1
end

-- definition of bullet below

function bullet.new(o)
  o = o or {}
  o.body_   = res.bullet1_img
  o.x_      = o.x_ or 50
  o.y_      = o.y_ or love.graphics.getHeight()/2 + (math.random() - 0.5)*20
  o.rad_    = o.rad_ or 0
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2
  
  o.color_  = {r=255, g=255, b=255, a=255} 
  
  o.vx_     = o.vx_ or 0
  o.vy_     = o.vy_ or 0
  
  setmetatable(o, {__index = bullet})
  return o
end

function bullet:update(dt)
  self.x_ = self.x_ + self.vx_ * dt
  self.y_ = self.y_ + self.vy_ * dt
end

function bullet:draw()
  love.graphics.setColor(self.color_.r, self.color_.g, self.color_.b, self.color_.a)
  love.graphics.draw(self.body_,    -- ref to img
                     self.x_,       -- x
                     self.y_,       -- y
                     self.rad_ + math.pi/2,     -- orientation (radians)
                     1,             -- scale x
                     1,             -- scale y
                     self.ox_,      -- origin x
                     self.oy_)      -- origin y
end

-- definition of game object below

function game:update(dt)
  local delete_timers = {}
  local delete_markers1 = {}
  local delete_markers2 = {}
  local delete_markers3 = {}
  
  -- mob generation queue process
  for _, v in ipairs(self.timers) do 
    v:update(dt)
    if v.loop_ < 0 then
      table.insert(delete_timers, v)
    end
  end
  
  self.yuusha:update(dt)
  for _, v in ipairs(self.mobs) do
    v:update(dt, self.yuusha)
    
    -- remove too far away objects
    if len_sq(v, CENTER_P) > 500000 then -- approx. distance of 700
      table.insert(delete_markers1, v) 
    end
  end
  
  for _, v in ipairs(self.yuu_bullets) do 
    v:update(dt)
    -- remove too far away objects
    if len_sq(v, CENTER_P) > 500000 then -- approx. distance of 700
      table.insert(delete_markers2, v) 
    end
  end
  
  for _, v in ipairs(self.mob_bullets) do 
    v:update(dt)
    -- remove too far away objects
    if len_sq(v, CENTER_P) > 500000 then -- approx. distance of 700
      table.insert(delete_markers3, v) 
    end
  end
  
  -- obj cleanup here
  for _, v in ipairs(delete_timers) do
    unordered_remove(self.timers, v)
  end
  for _, v in ipairs(delete_markers1) do
    unordered_remove(self.mobs, v)
  end
  for _, v in ipairs(delete_markers2) do
    unordered_remove(self.yuu_bullets, v)
  end
  for _, v in ipairs(delete_markers3) do
    unordered_remove(self.mob_bullets, v)
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
  for _, v in ipairs(self.yuu_bullets) do
    v:draw()
  end
  for _, v in ipairs(self.mob_bullets) do 
    v:draw()
  end
end

function game:addmob(o)
  self.mobs[#self.mobs+1] = o
end

function game:add_mob_bullet(o)
  self.mob_bullets[#self.mob_bullets+1] = o
end

function game:add_timer(o)
  self.timers[#self.timers+1] = timer.new(o)
end

function game:is_finished()
  return false
end

-- mob movement function for game object to use

local function mtype1(self) -- come in randomly
  local tmp1 = math.random()-0.5
  local tmp2 = math.random()-0.5
  tmp1 = math.abs(tmp1) / tmp1 -- either 1 or -1
  tmp2 = math.abs(tmp2) / tmp2 -- either 1 or -1
  self.vx_ = ((math.random()/2)+0.5)*tmp1*200
  self.vy_ = ((math.random()/2)+0.5)*tmp2*200
  
  self.x_ = self.vx_ < 0 and WIDTH + math.random()*100 or 0 - math.random()*100
  self.y_ = self.vy_ < 0 and HEIGHT/2 + math.random()*HEIGHT or HEIGHT/2 - math.random()*HEIGHT
end

local function mtype2(self, subtype) -- diagonal
  subtype = subtype or 1
  if subtype == 1 then
    self.x_ = WIDTH; self.y_ = -50; self.vx_ = -200; self.vy_ = 200
  elseif subtype == 2 then
    self.x_ = WIDTH; self.y_ = HEIGHT+50; self.vx_ = -200; self.vy_ = -200
  elseif subtype == 3 then
    self.x_ = 0; self.y_ = 50; self.vx_ = 200; self.vy_ = 200
  elseif subtype == 4 then
    self.x_ = 0; self.y_ = HEIGHT+50; self.vx_ = 200; self.vy_ = -200
  end
end

local function mtype1_move(self, dt)
  self.x_ = self.x_ + self.vx_ * dt
  self.y_ = self.y_ + self.vy_ * dt
end

-- We really need a mob factory here

function timer.new(o)
  o = o or {}
  
  o.loop_   = o.loop_ or 0
  o.dur_    = o.dur_ or 1 -- in seconds
  o.time_   = 0           -- in seconds
  o.action_ = o.action_ or nil
  
  setmetatable(o, {__index = timer})
  return o
end

function timer:update(dt)
  self.time_ = self.time_ + dt
  if self.time_ > self.dur_ then
    self.time_ = 0 
    self.loop_ = self.loop_ - 1
    self:action_()
  end
end

--

function game:keyreleased(key)
  if key == 'z' then
    self:add_timer{ loop_ = 5, dur_ = 0.3,
      action_ = function()
        local m = mob.new()
        mtype1(m)
        m.move_function = mtype1_move
        self:addmob(m)  
      end
    }
  end
  if key == 'x' then
    local dir = math.floor(math.random()*4)+1
    self:add_timer{ loop_ = 5, dur_ = 0.3,
      action_ = function()
        local m = mob.new()
        mtype2(m, dir)
        m.move_function = mtype1_move
        self:addmob(m)  
      end
    }
  end
end

return game
