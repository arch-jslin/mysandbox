helper    = require 'helper'
hitTest   = helper.hitTest
new_image = helper.image
remove    = helper.remove
touch_do  = helper.touch_do
frame_do  = helper.frame_do
----------------------------------------------------
pad = new_image('pad.png')
pad.x = 400
pad.y = 460

brick = new_image('brick.png')
brick.x = 400
brick.y = 200
  
ball= new_image('ball_white.png')
ball.x = 400
ball.y = 435

speedx = 2
speedy = -2

moveball = function(e)
  ball.x = ball.x + speedx
  ball.y = ball.y + speedy
  
  if hitTest(ball, brick) then
    speedy = -speedy
    remove(brick)
  end
  
  if hitTest(ball, pad) then
    speedy = -speedy 
  end
  if ball.y < 0 then
    speedy = -speedy
  end
  if ball.x < 0 then
    speedx = -speedx
  end
  if ball.x > 800 then
    speedx = -speedx
  end
end

movepad = function(e)
  pad.x = e.x
end

touch_do(movepad)
frame_do(moveball)

