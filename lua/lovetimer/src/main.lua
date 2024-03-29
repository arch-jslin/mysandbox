local endtime_ = {year=2018, month=1, day=28, hour=16, min=0, sec=0}

local time_left_ = 0
local font1_ 
local font2_

function love.load()
  font1_ = love.graphics.setNewFont(72)
  font2_ = love.graphics.setNewFont(54)
end

function love.update(dt)
  time_left_ = os.time(endtime_) - os.time()
end

function love.draw()
  local sec = time_left_ % 60
  local min = math.floor(time_left_ / 60) % 60
  local hr  = math.floor(time_left_ / 60 / 60)
  local str = string.format("%02d:%02d:%02d\n", hr, min, sec)
  
  if time_left_ < 3600 then
    love.graphics.setColor(255, 64, 64, 255)
  elseif time_left_ < 7200 then
    love.graphics.setColor(255, 255, 32, 255)
  else
    love.graphics.setColor(255, 255, 255, 255)
  end
  
  love.graphics.setFont(font1_)
  love.graphics.printf(str, 300, 50, 0, 'center')
  
  -- love.graphics.setColor(255, 255, 255, 255)
  -- love.graphics.setFont(font2_)
  -- love.graphics.printf('Until Upload', 100, 150, 400, 'center')
  
  love.graphics.setNewFont(64)
  love.graphics.setColor(255, 64, 64, 255)
  love.graphics.printf('UPLOAD NOW', 50, 200, 500, 'center')
end