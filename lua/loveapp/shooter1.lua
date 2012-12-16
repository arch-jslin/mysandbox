
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
local boss = {}
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

-- mob movement function for game object to use

local function mtype1(self) -- come in randomly
  local tmp1 = math.random()-0.5
  local tmp2 = math.random()-0.5
  tmp1 = math.abs(tmp1) / tmp1 -- either 1 or -1
  tmp2 = math.abs(tmp2) / tmp2 -- either 1 or -1
  self.vx_ = ((math.random()/2)+0.5)*tmp1*200
  self.vy_ = ((math.random()/2)+0.5)*tmp2*200
  
  self.x_ = self.vx_ < 0 and WIDTH + math.random()*50 or 0 - math.random()*50
  self.y_ = self.vy_ < 0 and HEIGHT/2 + math.random()*HEIGHT or HEIGHT/2 - math.random()*HEIGHT
end

local function mtype2(self, subtype) -- diagonal
  subtype = subtype or 1
  if subtype == 1 then
    self.x_ = WIDTH;    self.y_ = -50; self.vx_ = -200; self.vy_ = 200
  elseif subtype == 2 then
    self.x_ = WIDTH;    self.y_ = HEIGHT+50; self.vx_ = -200; self.vy_ = -200
  elseif subtype == 3 then
    self.x_ = WIDTH+50; self.y_ = 100; self.vx_ = -300; self.vy_ = 0
  elseif subtype == 4 then
    self.x_ = WIDTH+50; self.y_ = HEIGHT-100; self.vx_ = -300; self.vy_ = 0
  end
  --self.x_ = 0;        self.y_ = 50;         self.vx_ = 200; self.vy_ = 200
  --self.x_ = 0;        self.y_ = HEIGHT+50;  self.vx_ = 200; self.vy_ = -200
  --self.x_ = -50;      self.y_ = 100;        self.vx_ = 300; self.vy_ = 0
  --self.x_ = -50;      self.y_ = HEIGHT-100; self.vx_ = 300; self.vy_ = 0 
end

local function mtype1_move(self, dt)
  self.x_ = self.x_ + self.vx_ * dt
  self.y_ = self.y_ + self.vy_ * dt
end

local function mtype3(self, subtype) 
--  if subtype % 2 == 0 then
--    self.x_ = WIDTH; self.y_ = HEIGHT/2; self.vx_ = -200
--  else
    self.x_ = 0; self.y_ = HEIGHT/2; self.vx_ = 200
--  end
end

local function mtype2_move(mathfun, coef1, coef2, coef3)
  return function(self, dt)
    self.x_ = self.x_ + self.vx_ * dt
    self.y_ = mathfun((self.x_ / WIDTH) * math.pi * coef1 + coef2) * HEIGHT/2 * coef3 + HEIGHT/2
  end
end

local function phase1_event(self, key)
  if key == 'z' and self.unit_resource >= 10 and self.can_use_formation1 then
    local function formation1()
      local m = mob.new()
      mtype1(m)
      m.move_function = mtype1_move
      self:addmob(m)
    end
    formation1() -- directly call here first
    self:add_timer{ loop_ = 4, dur_ = 0.25, action_ = formation1 }
    
    self.can_use_formation1 = false
    self.unit_resource = self.unit_resource - 10
    self:add_timer{ dur_ = 3,
      action_ = function() self.can_use_formation1 = true end
    }
    
  elseif key == 'x' and self.unit_resource >= 5 and self.can_use_formation2 then
    local subtype = math.floor(math.random()*4)+1
    local function formation2()
      local m = mob.new()
      mtype2(m, subtype)
      m.move_function = mtype1_move
      self:addmob(m)  
    end
    formation2() -- directly call here first
    self:add_timer{ loop_ = 4, dur_ = 0.25, action_ = formation2 }
    
    self.can_use_formation2 = false
    self.unit_resource = self.unit_resource - 5
    self:add_timer{ dur_ = 1.5,
      action_ = function() self.can_use_formation2 = true end
    }
    
  elseif key == 'c' and self.unit_resource >= 5 and self.can_use_formation2 then
    local subtype = math.floor(math.random()*2)+1
    local function formation3(e)
      local m = mob.new()
      mtype3(m, subtype)
      if subtype == 1 then
        m.move_function = mtype2_move(math.cos, 2, 0, 0.8)
      else
        m.move_function = mtype2_move(math.cos, 2, math.pi, 0.8)
      end
      m.cooldown_ = m.cooldown_ + (8 - e.loop_) * 0.2
      self:addmob(m)     
    end
    formation3({loop_ = 8}) -- directly call here first
    self:add_timer{ loop_ = 7, dur_ = 0.25, action_ = formation3 }   
    
    self.can_use_formation2 = false
    self.unit_resource = self.unit_resource - 5
    self:add_timer{ dur_ = 1.5,
      action_ = function() self.can_use_formation2 = true end
    }
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
  self.state  = 'cut1'
  self.key_released_impl = nil
  
  self.unit_resource = 200
  self.can_use_formation1 = true
  self.can_use_formation2 = true
  self.can_use_formation3 = true
  
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

