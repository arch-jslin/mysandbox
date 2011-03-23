
local random = require 'helpers'.random
local tablex = {}

function tablex.shuffle(array)
  local len = #array
  for i = 1, len do
    local pos = random(len)+1
    array[i], array[pos] = array[pos], array[i]
  end
end

return tablex
