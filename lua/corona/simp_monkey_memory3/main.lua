helper = require 'helper'
new_image= helper.image
new_text = helper.text
random   = helper.random
remove   = helper.remove
touch_do = helper.touch_do
timer_do = helper.timer_do
------------------------------------------------------------

count = -3
answer = 1

t1 = new_text(count)
t1.x = 750
t1.y = 440

numbers = {}
covers  = {}
for i = 1, 8 do
  numbers[i] = new_text(i)
  numbers[i].x = random(600) + 100
  numbers[i].y = random(350) + 50
end

uncover = function(o, e)
  if o.number == answer then
    remove(o)
    answer = answer + 1
  end
end

update = function(e)
  count = count + 1
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
