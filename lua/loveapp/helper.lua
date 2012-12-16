
local function len_sq(o1, o2)
  local dx = o1.x_ - o2.x_
  local dy = o1.y_ - o2.y_
  return dx*dx + dy*dy
end

local function draw_hp(hp_percent, total_len, x, y, thick)
  thickness = thickness or 6
  if hp_percent <= 0 then return end
  love.graphics.setColor(255, 50, 50, 255)
  love.graphics.setLine(thickness)
  love.graphics.line(x, y-5, x+total_len, y-5)
  love.graphics.setColor(100, 255, 100, 255)
  love.graphics.setLine(thickness-2)
  love.graphics.line(x+1, y-5, x+((total_len-2)*hp_percent), y-5)
end

local function draw_level(font, level, x, y)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(font)
  love.graphics.print("Lv "..level, x, y - 25)
end

local WIDTH = love.graphics.getWidth()
local HEIGHT= love.graphics.getHeight()
local CENTER_P = {x_ = WIDTH/2, y_ = HEIGHT/2}

return {
  len_sq = len_sq,
  draw_hp = draw_hp,
  draw_level = draw_level,
  WIDTH = WIDTH,
  HEIGHT= HEIGHT,
  CENTER_P = CENTER_P,
}
