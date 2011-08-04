helper   = require 'helper'
hitTest  = helper.hitTest
new_image= helper.image
random   = helper.random
remove   = helper.remove
frame_do = helper.frame_do
touch_do = helper.touch_do
------------------------------------------------------------------
pad =  new_image('pad.png')
ball = new_image('ball_white.png')
bricks = {}

new_bricks_game = function()
  pad.x = 400
  pad.y = 460
  ball.x = 400
  ball.y = 435
  speedx = random(4) - 2
  speedy = -4

  for a = 1, 10 do 
    for b = 1, 10 do
      i = a*10 + b
      bricks[i] = new_image('brick.png')
      bricks[i].x = a * bricks[i].width  + bricks[i].width*2
      bricks[i].y = b * bricks[i].height + bricks[i].height*2
    end
  end
end

new_bricks_game()

moveball = function(e)
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
        remove(bricks[i])
      end
    end
  end
  
  if hitTest(ball, pad) and speedy > 0 then
    ball.y = ball.y - 5
    speedy = -speedy
    if ball.x < pad.x - pad.width/4 then 
      speedx = speedx - math.random() - 0.5 
    elseif ball.x > pad.x + pad.width/4 then 
      speedx = speedx + math.random() + 0.5 
    end 
  end
  
  if ball.x < 20 or ball.x > 780 then 
    speedx = -speedx 
  end
  
  if ball.y < 20 then 
    speedy = -speedy 
  end
  
  if ball.y > 500 then
    for a = 1, 10 do 
      for b = 1, 10 do
        i = a*10 + b
        remove(bricks[i])
      end
    end
    bricks = {}
    new_bricks_game()
  end
end

movepad = function(e)
  pad.x = e.x
end

frame_do(moveball)
touch_do(movepad)

