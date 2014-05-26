helper = require 'helper'
new_image= helper.image
new_text = helper.text
random   = helper.random
remove   = helper.remove
touch_do = helper.touch_do
timer_do = helper.timer_do
------------------------------------------------------------

count = -3

number1 = new_text(1)
number1.x = random(600) + 100
number1.y = random(350) + 50

number2 = new_text(2)
number2.x = random(600) + 100
number2.y = random(350) + 50

number3 = new_text(3)
number3.x = random(600) + 100
number3.y = random(350) + 50

t1 = new_text(count)
t1.x = 750
t1.y = 440

update = function(e)
  count = count + 1
  t1.text = count 
end

timer_do(1, update, -1)
