-- Another OO Benchmark 3 -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

local bench = require 'bench' . bench

local ObjStats = function(data)
  local o = {}
  local mt = {__index = data}
  setmetatable(o, mt)
  return o
end

local ObjMethods = function(data)
  function data.damage(n) 
    data.hp = data.hp - n
  end
  function data.cast(n)
    data.mp = data.mp - n
  end
  return data
end

local Obj = function(data)
  local o = ObjStats( ObjMethods(data) )
  function data.fireball(enemy)
    enemy.damage(5)
    data.cast(5)
  end
  function data.heal()
    data.damage(-5)
    data.cast(5)
  end
  return o
end

local function MI_mixed_way(n)
  local m = Obj{hp=10, mp=10}
  local m1= Obj{hp=10, mp=10}
  for i = 1, n do
    for j = 1, 50 do
      m.fireball(m1)
      m.heal()
    end
  end
end

local function MI_mixed_way_m(n)
  local mariners = {}
  for i = 1, n do
    mariners[i] = Obj{hp=10, mp=10}
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("MI_mixed_way for 1M iterations: ", function() return MI_mixed_way(1000000) end)
bench("MI_mixed_way mem-usage: ", function() return MI_mixed_way_m(100000) end)

