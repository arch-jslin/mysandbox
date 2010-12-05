
module('bench',package.seeall)

local randomseed, rand, floor, abs = math.randomseed, math.random, math.floor, math.abs
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

local function _bench(f, times)
  local total_t, best, worst = 0, math.huge, 0
  for i = 1, times do
    local t1 = os.clock()
    f()
    local delta = os.clock() - t1
    total_t = total_t + delta
    if delta < best then best = delta end
    if delta > worst then worst = delta end
  end
  return total_t / times, best, worst
end

function bench(desc, f, times)
  times = times or 1
  local avg, best, worst = _bench(f, times)
  print( (desc or "Benchmark result: ").."Avg. "..avg..(times > 1 and " ("..times.." rnds) (Range: "..best.." - "..worst..")" or "") )
end