-- definition of boss

function boss.new(o)
  o = o or {} 
  o.body_   = res.boss_img
  o.x_      = WIDTH + 275
  o.y_      = HEIGHT/2
  o.rad_    = 0
  o.facing_ = o.facing_ or 1
  o.ox_     = o.body_:getWidth()/2 
  o.oy_     = o.body_:getHeight()/2 
  
  o.radius_sq_ = o.ox_ * o.oy_ / 1.3 -- it's "radius square", modified by some factor.
  
  o.color_  = {r=255, g=255, b=255, a=255}
  
  o.vx_     = 0
  o.vy_     = 0
  o.max_hp_ = 500
  o.hp_     = 1
  o.state_  = 'normal'
  o.cooldown_normal_ = 0
  o.cooldown_wave_   = 1
  o.timers  = {}
  
  setmetatable(o, {__index = boss})
  return o 
end

function boss:add_timer(o)
  self.timers[#self.timers+1] = timer.new(o)
end

function boss:update(dt)
  -- timers on itself
  local delete_timers = {}
  for _, v in ipairs(self.timers) do 
    v:update(dt)
    if v.loop_ < 0 then
      table.insert(delete_timers, v)
    end
  end
  self:cooldown(dt)
  
  if love.mouse.isDown('l') and self:can_fire_normal() then
    self:fire_normal({x_ = love.mouse.getX(),
                      y_ = love.mouse.getY()})
  end
end

function boss:draw()
  draw_hp(self.hp_ / self.max_hp_, 
          WIDTH - 40, 
          20, 
          20,
          12)
        
  love.graphics.setColor(self.color_.r, self.color_.g, self.color_.b, self.color_.a)
  love.graphics.draw(self.body_, self.x_, self.y_, self.rad_, self.facing_, 1, self.ox_, self.oy_)
end

function boss:cooldown(dt)
  if self.cooldown_normal_ > 0 then
    self.cooldown_normal_ = self.cooldown_normal_ - dt -- in seconds 
  else
    self.cooldown_normal_ = 0
  end
  if self.cooldown_wave_ > 0 then
    self.cooldown_wave_ = self.cooldown_wave_ - dt -- in seconds 
  else
    self.cooldown_wave_ = 0
  end
end

function boss:can_fire_normal()
  return self.cooldown_normal_ == 0
end

function boss:can_fire_wave()
  return self.cooldown_wave_ == 0
end

local function targeted_fire(from, to)
  local dx = to.x_ - from.x_
  local dy = to.y_ - from.y_
  local length = math.sqrt(len_sq(from, to)) 
  local rad = math.atan2(dy, dx)
  local nx = dx / length
  local ny = dy / length
  
  local b = bullet.new{ x_ = from.x_, y_ = from.y_, rad_ = rad, vx_ = 100*nx, vy_ = 100*ny }
  game:add_mob_bullet(b)
end

function boss:fire_normal(target)
  targeted_fire({x_ = self.x_ - 100, y_ = self.y_ - 150}, target)
  targeted_fire({x_ = self.x_ - 100, y_ = self.y_ + 150}, target)
  self.cooldown_normal_ = self.cooldown_normal_ + 0.4
end

function boss:fire_wave()
  if self:can_fire_wave() then -- hmm... asymmetric condition, bad. let it be for now.
    for rad = math.pi * 0.6, math.pi * 1.4, 0.1 do    
      local nx = math.cos(rad)
      local ny = math.sin(rad)
      local b = bullet.new{ x_ = self.x_ - 100, y_ = self.y_, rad_ = rad, vx_ = 100*nx, vy_ = 100*ny }
      game:add_mob_bullet(b)
    end
    self.cooldown_wave_ = self.cooldown_wave_ + 2.4
  end
end

function boss:is_dying()
  return self.state_ == 'dying'
end

function boss:is_dead()
  return self.state_ == 'dead'
end

function boss:is_dying_or_dead()
  return self:is_dying() or self:is_dead()
end

local function phase2_event(self, key)
  if key == 'z' then
    self.mobs[1]:fire_wave() -- has to be boss in phase2
  end
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
    
    if #game.mob_bullets > 0 then
      local avgx, avgy, inc_pos
      local length
      local inc_nvec
      local abs_degree = 999
      local i = 1
      
      local alarm_range_sq = game.state == 'phase2' and 10000 or 22500
      local alarm_degree = game.state == 'phase2' and 45 or 70
     
      repeat
        avgx = (game.mob_bullets[i].x_)
        avgy = (game.mob_bullets[i].y_)
        inc_pos = {x_ = avgx, y_ = avgy}
        length = math.sqrt(len_sq(self, inc_pos))
        inc_nvec = { x_ = ((self.x_ - inc_pos.x_) / length), 
                     y_ = ((self.y_ - inc_pos.y_) / length) }

        local deg_inc = ((math.atan2(self.y_ - inc_pos.y_, self.x_ - inc_pos.x_)) * 180/math.pi) 
        local deg_vec = ((math.atan2(game.mob_bullets[i].vy_, game.mob_bullets[i].vx_)) * 180/math.pi) 
        abs_degree = math.abs(deg_inc - deg_vec)
        if abs_degree > 180 then abs_degree = 360 - abs_degree end -- round the degree
        i = i + 1
      until i > #game.mob_bullets or len_sq(self, inc_pos) >= alarm_range_sq or abs_degree < alarm_degree

      if len_sq(self, inc_pos) < alarm_range_sq then 
        game.mob_bullets[i-1].color_.g = 0
        -- start to using evasive maneuvers.
        self.state_ = 'evade'
        self.color_.r = 0
      
        if game.state == 'phase2' then
          if self.evade_down_ then 
--            self.vx_ = inc_nvec.y_ * 140   -- (x, y) -> (y, -x) this will go clockwise 
--            self.vy_ = -inc_nvec.x_ * 140  -- suitable when y < HEIGHT/2
            self.vx_ = game.mob_bullets[i-1].vy_ * 1.5
            self.vy_ = -game.mob_bullets[i-1].vx_ * 1.5
          else
--            self.vx_ = -inc_nvec.y_ * 140   -- (x, y) -> (-y, x) this will go counter clockwise
--            self.vy_ = inc_nvec.x_ * 140
            self.vx_ = -game.mob_bullets[i-1].vy_ * 1.5
            self.vy_ = game.mob_bullets[i-1].vx_ * 1.5
          end
        elseif game.state == 'phase1' then
          self.vx_ = inc_nvec.y_ * 150   -- (x, y) -> (y, -x) this will go clockwise 
          self.vy_ = -inc_nvec.x_ * 150  
--          self.vx_ = game.mob_bullets[i-1].vy_ * 1.5
--          self.vy_ = -game.mob_bullets[i-1].vx_ * 1.5
        end
        
        local front_border = game.state == 'phase2' and WIDTH - 250 or WIDTH - 30
        
        if (self.vx_ < 0 and self.x_ < 30) or (self.vx_ > 0 and self.x_ > front_border) then
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
  
  -- this is hack
  if not self.evade_down_ and self.y_ < 100 then
    self.evade_down_ = true
  elseif self.evade_down_ and self.y_ > HEIGHT - 100 then
    self.evade_down_ = false
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
  o.cooldown_ = 0.5 -- do not shoot for the first half second
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
  
  for _, v in ipairs(self.timers) do 
    v:update(dt)
    if v.loop_ < 0 then
      table.insert(delete_timers, v)
    end
  end
  
  if self.state == 'phase1' or self.state == 'phase2' then
    local delete_markers1 = {}
    local delete_markers2 = {}
    local delete_markers3 = {}
    
    -- will this slow down computer? seemed like ok.
    table.sort(self.mob_bullets, function(a, b)
      return len_sq(a, self.yuusha) < len_sq(b, self.yuusha)
    end)
    
    self.yuusha:update(dt)
    
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
    
    -- handle yuusha part collision test
    for _, v in ipairs(self.mob_bullets) do 
      -- actually it's very dangerious, but I think I can take advantage of sorted bullet list here.
      if len_sq(self.yuusha, v) > self.yuusha.radius_sq_ then 
        break -- bullet past this one is all too far, break it 
      end 
      table.insert(delete_markers3, v) -- remove bullet and...
      self.yuusha.hp_ = self.yuusha.hp_ - 1   -- take damage
    end
    
    -- handle "bad guy" part collision test
    for _, v in ipairs(self.mobs) do
      v:update(dt, self.yuusha)
      
      -- remove too far away objects OR Actually DEAD objects, not dying 
      if v:is_dead() or len_sq(v, CENTER_P) > 500000 then -- approx. distance of 700
        table.insert(delete_markers1, v) 
      end
    end
    -- this is really going to be a problem. 
    for _, u in ipairs(self.mobs) do 
      if not u:is_dying_or_dead() then 
        for _, v in ipairs(self.yuu_bullets) do
          if not v.used_ and len_sq(u, v) < u.radius_sq_ then
            table.insert(delete_markers2, v)
            u.hp_ = u.hp_ - 1 
            v.used_ = true
            break
          end
        end
      end
    end
    
    -- obj cleanup here
    for _, v in ipairs(delete_markers1) do
      unordered_remove(self.mobs, v)
    end
    for _, v in ipairs(delete_markers2) do
      unordered_remove(self.yuu_bullets, v)
    end
    for _, v in ipairs(delete_markers3) do
      unordered_remove(self.mob_bullets, v)
    end
    
    if self.unit_resource == 0 and 
       #self.mob_bullets == 0 and #self.yuu_bullets == 0 and #self.mobs == 0 then
      self.state = 'cut2'
      self:addmob( boss.new() ) -- add only mob which is boss when change game state
    end
    
  elseif self.state == 'cut1' then
    self.state = 'phase1' -- TEST: change to phase1 instantly for now 
    self.keyreleased_impl = phase1_event
  
  elseif self.state == 'cut2' then
    local boss = self.mobs[1]
    boss.x_ = boss.x_ - 100 * dt
    boss.hp_ = boss.hp_ + (boss.max_hp_ - boss.hp_) / 20
    
    local dx = 50 - self.yuusha.x_
    local dy = HEIGHT/2 - self.yuusha.y_
    self.yuusha.x_ = self.yuusha.x_ + dx*dt
    self.yuusha.y_ = self.yuusha.y_ + dy*dt
    
    if boss.x_ <= WIDTH then
      self.state = 'phase2'
      self.keyreleased_impl = phase2_event
    end
  end -- end of phase condition scope
  
  for _, v in ipairs(delete_timers) do
    unordered_remove(self.timers, v)
  end
  
  -- after update we sort the objs table to prepare for ordered drawing
  table.sort(self.mobs, function(a, b)
    return a.x_ < b.x_
  end)  
end

function game:draw() 
  for _, v in ipairs(self.mobs) do
    v:draw()
  end
  for _, v in ipairs(self.yuu_bullets) do
    v:draw()
  end
  for _, v in ipairs(self.mob_bullets) do 
    v:draw()
  end
  self.yuusha:draw() 
  
  -- Some info & UI drawing
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Unit Resource: "..self.unit_resource, WIDTH/2-50, HEIGHT-20)
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

function game:keyreleased(key)
  self.keyreleased_impl(self, key)
end

return game
