-- Another OO Benchmark 2 -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

local bench = require 'bench' . bench

local function search(k, superclasses, n)
  for i=1, n do
    local v = superclasses[i][k]
    if v then return v end
  end
end

function Class(...)
  local c = {}
  local superclasses = {...}
  local n = #superclasses
  
  setmetatable(c, {__index = function(t, k)
    local v = search(k, superclasses, n)
    t[k] = v
    return v
  end})
  c.__index = c
  
  function c:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
  end
  
  return c
end

local BaseA = Class()
BaseA.hp = 10
BaseA.mp = 10
local BaseB = Class()
function BaseB:damage(n)
  self.hp = self.hp - n
end
function BaseB:cast(n)
  self.mp = self.mp - n
end

local DerivedC = Class(BaseA, BaseB)
function DerivedC:heal()
  self:damage(-5)
  self:cast(5)
end
function DerivedC:fireball(enemy)
  enemy:damage(5)
  self:cast(5)
end

local function MI_with_methodcache(n)
  local m = DerivedC:new{hp=10, mp=10}
  local m1= DerivedC:new{hp=20, mp=20}
  for i = 1, n do
    m:fireball(m1)
    m:heal()
  end
end

local function MI_with_methodcache_m(n)  
  local mariners = {}
  for i = 1, n do
    mariners[i] = DerivedC:new{hp=15, mp=10}
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("MI_with_methodcache for 10M iterations: ", function() return MI_with_methodcache(10000000) end, 10)
bench("MI_with_methodcache mem-usage: ", function() return MI_with_methodcache_m(100000) end)

--------------------------------------------------------------

