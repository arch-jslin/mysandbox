local HC = require 'hardoncollider'

local RES = {}
local SCREEN_W = love.window.getWidth()
local SCREEN_H = love.window.getHeight()
local CENTER_X = SCREEN_W / 2
local CENTER_Y = SCREEN_H / 2

local key_left_  = false
local key_right_ = false

local you 
local bullets_
local bullets_to_be_deleted_

local timers_ 
local timers_to_be_deleted_

local gameover_

-- array to hold collision messages
local logtext_ = {}

-- helpers

local function random(n)
  return math.floor(math.random()*n)
end

local function LOG(str, ...)
  logtext_[#logtext_+1] = string.format(str, ...)
end

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

local function len_sq(o1, o2)
  local dx = o1.x - o2.x
  local dy = o1.y - o2.y
  return dx*dx + dy*dy
end

-- simple Timer class

local Timer = {}
function Timer.new(o)
  o = o or {}
  
  o.loop   = o.loop or 0
  o.dur    = o.dur or 1 -- in seconds
  o.time   = 0           -- in seconds
  o.action = o.action or nil
  
  setmetatable(o, {__index = Timer})
  return o
end

function Timer:update(dt)
  self.time = self.time + dt
  if self.time > self.dur then
    self.time = 0 
    self.loop = self.loop - 1
    self:action()
  end
  
  if self.loop < 0 then 
    timers_to_be_deleted_[#timers_to_be_deleted_ + 1] = self
  end
end

local function delay(sec, func)
  timers_[#timers_+1] = Timer.new { dur = sec, action = func }
end

-- some functions that relates to you

local function you_size_change(delta)
  local oldsz = you.size
  you.size = you.size + delta
  
  if you.size < 0 then 
    gameover_ = true
    you.size = 0.0001
    
    LOG("GAME OVER!")
    -- gameover timer cleanup
    for _, v in ipairs(timers_) do
      timers_to_be_deleted_[#timers_to_be_deleted_ + 1] = v
    end
    
  end
  
  you.scale_change = you.size / oldsz
  
  you.rect:scale(you.scale_change)
  you.scale_change = 1 
end

-- simple Bullet class

local Bullet = {}
function Bullet.new(o)
  o           = o or {}
  o.x         = o.x or 50
  o.y         = o.y or 50
  o.base_size = o.base_size or 8
  o.size      = o.size or 8
  o.body      = RES.bullet_img1
  o.shape     = HC.circle(0, 0, o.size)
  
  o.color     = {r=255, g=255, b=255, a=255} 
  
  o.vx        = o.vx or 0
  o.vy        = o.vy or 0
  
  setmetatable(o, {__index = Bullet})
  
  return o
end

function Bullet:update(dt)
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  
  self.shape:moveTo(self.x, self.y) 
  
  local dmg = 25
  if you.size > 220 then dmg = 32 
  elseif you.size > 440 then dmg = 45
  end
  
  for shape, delta in pairs(HC.collisions(self.shape)) do
    if shape == you.rect then -- make bullets only collide with you.rect
      logtext_[#logtext_+1] = string.format("Hit! Separating vector = (%s,%s), object(%s)", delta.x, delta.y, self)
      bullets_to_be_deleted_[#bullets_to_be_deleted_ + 1] = self
      
      you_size_change(-dmg) -- whatev', you is global, forget the argument thing
    end
  end
  
  if len_sq(you, self) > 1000000 then -- roughly 1000 in distance to the square
    logtext_[#logtext_+1] = string.format("object(%s) too far, self-removal", self)
    bullets_to_be_deleted_[#bullets_to_be_deleted_ + 1] = self
  end
end

function Bullet:draw()
  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
  love.graphics.draw(self.body,    -- ref to img
                     self.x,       -- x
                     self.y,       -- y
                     0,     -- orientation (radians)
                     self.size / self.base_size,             -- scale x
                     self.size / self.base_size,             -- scale y
                     self.size,      -- origin x
                     self.size)      -- origin y
end

local function targeted_fire(from, to, speed)
  local dx = to.x - from.x
  local dy = to.y - from.y
  local length = math.sqrt(len_sq(from, to)) 
  local rad = math.atan2(dy, dx)
  local nx = dx / length
  local ny = dy / length
  speed = speed or 300
  
  local b = Bullet.new{ x = from.x, y = from.y, vx = speed*nx, vy = speed*ny }
  bullets_[#bullets_ + 1] = b
end

-- level patterns

local function shoot_bullet_1(o)
  o          = o or {}
  o.time_gap = o.time_gap or 0.1
  o.times    = o.times or 1
  o.distance = o.distance or (you.size / 2) * 1.414  -- sz*sqrt(2) from the center
  o.from     = o.from or {x = 0, y = CENTER_Y - o.distance}
  o.to       = o.to   or {x = SCREEN_W, y = CENTER_Y - o.distance}
  o.speed    = o.speed or 300
  
  timers_[#timers_ + 1] = Timer.new { dur = o.time_gap, loop = o.times - 1, -- loop 0 means "it doesn't loop but will do once" 
    action = function()
      targeted_fire( o.from, o.to, o.speed )
    end
  }
end

local function pattern_hori()
  local distance = (you.size / 2) * 1.414
  shoot_bullet_1 { time_gap = 0.1, times = 3, 
                   from = { x = 0, y = CENTER_Y - distance },
                   to   = { x = SCREEN_W, y = CENTER_Y - distance } }
                 
  delay(2, function()
    shoot_bullet_1 { time_gap = 0.1, times = 3, 
                     from = { x = SCREEN_W, y = CENTER_Y + distance }, 
                     to   = { x = 0, y = CENTER_Y + distance } }
  end)
end

local function pattern_basic_random_endless()
  timers_[#timers_ + 1] = Timer.new { dur = 1.5, loop = 999, 
    action = function()
      local distance = (you.size / 2) * (1.41 + math.random()*(0.12 - (you.size/640)*0.5))
      local diag_offset = (you.size / 2) * (1.61 + math.random()*(0.15 - (you.size/640)*0.35))
      
      if key_left_ and key_right_ then
        distance = distance + (you.size/2) * 0.2
      end
      
      local roll = random(7)
      if roll == 0 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = 0, y = CENTER_Y - distance },
                         to   = { x = SCREEN_W, y = CENTER_Y - distance } }
      elseif roll == 1 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = SCREEN_W, y = CENTER_Y + distance }, 
                         to   = { x = 0, y = CENTER_Y + distance } }
      elseif roll == 2 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = CENTER_X - distance, y = 0 }, 
                         to   = { x = CENTER_X - distance, y = SCREEN_H } }
      elseif roll == 3 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = CENTER_X + distance, y = SCREEN_H }, 
                         to   = { x = CENTER_X + distance, y = 0 } }
      elseif roll == 4 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 300 * 1.4,                                 
                         from = { x = 0 + diag_offset, y = CENTER_Y - CENTER_X },           
                         to   = { x = SCREEN_W, y = CENTER_Y + CENTER_X - diag_offset } }   
      elseif roll == 5 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 300 * 1.4,       
                         from = { x = SCREEN_W - diag_offset, y = CENTER_Y + CENTER_X },
                         to   = { x = 0, y = CENTER_Y - CENTER_X + diag_offset } }
      elseif roll == 6 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 300 * 1.4, 
                         from = { x = 0, y = CENTER_Y + CENTER_X - diag_offset }, 
                         to   = { x = SCREEN_W - diag_offset, y = CENTER_Y - CENTER_X } }
      elseif roll == 7 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 300 * 1.4, 
                         from = { x = SCREEN_W, y = CENTER_Y - CENTER_X + diag_offset }, 
                         to   = { x = 0 + diag_offset, y = CENTER_Y + CENTER_X } }
      end
    end
  }
