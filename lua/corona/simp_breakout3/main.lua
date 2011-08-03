
hitTest = require 'helper'.hitTest
--1
pad = display.newImage('pad.png')
pad.x = 400
pad.y = 460

bricks = {}
for a = 1, 10 do 
  for b = 1, 10 do
    i = a*10 + b
    bricks[i] = display.newImage('brick.png')
    bricks[i].x = a * bricks[i].width  + bricks[i].width
    bricks[i].y = b * bricks[i].height + bricks[i].height
  end
end

ball= display.newImage('ball_white.png')
ball.x = 400
ball.y = 435

speedx = math.random()*4 - 2
speedy = -4

Runtime:addEventListener('enterFrame', function(e)
  ball.x = ball.x + speedx
  ball.y = ball.y + speedy
  for a = 1, 10 do 
    for b = 1, 10 do
      i = a*10 + b
      hit = hitTest(ball, bricks[i])
      if hit then
        if hit == 1 then
          if speedy >= 0 then 
            ball.y = ball.y - 5
          else
            ball.y = ball.y + 5
          end
          speedy = -speedy
        elseif hit == 2 then
          if speedx >= 0 then 
            ball.x = ball.x - 5
          else
            ball.x = ball.x + 5
          end
          speedx = -speedx
        end
        bricks[i]:removeSelf()
        bricks[i] = nil
      end
    end
  end
  
  if hitTest(ball, pad) then
    ball.y = ball.y - 5
    speedy = -speedy
    if ball.x < pad.x - pad.width/4 then 
      speedx = speedx - math.random() - 0.5 
    elseif ball.x > pad.x + pad.width/4 then 
      speedx = speedx + math.random() + 0.5 
    end 
  end
  
  if ball.x < 20 or ball.x > 780 then speedx = -speedx end
  if ball.y < 20 then speedy = -speedy end
end)

--2
Runtime:addEventListener('touch', function(e)
  pad.x = e.x
end)

