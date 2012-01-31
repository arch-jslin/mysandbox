helper = require 'helper'
new_image= helper.image
new_text = helper.text
random   = helper.random
floor    = math.floor
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
order   = {}
for i = 1, 40 do
  order[i] = i
end

new_numbers = function()
  for i = 1, 40 do
    j = floor(random(40)) + 1
    temp = order[i]
    order[i] = order[j]
    order[j] = temp
  end

  for i = 1, 8 do
    numbers[i] = new_text(i)
    numbers[i].x =      (order[i] % 8) * 70 + 100
    numbers[i].y = floor(order[i] / 8) * 70 + 50
  end
end

new_numbers()

uncover = function(o, e)
  if o.number == answer then
    remove(o)
    answer = answer + 1
  else
    count = -4
    answer = 1
    for i = 1, 8 do
      remove(numbers[i])
      remove(covers[i])
    end
    numbers = {}
    covers  = {}
    new_numbers()
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