end

local function pattern_basic_random_endless2()
timers_[#timers_ + 1] = Timer.new { dur = 1.2, loop = 999, 
    action = function()
      local distance = (you.size / 2) * (1 + math.random()*(0.12 - (you.size/640)*1))
      local diag_offset = (you.size / 2) * (1.2 + math.random()*(0.15 - (you.size/640)*0.7))
      
      if key_left_ and key_right_ then
        distance = distance + (you.size/2) * 0.2
      end
      
      local roll = random(7)
      if roll == 0 then
        shoot_bullet_1 { time_gap = 0.1, times = 5, speed = 400,
                         from = { x = 0, y = CENTER_Y - distance },
                         to   = { x = SCREEN_W, y = CENTER_Y - distance } }
      elseif roll == 1 then
        shoot_bullet_1 { time_gap = 0.1, times = 5, speed = 400,
                         from = { x = SCREEN_W, y = CENTER_Y + distance }, 
                         to   = { x = 0, y = CENTER_Y + distance } }
      elseif roll == 2 then
        shoot_bullet_1 { time_gap = 0.1, times = 5, speed = 400,
                         from = { x = CENTER_X - distance, y = 0 }, 
                         to   = { x = CENTER_X - distance, y = SCREEN_H } }
      elseif roll == 3 then
        shoot_bullet_1 { time_gap = 0.1, times = 5, speed = 400,
                         from = { x = CENTER_X + distance, y = SCREEN_H }, 
                         to   = { x = CENTER_X + distance, y = 0 } }
      elseif roll == 4 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 550,                        
                         from = { x = 0 + diag_offset, y = CENTER_Y - CENTER_X },           
                         to   = { x = SCREEN_W, y = CENTER_Y + CENTER_X - diag_offset } }   
      elseif roll == 5 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 550,      
                         from = { x = SCREEN_W - diag_offset, y = CENTER_Y + CENTER_X },
                         to   = { x = 0, y = CENTER_Y - CENTER_X + diag_offset } }
      elseif roll == 6 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 550,
                         from = { x = 0, y = CENTER_Y + CENTER_X - diag_offset }, 
                         to   = { x = SCREEN_W - diag_offset, y = CENTER_Y - CENTER_X } }
      elseif roll == 7 then
        shoot_bullet_1 { time_gap = 0.07, times = 5, speed = 550,
                         from = { x = SCREEN_W, y = CENTER_Y - CENTER_X + diag_offset }, 
                         to   = { x = 0 + diag_offset, y = CENTER_Y + CENTER_X } }
      end
    end
  }
