helper = require 'helper'
hitTest  = helper.hitTest
new_image= helper.image
new_text = helper.text
random   = helper.random
remove   = helper.remove
touch_do = helper.touch_do
timer_do = helper.timer_do
------------------------------------------------------------

count = -3
answer = 1

numbers = {}
covers  = {}

do_not_touch_anyone = function(i)
  for n = 1, i-1 do
    if numbers[i].x > numbers[n].x - 40 and numbers[i].x < numbers[n].x + 40 and 
       numbers[i].y > numbers[n].y - 40 and numbers[i].y < numbers[n].y + 40 then
      return false
    end
  end
  return true
end

for i = 1, 8 do
  numbers[i] = new_text(i)
  repeat
    numbers[i].x = random(600) + 100
    numbers[i].y = random(350) + 50
    print(i)
  until do_not_touch_anyone(i) 
end

t1 = new_text(count)
t1.x = 750
t1.y = 440

uncover = function(o, e)
  if o.number == answer then
    remove(o)
    answer = answer + 1
  end
end

update = function(e)
  count = count + 1
  systime = os.date("*t")
  t1.text = count
  
  if count == 0 then
    for i = 1, 8 do
      covers[i]        = new_image('square.png')
      covers[i].x      = numbers[i].x
      covers[i].y      = numbers[i].y
      covers[i].number = i
      covers[i].tap_do(uncover)
    end
  end  
end

timer_do(1, update, -1)

-- must remember to tell them how to make a proper cleanup and game restart.
