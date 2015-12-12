local HC = require 'hardoncollider'

local key_left_  = false
local key_right_ = false

local you 

local bullet

-- array to hold collision messages
local logtext_ = {}

function love.load()
  math.randomseed(os.time())
  
  you = {}
  you.rot  = 0
  you.size = 64
  you.base_size = 64
  you.x = love.graphics.getWidth() / 2
  you.y = love.graphics.getHeight() / 2
  
  you.body = love.graphics.newImage('you.png')
  you.rect = HC.rectangle(you.x - you.size/2, you.y - you.size/2, you.size, you.size)
  you.rect:setRotation(you.rot)

  bullet = {}
  bullet.x = 50
  bullet.y = 50
  bullet.size = 8
  bullet.body = love.graphics.newImage('bullet.png')
  bullet.shape = HC.circle(0, 0, 8)
end

function love.update(dt)
  if key_left_ and key_right_ then
    you.size = you.size + 1
  elseif key_left_ then
    you.rot = you.rot - 0.05
  elseif key_right_ then
    you.rot = you.rot + 0.05
  end
  
  bullet.x, bullet.y = love.mouse.getPosition()
  bullet.shape:moveTo(bullet.x, bullet.y)
  
  you.rect:setRotation(you.rot)
  you.rect:scale(you.size / you.base_size)
  
  -- collision
  for shape, delta in pairs(HC.collisions(bullet.shape)) do
    logtext_[#logtext_+1] = string.format("Colliding. Separating vector = (%s,%s)", delta.x, delta.y)
  end
  
  --debug: on screen log texts
  while #logtext_ > 40 do
      table.remove(logtext_, 1)
  end
end

function love.draw()
  local scale = you.size / you.base_size
  
  love.graphics.draw(you.body, you.x, you.y, you.rot, scale, scale, you.base_size/2, you.base_size/2)
  love.graphics.draw(bullet.body, bullet.x, bullet.y, 0, 1, 1, bullet.size, bullet.size)
  
  love.graphics.setColor(64, 255, 128)
  --debug shape
  you.rect:draw('line')
  bullet.shape:draw('line')
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