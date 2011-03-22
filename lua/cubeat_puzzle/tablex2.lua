
local Helper = require 'helpers'
local random, Stack = Helper.random, Helper.stack
local tablex = require 'pl.tablex'

function tablex.shuffle(array)
  for i = 1, #array do
    local pos = random(#array)+1
    array[i], array[pos] = array[pos], array[i]
  end
end

function tablex.rotate(array, n)
  n = n or 1
  local len = #array
  local temp = tablex.sub(array, -n, -1)
  for i = #array, n+1, -1 do
    array[i] = array[i-n]
  end
  for i = 1, #temp do
    array[i] = temp[i]
  end
end

return tablex
