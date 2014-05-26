helper = require 'helper'
new_image= helper.image
new_text = helper.text
random   = helper.random
remove   = helper.remove
touch_do = helper.touch_do
timer_do = helper.timer_do
-----------------------------------------------------------

count = 0

s = new_image('square.png')
s.x = 150
s.y = 150

one = new_text('1')
one.x = s.x
one.y = s.y

time_text = new_text(count)
time_text.x = 300
time_text.y = 300

uncover = function()
  remove(s)
end

update = function()
  count = count + 1
  time_text.text = count
end

s.tap_do(uncover)

timer_do(1, update, -1)
