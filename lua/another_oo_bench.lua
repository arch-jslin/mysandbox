-- Another OO Benchmark -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

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

bench("table_approach for 1M iterations: ", function() return table_approach(1000000) end)
bench("closure_approach for 1M iterations: ", function() return closure_approach(1000000) end)
bench("table_approach mem-usage: ", function() return table_approach_m(100000) end)
bench("closure_approach mem-usage: ", function() return closure_approach_m(100000) end)

-------------------------------------------------------------------

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

BaseA = Class()
BaseA.hp = 10
BaseA.mp = 10
BaseB = Class()
function BaseB:damage(n)
  self.hp = self.hp - n
end
function BaseB:cast(n)
  self.mp = self.mp - n
end

DerivedC = Class(BaseA, BaseB)
function DerivedC:heal()
  self:damage(-5)
  self:cast(5)
end
function DerivedC:fireball(enemy)
  enemy:damage(5)
  self:cast(5)
end

local function MI_with_methodcache(n)
  local m = DerivedC:new()
  local m1= DerivedC:new()
  for i = 1, n do
    for j = 1, 50 do
      m:fireball(m1)
      m:heal()
    end
  end
end

local function MI_with_methodcache_m(n)
  local mariners = {}
  for i = 1, n do
    mariners[i] = DerivedC:new()
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("MI_with_methodcache for 1M iterations: ", function() return MI_with_methodcache(1000000) end)
bench("MI_with_methodcache mem-usage: ", function() return MI_with_methodcache_m(100000) end)

-------------------------------------------------------------------

ObjStats = function(data)
  local o = {}
  local mt = {__index = data}
  setmetatable(o, mt)
  return o
end

ObjMethods = function(data)
  function data.damage(n) 
    data.hp = data.hp - n
  end
  function data.cast(n)
    data.mp = data.mp - n
  end
  return data
end

Obj = function(data)
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

-----------------------------------------------------------------------

local Vec2D = {}
function damage(self, n) self.hp = self.hp - n end
function cast(self, n)   self.mp = self.mp - n end
function fireball(self, enemy) 
  enemy:damage(5)
  self:cast(5)
end
function heal(self)
  self:damage(-5)
  self:cast(5)
end

function Vec2D.new(initer) 
  local self = {
    damage = damage,
    cast =   cast,
    fireball = fireball,
    heal = heal
  }
  self.hp = initer.hp
  self.mp = initer.mp
  return self
end

local function basic_metatable_way(n)
  local m = Vec2D.new{hp=10, mp=10}
  local m1= Vec2D.new{hp=10, mp=10}
  for i = 1, n do
    for j = 1, 50 do
      m:fireball(m1)
      m:heal()
    end
  end
end

local function basic_metatable_way_m(n)
  local mariners = {}
  for i = 1, n do
    mariners[i] = Vec2D.new{hp=10, mp=10}
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("basic_metatable_way for 1M iterations: ", function() return basic_metatable_way(1000000) end)
bench("basic_metatable_way mem-usage: ", function() return basic_metatable_way_m(100000) end)