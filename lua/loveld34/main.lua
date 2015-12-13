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

-- array to hold collision messages
local logtext_ = {}

-- helpers

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
  
  for shape, delta in pairs(HC.collisions(self.shape)) do
    logtext_[#logtext_+1] = string.format("Hit! Separating vector = (%s,%s), object(%s)", delta.x, delta.y, self)
    
    bullets_to_be_deleted_[#bullets_to_be_deleted_ + 1] = self
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

local function targeted_fire(from, to)
  local dx = to.x - from.x
  local dy = to.y - from.y
  local length = math.sqrt(len_sq(from, to)) 
  local rad = math.atan2(dy, dx)
  local nx = dx / length
  local ny = dy / length
  
  local b = Bullet.new{ x = from.x, y = from.y, vx = 200*nx, vy = 200*ny }
  bullets_[#bullets_ + 1] = b
end

function love.load()
  math.randomseed(os.time())
  
  RES.bullet_img1 = love.graphics.newImage('bullet.png')
  
  you = {}
  you.rot  = 0
  you.size = 64
  you.base_size = 64
  you.scale_change = 1
  you.x = love.graphics.getWidth() / 2
  you.y = love.graphics.getHeight() / 2
  
  you.body = love.graphics.newImage('you.png')
  -- you.rect = HC.rectangle(you.x - you.size/2, you.y - you.size/2, you.size, you.size)
  
  you.rect = HC.polygon(you.x - you.size/2, you.y - you.size/2,
                        you.x - you.size/2, you.y + you.size/2,
                        you.x + you.size/2, you.y + you.size/2, 
                        you.x + you.size/2, you.y - you.size/2)
  
  you.rect:setRotation(you.rot)

  bullets_ = {}
  timers_  = {}
  
  timers_[#timers_ + 1] = Timer.new { dur = 0.3, loop = 999, 
    action = function()
      targeted_fire( {x = 0, y = CENTER_Y-you.size }, {x=1280, y=CENTER_Y-you.size} )
    end
  }
end

function love.update(dt)
  
  bullets_to_be_deleted_ = {} 
  timers_to_be_deleted_  = {}
  
  -- update inputs
  
  if key_left_ and key_right_ then
    local oldsz = you.size
    you.size = you.size + 1
    you.scale_change = you.size / oldsz
  elseif key_left_ then
    you.rot = you.rot - 0.05
    
    local oldsz = you.size
    you.size = you.size - 0.2
    you.scale_change = you.size / oldsz
  elseif key_right_ then
    you.rot = you.rot + 0.05
  
    local oldsz = you.size
    you.size = you.size - 0.2
    you.scale_change = you.size / oldsz
  else
    --
    local oldsz = you.size
    you.size = you.size - 0.33
    you.scale_change = you.size / oldsz
    --]]
    LOG("you.size %d", you.size)
  end
  
  -- update timers
  
  for _, t in ipairs(timers_) do
    t:update(dt)
  end
  
  -- update main actor
    
  you.rect:setRotation(you.rot)
  you.rect:scale(you.scale_change)
  you.scale_change = 1
  
  -- LOG("(%s,%s) (%s,%s) (%s,%s) (%s,%s)", you.rect._polygon:unpack())
  
  -- update bullets 
  for _, b in ipairs(bullets_) do
    b:update(dt)
  end
  
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
  
  love.graphics.draw(you.body, you.x, you.y, you.rot, scale, scale, you.base_size/2, you.base_size/2)
  
  -- draw bullets 
  for _, b in ipairs(bullets_) do
    b:draw()
  end
  
  love.graphics.setColor(64, 255, 128)
  --debug shape
  you.rect:draw('line')
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

function love.keypressed(k)
  if k == 'z' then
    key_left_ = true
  elseif k == 'x' then
    key_right_ = true
  end
end

function love.keyreleased(k)
  if k == 'z' then
    key_left_ = false
  elseif k == 'x' then
    key_right_ = false
  end
end  