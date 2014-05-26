
local names_ = { 'Team_A', 'Team_B', 'Team_C', 'Team_D', 'Team_E', 'Team_F', 'Team_G' }
local font_

local index_last_ = 1
local index_next_ = 2

local x_last_ =  400
local x_next_ = -400

local vx_ = 0
local ax_ = 0

function love.load()
  font_ = love.graphics.newFont('msjhbd.ttf', 96)
  love.graphics.setFont(font_)
end

function love.update(dt)
  vx_ = vx_ + ax_ 
  if vx_ > 6000 then 
    vx_ = 6000 
  elseif vx_ < 0 then
    vx_ = 0
    if x_last_ < 800 then
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
  end

  x_last_ = x_last_ + (vx_ * dt)
  x_next_ = x_next_ + (vx_ * dt)
  
  if x_last_ > 1200 then 
    index_last_ = index_next_
    index_next_ = index_next_ + 1
    if index_next_ > #names_ then index_next_ = 1 end
    
    x_last_ = x_next_
    x_next_ = -400
  end
end

function love.draw()  
  love.graphics.printf(names_[index_last_], x_last_, 100, 0, 'center')
  love.graphics.printf(names_[index_next_], x_next_, 100, 0, 'center')
end

local flag_ = 0

function love.mousepressed( x, y, button )
  if button == 'l' then
    if flag_ == 0 then
      flag_ = 1
      ax_ = 2
    else 
      flag_ = 0
      ax_ = -2
    end
  end
end

