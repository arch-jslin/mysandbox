-- Another OO Benchmark 5 -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

local bench = require 'bench' . bench

local function inspect(t, indent)
  indent = indent or 0
  local heading = indent > 0 and string.rep(" ", indent) or ""
  for k,v in pairs(t) do
    if type(v) == "table" then 
      if v == t then io.write(heading..k.."\tself\n")
      else io.write(heading..k.."\t"..tostring(v).."\n"); inspect(v, indent+8) end
    else io.write(heading..k.."\t"..tostring(v).."\n") end
  end
end

local Klass = nil
do
  local ScopeHandler = {}
  local private = setmetatable({}, {__mode = "k"}) -- private scoped properties

  local function union(a, b)
    local dest = {}
    local function shallow_cp(s, d) for k,v in pairs(s) do d[k] = v end end
    shallow_cp(a, dest); 
    shallow_cp(b, dest); 
    return dest
  end

  function ScopeHandler.reader(class)
    --blah
  end
  
  function ScopeHandler.accessor(class)
    local accessors = {} 
    for k,v in pairs(class) do
      if type(v) ~= "function" and type(k) == "string" then
        local get_name = "get"..k
        local set_name = "set"..k
        local code1 = "return function(priv) return function(self) return priv[self]."..k.." end end"
        local code2 = "return function(priv) return function(self, v) priv[self]."..k.." = v end end"
        accessors[get_name] = loadstring(code1)()(private)
        accessors[set_name] = loadstring(code2)()(private)
      end
    end 
    accessors.get = function(self, k) return private[self][k] end
    accessors.set = function(self, k, v) private[self][k] = v end
    return accessors
  end

  function MakeClass(...) 
    local class = {}
    local superclasses = {...}
    local method_pool = {}
    for i = 1, #superclasses do
      local mt = getmetatable(superclasses[i])
      method_pool = union(method_pool, mt and mt.__index or superclasses[i])
    end
    method_pool = union(method_pool, ScopeHandler.accessor(method_pool))
    setmetatable(class, {__index = method_pool})
    class.__index = class
    class.new = function(self, o)
      o = o or {}
      private[o] = o --init private stuff
      setmetatable(o, self)
      return o
    end
    return class
  end
  Klass = MakeClass
end --end of Klass module
  
local C, C2, EntityTemplate, EntityTemplate2 = {}, {}, {}, {}
do  
  local private = setmetatable({}, {__mode = "k"}) -- private scoped properties
  EntityTemplate = {
    hp = 10,
    mp = 10,
    damage = function(self, n) self:sethp(self:gethp() - n) end,
    cast   = function(self, n) self:setmp(self:getmp() - n) end
  }

  EntityTemplate2 = {
    fireball = function(self, enemy) enemy:damage(5); self:cast(5) end,
    heal     = function(self) self:damage(-5); self:cast(5) end
  }
  
  C = Klass(EntityTemplate)
  C2= Klass(C)
  C2.new = C.new
  C2.fireball = EntityTemplate2.fireball
  C2.heal     = EntityTemplate2.heal
end

local function my_klass1(n)
  local m = C2:new{hp=5}
  local m1= C2:new{mp=20}
  for i = 1, n do
    m:fireball(m1)
    m:heal()
  end
end

local function my_klass1_m(n)
  local mariners = {}
  for i = 1, n do
    mariners[i] = C2:new()
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("my_klass1 for 10M iterations: ", function() return my_klass1(10000000) end, 10)
bench("my_klass1 mem-usage: ", function() return my_klass1_m(100000) end)

