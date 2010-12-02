
module('bench',package.seeall)

local randomseed, rand, floor, abs = math.randomseed, math.random, math.floor, math.abs
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

function bench(desc, f)
  local t = os.clock()
  f()
  print( desc or "", os.clock() - t )
end