end


local function pattern_basic_random_endless3()
timers_[#timers_ + 1] = Timer.new { dur = 2, loop = 999, 
    action = function()
      local distance = (you.size / 2) * (1 + math.random()*(0.12 - (you.size/640)*1))
      local diag_offset = (you.size / 2) * (0.6 + math.random()*(0.15 - (you.size/640)*0.7))
      
      if key_left_ and key_right_ then
        distance = distance + (you.size/2) * 0.2
      end
      
      local roll = random(6)
      if roll == 0 then
        for i = 1, 10 do 
          shoot_bullet_1 { time_gap = 0.1, 
                           from = { x = 0 - i*20, y = CENTER_Y + CENTER_X - diag_offset - i*20 }, 
                           to   = { x = 0 - i*20 + 1500, y = CENTER_Y + CENTER_X - diag_offset - i*20 - 1500 } }
          --
          shoot_bullet_1 { time_gap = 0.1,
                           from = { x = SCREEN_W + i*20, y = CENTER_Y - CENTER_X + diag_offset + i*20 }, 
                           to   = { x = SCREEN_W + i*20 - 1500, y = CENTER_Y - CENTER_X + diag_offset + i*20 + 1500} }
          --
        end     
      elseif roll == 1 then
        for i = 1, 10 do
          shoot_bullet_1 { time_gap = 0.1,                                  
                           from = { x = 0 + diag_offset + i*20, y = CENTER_Y - CENTER_X - i*20 },           
                           to   = { x = 0 + diag_offset + i*20 + 1500, y = CENTER_Y - CENTER_X - i*20 + 1500} }   
          shoot_bullet_1 { time_gap = 0.1,        
                           from = { x = SCREEN_W - diag_offset - i*20, y = CENTER_Y + CENTER_X + i*20 },
                           to   = { x = SCREEN_W - diag_offset - i*20 - 1500, y = CENTER_Y + CENTER_X + i*20 - 1500} }
        end
      elseif roll == 2 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = 0, y = CENTER_Y - distance },
                         to   = { x = SCREEN_W, y = CENTER_Y - distance } }
      elseif roll == 3 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = SCREEN_W, y = CENTER_Y + distance }, 
                         to   = { x = 0, y = CENTER_Y + distance } }
      elseif roll == 4 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = CENTER_X - distance, y = 0 }, 
                         to   = { x = CENTER_X - distance, y = SCREEN_H } }
      elseif roll == 5 then
        shoot_bullet_1 { time_gap = 0.1, times = 5,
                         from = { x = CENTER_X + distance, y = SCREEN_H }, 
                         to   = { x = CENTER_X + distance, y = 0 } }
      end
    end
  }
