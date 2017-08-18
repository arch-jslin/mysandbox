
local names_ = { 'Team_A', 'Team_D', 'Team_E', 'Team_F', 'Team_G', 'Team_H' }

local font_

local index_last_ = 1
local index_next_ = 2

local x_last_ =  400
--local x_next_ = -400

local progress_x_ = 0

local vx_ = 0
local ax_ = 0

function love.load()
  font_ = love.graphics.setNewFont(96)
  love.graphics.setFont(font_)
end

function love.update(dt)
  vx_ = vx_ + ax_ 
  if vx_ > 6000 then 
    vx_ = 6000 
  elseif vx_ < 0 then
    vx_ = 0
    --[[if x_last_ < 800 then
      x_last_ = 400
      x_next_ = -400
    end
    if x_next_ > 0 then
      index_last_ = index_next_ 
      index_next_ = index_next_ + 1
      if index_next_ > #names_ then index_next_ = 1 end
      
      x_last_ = 400 
      x_next_ = -400
    end
    --]]
  end

  local dx = vx_* dt
  progress_x_ = progress_x_ + dx
  --x_last_ = x_last_ + dx
  --x_next_ = x_next_ + dx
  
  --if x_last_ > 1200 then 
  if progress_x_ > 800 then 
    index_last_ = index_next_
    index_next_ = index_next_ + 1
    if index_next_ > #names_ then index_next_ = 1 end
    
    progress_x_ = 0
    --[[x_last_ = x_next_
    x_next_ = -400
    ]]--
  end
end

local function draw_bar(bar_percent, total_len, x, y, thickness)
  thickness = thickness or 12
  if bar_percent <= 0 then return end
  love.graphics.setColor(64, 64, 64, 255)
  love.graphics.setLineWidth(thickness)
  love.graphics.line(x, y-5, x+total_len, y-5)
  love.graphics.setColor(100, 255, 100, 255)
  love.graphics.setLineWidth(thickness-2)
  love.graphics.line(x+1, y-5, x+((total_len-2)*bar_percent), y-5)
end

function love.draw()  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf(names_[index_last_], x_last_, 100, 0, 'center')
  --love.graphics.printf(names_[index_next_], x_next_, 100, 0, 'center')
  
  draw_bar((progress_x_) / 800, 800, 0, 400)
end

local flag_ = 0

function love.mousepressed( x, y, button )
  if button == 'l' then
    if flag_ == 0 then
      flag_ = 1
      ax_ = 20
    else 
      flag_ = 0
      ax_ = -20
    end
  end
end

