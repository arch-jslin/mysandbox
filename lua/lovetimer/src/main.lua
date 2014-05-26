local endtime_ = {year=2014, month=1, day=26, hour=17, min=00, sec=0}

local time_left_ = 0

function love.load()
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
    love.graphics.setColor(255, 0, 0, 255)
  elseif time_left_ < 7200 then
    love.graphics.setColor(255, 255, 0, 255)
  else
    love.graphics.setColor(255, 255, 255, 255)
  end
  
  love.graphics.setNewFont(96)
  love.graphics.printf(str, 400, 100, 0, 'center')
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setNewFont(80)
  love.graphics.printf('Until Final Demo', 0, 200, 800, 'center')
  
  love.graphics.setNewFont(64)
  love.graphics.printf('UPLOAD the game NOW', 0, 300, 800, 'center')
end