end

-- end of level patterns

local function init(type)

  LOG("initing type %s", type)
  
  gameover_ = false

  you = {}
  you.type = type
  you.rot  = 0
  you.size = 64
  you.base_size = 64
  you.scale_change = 1
  you.x = love.graphics.getWidth() / 2
  you.y = love.graphics.getHeight() / 2
  
  if type == 1 then
    you.rect = HC.polygon(you.x - you.size/2, you.y - you.size/2,
                          you.x - you.size/2, you.y + you.size/2,
                          you.x + you.size/2, you.y + you.size/2, 
                          you.x + you.size/2, you.y - you.size/2)
  
    pattern_basic_random_endless()
  
  elseif type == 2 then
    you.rect = HC.polygon(you.x - you.size/2 + you.size*0.05, you.y + you.size/2 - you.size*0.13398 - you.size*0.08,
                          you.x + you.size/2 - you.size*0.05, you.y + you.size/2 - you.size*0.13398 - you.size*0.08,
                          you.x, you.y - you.size/2)
    
    pattern_basic_random_endless2()
    
  elseif type == 3 then
    you.rect = HC.polygon(you.x - you.size/3*2, you.y - you.size/4,
                          you.x - you.size/3*2, you.y + you.size/4,
                          you.x + you.size/3*2, you.y + you.size/4, 
                          you.x + you.size/3*2, you.y - you.size/4)
                        
    pattern_basic_random_endless3()
  end
  
  you.charge = 0
  you.rect:setRotation(you.rot)
  
end

function love.load()
  math.randomseed(os.time())
  
  RES.bullet_img1 = love.graphics.newImage('bullet.png')
  
  bullets_ = {}
  timers_  = {}
  
  init(1)
end

