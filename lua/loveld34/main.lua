local HC = require 'hardoncollider'

local RES = {}

local key_left_  = false
local key_right_ = false

local you 
local bullets_

local debugbullet_

-- array to hold collision messages
local logtext_ = {}

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
  
  for shape, delta in pairs(HC.collisions(self.shape)) do
    logtext_[#logtext_+1] = string.format("Hit! Separating vector = (%s,%s)", delta.x, delta.y)
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
  you.rect = HC.rectangle(you.x - you.size/2, you.y - you.size/2, you.size, you.size)
  you.rect:setRotation(you.rot)

  bullets_ = {}
  
  debugbullet_ = Bullet.new { x=50, y=50 } 
end

function love.update(dt)
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
    local oldsz = you.size
    you.size = you.size - 0.33
    you.scale_change = you.size / oldsz
  end
    
  you.rect:setRotation(you.rot)
  you.rect:scale(you.scale_change)
  you.scale_change = 1
  
  debugbullet_.x, debugbullet_.y = love.mouse.getPosition() --debug
  debugbullet_.shape:moveTo(debugbullet_.x, debugbullet_.y) --debug
  debugbullet_:update(dt)
  
  --debug: on screen log texts
  while #logtext_ > 40 do
      table.remove(logtext_, 1)
  end
end

function love.draw()
  local scale = you.size / you.base_size
  
  love.graphics.draw(you.body, you.x, you.y, you.rot, scale, scale, you.base_size/2, you.base_size/2)
  debugbullet_:draw()
  
  love.graphics.setColor(64, 255, 128)
  --debug shape
  you.rect:draw('line')
  debugbullet_.shape:draw('line')
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