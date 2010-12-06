-- Another OO Benchmark 4 -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

local bench = require 'bench' . bench
local Vec2D = {}
function Vec2D:damage(n) self.hp = self.hp - n end
function Vec2D:cast(n)   self.mp = self.mp - n end
function Vec2D:fireball(enemy) 
  enemy:damage(5)
  self:cast(5)
end
function Vec2D:heal()
  self:damage(-5)
  self:cast(5)
end
Vec2D.__index = Vec2D
function Vec2D:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

local function basic_no_metatable_way(n)
  local m = Vec2D:new{hp=10, mp=10}
  local m1= Vec2D:new{hp=10, mp=10}
  for i = 1, n do
    m:fireball(m1)
    m:heal()
  end
end

local function basic_no_metatable_way_m(n)
  local mariners = {}
  for i = 1, n do
    mariners[i] = Vec2D:new{hp=10, mp=10}
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("basic_no_metatable_way for 10M iterations: ", function() return basic_no_metatable_way(10000000) end)
bench("basic_no_metatable_way mem-usage: ", function() return basic_no_metatable_way_m(100000) end)

