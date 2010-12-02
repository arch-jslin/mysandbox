-- Another OO Benchmark -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

local bench = require 'bench' . bench

local function table_approach(n)
  assert (loadfile ("another_oo1.lua")) ()
  local mariners = {}
  local m = mariner.new ()
  local m1= mariner.new ()
  for i = 1, n do
    for j = 1, 50 do
      m:fireball (m1)
      m:heal ()
    end
  end
end
  
local function closure_approach(n)
  assert (loadfile ("another_oo2.lua")) ()
  local mariners = {}
  local m = mariner.new ()
  local m1= mariner.new ()
  for i = 1, n do
     for j = 1, 50 do
        m.fireball (m1)
        m.heal ()
     end
  end
end

local function table_approach_m(n)
  assert (loadfile ("another_oo1.lua")) ()
  local mariners = {}
  for i = 1, n do
    mariners[i] = mariner.new ()
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

local function closure_approach_m(n)
  assert (loadfile ("another_oo2.lua")) ()
  local mariners = {}
  for i = 1, n do
    mariners[i] = mariner.new ()
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("table_approach for 1M iterations: ", function() return table_approach(1000000) end)
bench("table_approach mem-usage: ", function() return table_approach_m(100000) end)
bench("closure_approach for 1M iterations: ", function() return closure_approach(1000000) end)
bench("closure_approach mem-usage: ", function() return closure_approach_m(100000) end)
