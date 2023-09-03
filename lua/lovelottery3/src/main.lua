
local names_ = { 'C', 'D', 'E' }

local font_

local index_last_ = 1
local index_next_ = 2

local CENTER_X = love.graphics.getWidth() / 2
local CENTER_Y = love.graphics.getHeight() / 2
local R = ((CENTER_X + CENTER_Y) / 2) - 40

local degree_ = 0
local fontsize_big_ = 96

local v_deg_ = 0
local a_deg_ = 0
local flag_  = 0

-- big resources
local pin_img_
local beep_

function love.load()
  font_ = love.graphics.setNewFont(fontsize_big_)
  love.graphics.setFont(font_)
  
  pin_img_ = love.graphics.newImage('block.png')
  beep_ = love.audio.newSource('Blip_Select3.wav', 'static')
  beep_:setVolume(0.3) 
end

function love.update(dt)
  v_deg_ = v_deg_ + a_deg_ 
  if v_deg_ > 2000 then 
    v_deg_ = 2000 
  elseif v_deg_ > 0 and v_deg_ < 180 and flag_ == 0 then
    a_deg_ = -1
  elseif v_deg_ < 0 then
    v_deg_ = 0
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

  local delta_degree = v_deg_* dt
  degree_ = degree_ + delta_degree
  
  --[[if progress_x_ > 800 then 
    index_last_ = index_next_
    index_next_ = index_next_ + 1
    if index_next_ > #names_ then index_next_ = 1 end
    
    progress_x_ = 0
    x_last_ = x_next_
    x_next_ = -400
  end
  --]]
end

--[[
local function draw_bar(bar_percent, total_len, x, y, thickness)
  thickness = thickness or 12
  if bar_percent <= 0 then return end
  love.graphics.setColor(64, 64, 64, 255)
  love.graphics.setLineWidth(thickness)
  love.graphics.line(x, y-5, x+total_len, y-5)
  love.graphics.setColor(100, 255, 100, 255)
  love.graphics.setLineWidth(thickness-2)
  love.graphics.line(x+1, y-5, x+((total_len-2)*bar_percent), y-5)
end]]

local function get_clock_position(n)
  local nth_degree = ((360 / #names_) * (n-1)) - 90
  local radian = nth_degree * math.pi / 180
  return CENTER_X + R*math.cos(radian), CENTER_Y + R*math.sin(radian)
end

local function draw_pin()
  local draw_degree = degree_ - 90
  local radian = draw_degree * math.pi / 180
  love.graphics.draw(pin_img_, CENTER_X, CENTER_Y, radian, 8, 1, 0, pin_img_:getHeight()/2)
end

local function is_pin_in_the_slice_of(n)
  local text_center_offset_degree = (360 / #names_) / 2
  local from_degree = ((360 / #names_) * (n-1))
  local to_degree   = ((360 / #names_) * (n))
  local clamped_degree = (degree_+ text_center_offset_degree) % 360 
  if clamped_degree >= from_degree and clamped_degree < to_degree then 
    return true
  end
  return false 
end  

local function draw_clockwise()
  for i = 1, #names_ do
    local x, y = get_clock_position(i)
    if is_pin_in_the_slice_of(i) then 
      love.graphics.setColor(64, 255, 64, 255)
      --audio here
      index_last_ = index_next_
      index_next_ = i
      if index_last_ ~= index_next_ then
        beep_:play()
      end
    end
    love.graphics.printf(names_[i], x, y - (fontsize_big_/2), 0, 'center')
    love.graphics.setColor(255, 255, 255, 255)
  end
end

function love.draw()  
  draw_pin()
  draw_clockwise()
end

function love.mousepressed( x, y, button )
  if button == 'l' then
    if flag_ == 0 then
      flag_ = 1
      a_deg_ = 10
    else 
      flag_ = 0
      a_deg_ = -5
    end
  end
end