function love.update(dt)
  local speed_shrink = -1.5
  local speed_bounce = 1.8
  local speed_rotate_bounce = 0.9
  local speed_rotate_grow = 0.2
  local speed_grow   = 0.5
  local speed_rot    = 0.05
  
  if you.type == 2 then
    speed_shrink = -3
    speed_bounce = 4
    speed_rot = 0.066
  end
  
  if you.type == 3 then    
    speed_shrink = -3
    speed_bounce = 4
    speed_rotate_bounce = 2
    speed_rotate_grow = 0.2
    speed_grow   = 0.5
  end
  
  bullets_to_be_deleted_ = {} 
  timers_to_be_deleted_  = {}
  
  -- update inputs
  
  if not gameover_ then
  
    if key_left_ and key_right_ then
      you_size_change(speed_shrink)
      you.charge = you.charge + 1
      
      delayed_trigger = 0
    elseif key_left_ then
      
      delayed_trigger = delayed_trigger + 1
      
      if delayed_trigger > 1 then 
        you.rot = you.rot - speed_rot
        
        if you.charge > 0 then
          you.charge = you.charge - 1
          you_size_change(speed_rotate_bounce)
        else
          you_size_change(speed_rotate_grow)
        end
      end
    elseif key_right_ then
      
      delayed_trigger = delayed_trigger + 1
      
      if delayed_trigger > 1 then
        you.rot = you.rot + speed_rot
        
        if you.charge > 0 then
          you.charge = you.charge - 1
          you_size_change(speed_rotate_bounce)
        else
          you_size_change(speed_rotate_grow)
        end
      end
    else
      if you.charge > 0 then
        you.charge = you.charge - 1
        you_size_change(speed_bounce)
      else
        you_size_change(speed_grow)
      end
      
      delayed_trigger = 0
    end
  
    -- update timers
  
    for _, t in ipairs(timers_) do
      t:update(dt)
    end
  
  else
  
    -- do something? 

  end
  
  -- update bullets 
  for _, b in ipairs(bullets_) do
    b:update(dt) -- bullet collision will happen here, so you.rect size change should be after this
  end
  
  -- update main actor
    
  you.rect:setRotation(you.rot) 
  
  -- LOG("(%s,%s) (%s,%s) (%s,%s) (%s,%s)", you.rect._polygon:unpack())
  
  --debug: on screen log texts
  while #logtext_ > 40 do
      table.remove(logtext_, 1)
  end
  
  for _, v in ipairs(bullets_to_be_deleted_) do
    HC.remove(v.shape)
    unordered_remove(bullets_, v)
  end
  
  for _, v in ipairs(timers_to_be_deleted_) do
    unordered_remove(timers_, v)
  end
end

function love.draw()
  local scale = you.size / you.base_size
  
  --love.graphics.draw(you.body, you.x, you.y, you.rot, scale, scale, you.base_size/2, you.base_size/2)
  
  -- draw bullets 
  for _, b in ipairs(bullets_) do
    b:draw()
  end
  
  love.graphics.setColor(64, 255, 128)
  --debug shape
  --you.rect:draw('line')
  you.rect:draw('fill')
  love.graphics.setColor(255, 255, 255)
  
  --debug: on screen log texts
  if key_left_ and key_right_ then
    love.graphics.print('both', 200, 180)  
  elseif key_left_ then
    love.graphics.print('left', 200, 200)
  elseif key_right_ then
    love.graphics.print('right', 250, 200)
  end
  
  -- print messages
  for i = 1,#logtext_ do
    love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
    love.graphics.print(logtext_[#logtext_ - (i-1)], 10, i * 15)
  end
  
  love.graphics.setColor(255, 255, 255, 255) -- reset white
end

local function cleanup()
  
  LOG("Cleaning up")
  
  HC.remove(you.rect)
  
  for _, v in ipairs(bullets_) do
    bullets_to_be_deleted_[#bullets_to_be_deleted_ + 1] = v
  end
  
  for _, v in ipairs(timers_) do
    timers_to_be_deleted_[#timers_to_be_deleted_ + 1] = v
  end

  for _, v in ipairs(bullets_to_be_deleted_) do
    HC.remove(v.shape)
    unordered_remove(bullets_, v)
  end
  
  for _, v in ipairs(timers_to_be_deleted_) do
    unordered_remove(timers_, v)
  end
end

function love.keypressed(k)
  if k == 'z' then
    key_left_ = true
  elseif k == 'x' then
    key_right_ = true
  
  elseif k == '1' then
    cleanup()
    init(1)
  elseif k == '2' then
    cleanup()
    init(2)
  elseif k == '3' then
    cleanup()
    init(3)
  end
end

function love.keyreleased(k)
  if k == 'z' then
    key_left_ = false
  elseif k == 'x' then
    key_right_ = false
  end
end  