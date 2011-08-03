helper    = require 'helper'
hitTest   = helper.hitTest
new_image = helper.image
remove    = helper.remove
random    = helper.random
touch_do  = helper.touch_do
frame_do  = helper.frame_do
----------------------------------------------------
pad = new_image('pad.png')
pad.x = 400
pad.y = 460

bricks = {}

for i = 1, 10 do 
  bricks[i] = new_image('brick.png')
  bricks[i].x = i * 60 + 65
  bricks[i].y = 200
end

ball= new_image('ball_white.png')
ball.x = 400
ball.y = 435

speedx = random(4) - 2
speedy = -4

moveball = function(e)
  ball.x = ball.x + speedx
  ball.y = ball.y + speedy
  
  for i = 1, 10 do 
    if hitTest(ball, bricks[i]) then
      ball.y = ball.y + 5
      speedy = -speedy
      remove(bricks[i])
    end
  end
  
  if hitTest(ball, pad) then
    ball.y = ball.y - 5
    speedy = -speedy
  end
  
  if ball.x < 20 or ball.x > 780 then 
    speedx = -speedx 
  end
  
  if ball.y < 20 then 
    speedy = -speedy 
  end
end

movepad = function(e)
  pad.x = e.x
end

frame_do(moveball)
touch_do(movepad)

