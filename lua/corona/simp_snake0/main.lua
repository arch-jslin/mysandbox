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

snake = new_image('snake.png')
go_x = 1
go_y = 0

startx = 0
starty = 0
dx = 0
dy = 0

snake_go = function(e)
  if e.phase == 'began' then   -- touch start
    startx = e.x
    starty = e.y
  elseif e.phase == 'ended' then -- touch end
    dx = e.x - startx
    dy = e.y - starty
    if abs(dx) > abs(dy) then  -- left or right
      if dx > 0 then
        go_x = 1
        go_y = 0
      else
        go_x = -1
        go_y = 0
      end
    else                       -- up or down
      if dy > 0 then 
        go_x = 0
        go_y = 1
      else
        go_x = 0
        go_y = -1
      end
    end
  end
end

move_snake = function(e)
  snake.x = snake.x + go_x * 32
  snake.y = snake.y + go_y * 32
end

touch_do(snake_go)
timer_do(0.5, move_snake, -1)
