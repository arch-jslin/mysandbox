helper = require 'helper'
new_image = helper.image
touch_do  = helper.touch_do
frame_do  = helper.frame_do
------------------------------------------------------------
pad = new_image('pad.png')
pad.x = 400
pad.y = 460

ball= new_image('ball_white.png')
ball.x = 400
ball.y = 435

move = function(e)
  pad.x = e.x
end

v = 3

moveball = function(e)
  if ball.x > 800 then
    v = -v
  end
  if ball.x < 0 then
    v = -v
  end
  ball.x = ball.x + v
end

touch_do(move)
frame_do(moveball)
