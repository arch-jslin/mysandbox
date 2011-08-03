
--1
pad = display.newImage('pad.png')
pad.x = 400
pad.y = 460

ball= display.newImage('ball_white.png')
ball.x = 400
ball.y = 435

Runtime:addEventListener('enterFrame', function(e)
end)

--2
Runtime:addEventListener('touch', function(e)
  pad.x = e.x
end)

