-- Another OO Benchmark 5 -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

local bench = require 'bench' . bench

local function union(a, b)
  local dest = {}
  local function shallow_cp(s, d) for k,v in pairs(s) do d[k] = v end end
  shallow_cp(a, dest); 
  shallow_cp(b, dest); 
  return dest
end

function Klass(...) 
  local class = {}
  local superclasses = {...}
  local method_pool = {}
  for i = 1, #superclasses do
    local mt = getmetatable(superclasses[i])
    method_pool = union(method_pool, mt and mt.__index or superclasses[i])
  end  
  setmetatable(class, {__index = method_pool})
  class.__index = class

  function class:new(data)
    local o = {}
    o.data = data or {}
    setmetatable(o, {
      __index = function(t, k) return data[k] and data[k] or self[k] end,
      __newindex = function() error('No harnessing 2.') end, __metatable = false})
    return o
  end

  return class
end

local EntityTemplate = {
  hp = 10,
  mp = 10,
  damage = function(self, n) self.data.hp = self.hp - n end,
  cast   = function(self, n) self.data.mp = self.mp - n end
}
local EntityTemplate2 = {
  fireball = function(self, enemy) enemy:damage(5); self:cast(5) end,
  heal     = function(self) self:damage(-5); self:cast(5) end
}

local function my_klass1(n)
  local C = Klass(EntityTemplate)
  local C2= Klass(C)
  C2.fireball = EntityTemplate2.fireball
  C2.heal     = EntityTemplate2.heal
  local m = C2:new{hp=5, mp=5}
  local m1= C2:new{hp=20, mp=20}
  for i = 1, n do
    for j = 1, 50 do
      m:fireball(m1)
      m:heal()
    end
  end
end

local function my_klass1_m(n)
  local C = Klass(EntityTemplate)
  local C2= Klass(C)
  C2.fireball = EntityTemplate2.fireball
  C2.heal     = EntityTemplate2.heal
  local mariners = {}
  for i = 1, n do
    mariners[i] = C2:new{hp=10, mp=10}
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("my_klass1 for 1M iterations: ", function() return my_klass1(1000000) end)
bench("my_klass1 mem-usage: ", function() return my_klass1_m(100000) end)

