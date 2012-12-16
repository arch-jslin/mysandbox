
local helper = require 'helper'
local len_sq = helper.len_sq
local draw_hp = helper.draw_hp
local draw_level = helper.draw_level

local WIDTH = helper.WIDTH
local HEIGHT= helper.HEIGHT
local CENTER_P = helper.CENTER_P

local timer = {}

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

-- definition of yuusha

function yuusha.new(o)
  o = o or {} 
  o.body_   = res.yuusha_fighter_img
  o.x_      = 100
  o.y_      = HEIGHT/2
  o.rad_    = 0
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2 
  
  o.radius_sq_ = o.ox_ * o.oy_ / 2 -- it's "radius square", modified by some factor.
  
  o.color_  = {r=255, g=255, b=255, a=255}
  
  o.vx_     = 0
  o.vy_     = 0
  o.level_  = 1
  o.max_hp_ = 6
  o.hp_     = o.max_hp_
  o.state_  = 'normal'
  o.cooldown_ = 1
  o.timers  = {}
  
  setmetatable(o, {__index = yuusha})
  return o 
end

function yuusha:add_timer(o)
  self.timers[#self.timers+1] = timer.new(o)
end

function yuusha:update(dt)
  -- timers on itself
  local delete_timers = {}
  for _, v in ipairs(self.timers) do 
    v:update(dt)
    if v.loop_ < 0 then
      table.insert(delete_timers, v)
    end
  end
  self:cooldown(dt)
  
  if self.state_ == 'normal' then
    
    if #game.mob_bullets > 3 then
      local avgx = (game.mob_bullets[1].x_)
      local avgy = (game.mob_bullets[1].y_)
      local inc_pos = {x_ = avgx, y_ = avgy}
      if len_sq(self, inc_pos) < 22500 then -- ok, 150 is fairly close enough
        -- start to using evasive maneuvers.
        self.state_ = 'evade'
        self.color_.r = 0
        local length = math.sqrt(len_sq(self, inc_pos))
        local inc_nvec = { x_ = ((self.x_ - inc_pos.x_) / length), 
                           y_ = ((self.y_ - inc_pos.y_) / length) }
        self.vx_ = inc_nvec.y_ * 200
        self.vy_ = -inc_nvec.x_  * 200
        
        if (self.vx_ < 0 and self.x_ < 30) or (self.vx_ > 0 and self.x_ > WIDTH - 30) then
          self.vx_ = -self.vx_ 
        end
        
        if (self.vy_ < 0 and self.y_ < 30) or (self.vy_ > 0 and self.y_ > HEIGHT- 30) then 
          self.vy_ = -self.vy_
        end
        
        self:add_timer{ dur_ = 0.1,
          action_ = function(e)
            self.state_ = 'normal' -- set timer to set state back to normal
            self.color_.r = 255
            self.vx_ = 0
            self.vy_ = 0
          end
        }
      end
    end
  elseif self.state_ == 'evade' then
    
  end
  
  if #game.mobs > 0 and self:can_fire() then
    self:fire()
  end
  
  self.x_ = self.x_ + self.vx_ * dt
  self.y_ = self.y_ + self.vy_ * dt
  
  -- obj cleanup here
  for _, v in ipairs(delete_timers) do
    unordered_remove(self.timers, v)
  end
end

function yuusha:draw()
  draw_hp(self.hp_ / self.max_hp_, 
          self.body_:getWidth(), 
          self.x_ - self.ox_, 
          self.y_ - self.oy_)
  if self.hp_ > 0 then 
    draw_level(res.font1, self.level_, self.x_ - self.ox_, self.y_ - self.oy_)
  end
  love.graphics.setColor(self.color_.r, self.color_.g, self.color_.b, self.color_.a)
  love.graphics.draw(self.body_, self.x_, self.y_, self.rad_, self.facing_, 1, self.ox_, self.oy_)
end

function yuusha:can_fire()
  return self.cooldown_ == 0
end

function yuusha:cooldown(dt)
  if self.cooldown_ > 0 then
    self.cooldown_ = self.cooldown_ - dt -- in seconds 
    return 
  end
  self.cooldown_ = 0
end

function yuusha:fire()
  local b1 = bullet.new{ x_ = self.x_, y_ = self.y_ - 16, rad_ = rad, vx_ = 400 }
  b1.color_.b = 0
  local b2 = bullet.new{ x_ = self.x_, y_ = self.y_ + 16, rad_ = rad, vx_ = 400 }
  b2.color_.b = 0
  game:add_yuu_bullet(b1)
  game:add_yuu_bullet(b2)
  
  self.cooldown_ = self.cooldown_ + 0.16
end

function yuusha:levelup(n)
  self.level_  = self.level_ + n
  self.max_hp_ = self.max_hp_ + n*3
  self.hp_     = self.max_hp_ 
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
  
  o.radius_sq_ = o.ox_ * o.oy_ * 2 -- it's "radius square", modified by some factor.
  
  o.color_  = {r=255, g=255, b=255, a=255} 
  
  o.hp_     = 1
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
    
    if self.hp_ <= 0 then
      self.state_ = 'dying'
    end
      
  elseif self.state_ == 'dying' then
    self.state_ = 'dead' -- instant death for now (only 1 frame delay)
  elseif self.state_ == 'dead' then

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

function mob:is_dead()
  return self.state_ == 'dead'
end

function mob:is_dying_or_dead()
  return self:is_dying() or self:is_dead()
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
  
  -- will this slow down computer? seemed like ok.
  table.sort(self.mob_bullets, function(a, b)
    return len_sq(a, self.yuusha) < len_sq(b, self.yuusha)
  end)
  
  self.yuusha:update(dt)
  for _, v in ipairs(self.mobs) do
    v:update(dt, self.yuusha)
    
    -- remove too far away objects OR Actually DEAD objects, not dying 
    if v:is_dead() or len_sq(v, CENTER_P) > 500000 then -- approx. distance of 700
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
  
  -- handle collision test here after everybody updated
  for _, v in ipairs(self.mob_bullets) do 
    -- actually it's very dangerious, but I think I can take advantage of sorted bullet list here.
    if len_sq(self.yuusha, v) > self.yuusha.radius_sq_ then 
      break -- bullet past this one is all too far, break it 
    end 
    table.insert(delete_markers3, v) -- remove bullet and...
    self.yuusha.hp_ = self.yuusha.hp_ - 1   -- take damage
  end
  
  -- this is really going to be a problem. 
  for _, u in ipairs(self.mobs) do 
    if not u:is_dying_or_dead() then 
      for _, v in ipairs(self.yuu_bullets) do
        if not v.used_ and len_sq(u, v) < u.radius_sq_ then
          table.insert(delete_markers2, v)
          u.hp_ = 0 -- all mobs are 1 shot kill
          v.used_ = true
          break
        end
      end
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

function game:add_yuu_bullet(o)
  self.yuu_bullets[#self.yuu_bullets+1] = o
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
  elseif subtype == 5 then
    self.x_ = -50; self.y_ = 100; self.vx_ = 300; self.vy_ = 0
  elseif subtype == 6 then
    self.x_ = WIDTH+50; self.y_ = 100; self.vx_ = -300; self.vy_ = 0
  elseif subtype == 7 then
    self.x_ = -50; self.y_ = HEIGHT-100; self.vx_ = 300; self.vy_ = 0 
  elseif subtype == 8 then
    self.x_ = WIDTH+50; self.y_ = HEIGHT-100; self.vx_ = -300; self.vy_ = 0
  end
end

local function mtype1_move(self, dt)
  self.x_ = self.x_ + self.vx_ * dt
  self.y_ = self.y_ + self.vy_ * dt
end

local function mtype3(self, subtype) 
  if subtype % 2 == 0 then
    self.x_ = WIDTH; self.y_ = HEIGHT/2; self.vx_ = -200
  else
    self.x_ = 0; self.y_ = HEIGHT/2; self.vx_ = 200
  end
end

local function mtype2_move(mathfun, coef1, coef2, coef3)
  return function(self, dt)
    self.x_ = self.x_ + self.vx_ * dt
    self.y_ = mathfun((self.x_ / WIDTH) * math.pi * coef1 + coef2) * HEIGHT/2 * coef3 + HEIGHT/2
  end
end

function game:keyreleased(key)
  if key == 'z' then
    self:add_timer{ loop_ = 5, dur_ = 0.25,
      action_ = function()
        local m = mob.new()
        mtype1(m)
        m.move_function = mtype1_move
        self:addmob(m)  
      end
    }
  elseif key == 'x' then
    local subtype = math.floor(math.random()*8)+1
    self:add_timer{ loop_ = 5, dur_ = 0.25,
      action_ = function()
        local m = mob.new()
        mtype2(m, subtype)
        m.move_function = mtype1_move
        self:addmob(m)  
      end
    }
  elseif key == 'c' then
    local subtype = math.floor(math.random()*4)+1
    self:add_timer{ loop_ = 8, dur_ = 0.25,
      action_ = function(e)
        local m = mob.new()
        mtype3(m, subtype)
        if subtype <= 2 then
          m.move_function = mtype2_move(math.cos, 2, 0, 0.8)
        else
          m.move_function = mtype2_move(math.cos, 2, math.pi, 0.8)
        end
        m.cooldown_ = m.cooldown_ + (8 - e.loop_) * 0.2
        self:addmob(m) 
      end
    }    
  end
end

return game
