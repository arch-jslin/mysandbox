helper = require 'helper'
hitTest  = helper.hitTest
new_image= helper.image
new_text = helper.text
random   = helper.random
floor    = math.floor
abs      = math.abs
remove   = helper.remove
touch_do = helper.touch_do
timer_do = helper.timer_do
------------------------------------------------------------

new_snake_head = function()
  snake = {}
  snake[1] = new_image('snake.png')
  snake[1].x = 32
  snake[1].y = 32
  snake[1].go_x = 1
  snake[1].go_y = 0
end

new_snake_head()

food = new_image('snake.png')
food.x = ( floor(random(24)) + 1 ) * 32
food.y = ( floor(random(14)) + 1 ) * 32

startx = 0
starty = 0
dx = 0
dy = 0

count = 0

snake_go = function(e)
  if e.phase == 'began' then   -- touch start
    startx = e.x
    starty = e.y
  elseif e.phase == 'ended' then -- touch end
    dx = e.x - startx
    dy = e.y - starty
    if abs(dx) > abs(dy) then  -- left or right
      if dx > 0 then
        snake[1].go_x = 1
        snake[1].go_y = 0
      else
        snake[1].go_x = -1
        snake[1].go_y = 0
      end
    else                       -- up or down
      if dy > 0 then 
        snake[1].go_x = 0
        snake[1].go_y = 1
      else
        snake[1].go_x = 0
        snake[1].go_y = -1
      end
    end
  end
end

move_snake = function(e)
  count = count + 1
  if snake[1].x == food.x and snake[1].y == food.y then
    snake[#snake+1] = new_image('snake.png')
    snake[#snake].x = snake[#snake-1].x
    snake[#snake].y = snake[#snake-1].y
    snake[#snake].go_x = 0
    snake[#snake].go_y = 0
    food.x = ( floor(random(24)) + 1 ) * 32
    food.y = ( floor(random(14)) + 1 ) * 32
  end

  for i = #snake, 1, -1 do
    snake[i].x = snake[i].x + snake[i].go_x * 32
    snake[i].y = snake[i].y + snake[i].go_y * 32
    if i > 1 then
      snake[i].go_x = snake[i-1].go_x
      snake[i].go_y = snake[i-1].go_y
    end
  end
  
  if snake[1].x >= 800 or snake[1].x <= 0 or snake[1].y >= 480 or snake[1].y <= 0 then
    food.x = ( floor(random(24)) + 1 ) * 32
    food.y = ( floor(random(14)) + 1 ) * 32
    count = 0
    for i = 1, #snake do
      remove(snake[i])
    end
    new_snake_head()
  end
  
  for i = 2, #snake do
    if snake[i].x == snake[1].x and snake[i].y == snake[1].y then
      food.x = ( floor(random(24)) + 1 ) * 32
      food.y = ( floor(random(14)) + 1 ) * 32
      count = 0
      for i = 1, #snake do
        remove(snake[i])
      end
      new_snake_head()
      break
    end
  end
end

touch_do(snake_go)
timer_do(0.3, move_snake, -1)
