
hitTest = require 'helper'.hitTest
--1
pad = display.newImage('pad.png')
pad.x = 400
pad.y = 460

brick=display.newImage('brick.png')
brick.x = 400
brick.y = 200

ball= display.newImage('ball_white.png')
ball.x = 400
ball.y = 435

speedx = 0
speedy = -2

Runtime:addEventListener('enterFrame', function(e)
  ball.x = ball.x + speedx
  ball.y = ball.y + speedy
  if hitTest(ball, brick) then
    ball.y = ball.y + 5
    speedy = -speedy
    --brick:removeSelf()
    --brick = nil
  end
  if hitTest(ball, pad) then
    ball.y = ball.y - 5
    speedy = -speedy
  end
end)

--2
Runtime:addEventListener('touch', function(e)
  pad.x = e.x
end)

