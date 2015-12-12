local key_left_  = false
local key_right_ = false

local you 

local bullet

function love.load()
  math.randomseed(os.time())

  you = {}
  you.rot  = 0
  you.size = 64
  you.base_size = 64
  you.x = love.graphics.getWidth() / 2
  you.y = love.graphics.getHeight() / 2
  
  you.body = love.graphics.newImage('you.png')
  
  bullet = {}
  bullet.body = love.graphics.newImage('bullet.png')
end

function love.update(dt)
  
end

function love.draw()
  local scale = you.size / you.base_size
  
  love.graphics.draw(you.body, you.x, you.y, you.rot, scale, scale, you.base_size/2, you.base_size/2)
  
  love.graphics.draw(bullet.body, 50, 50, 0, .5, .5)
  
  if key_left_ and key_right_ then
    love.graphics.print('both', 200, 180)  
    you.size = you.size + 1
  elseif key_left_ then
    love.graphics.print('left', 200, 200)
    you.rot = you.rot - 0.05
  elseif key_right_ then
    love.graphics.print('right', 250, 200)
    you.rot = you.rot + 0.05
  end
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