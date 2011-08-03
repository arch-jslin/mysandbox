
hitTest = require 'helper'.hitTest
--1
pad = display.newImage('pad.png')
pad.x = 400
pad.y = 460
--[[
brick=display.newImage('brick.png')
brick.x = 400
brick.y = 200
--]]
bricks = {}
for a = 1, 10 do 
  for b = 1, 10 do
    i = a*10 + b
    bricks[i] = display.newImage('brick.png')
    bricks[i].x = a * 60 + 60
    bricks[i].y = b * 30 + 30
  end
end

print(bricks[99].y)

ball= display.newImage('ball_white.png')
ball.x = 400
ball.y = 435

speedx = 0
speedy = -2

Runtime:addEventListener('enterFrame', function(e)
  ball.x = ball.x + speedx
  ball.y = ball.y + speedy
  for a = 1, 10 do 
    for b = 1, 10 do
      i = a*10 + b
      if hitTest(ball, bricks[i]) then
        ball.y = ball.y + 5
        speedy = -speedy
        bricks[i]:removeSelf()
        bricks[i] = nil
      end
    end
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

