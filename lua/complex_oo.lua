-- Complex OO: merge PiL's MI impl and Javascript the Good Parts --

local function search(k, superclasses)
  for i=1, #superclasses do
    local v = superclasses[i][k]
    if v then return v end
  end
end

function Class(...)
  local c = {}
  local superclasses = {...}
  
  setmetatable(c, {__index = function(t, k)
    local v = search(k, superclasses)
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

b = BaseA:new()

DerivedC = Class(BaseA, BaseB)
function DerivedC:heal()
  self:damage(-5)
  self:cast(5)
end
function DerivedC:fireball(enemy)
  enemy:damage(5)
  self:cast(5)
end

c = DerivedC:new()
d = DerivedC:new()
c:fireball(d)
d:heal()

--[[
BaseA = Class({}, {
  prop_ = 1,
  priv_method_ = function(self) ... end,
  public_method = function(self) ... end, -- which might conflict.
})

BaseB = Class({}, {
  propb_ = 2,
  priv_method2_ = function(self) ... end,
  public_method = function(self) ... end, -- which might conflict.
})

DerivedC = Class( 
  inherits={BaseA, BaseB},
  privates={...},
  publics ={...}
})

-- What we haven't tried: 
--   Revisit implementation about private/scoped property with above method
--   Shallow copy table property
--   "The module way" (check Lua-Coat)
--   LOOP is just not clean enough.

--]]

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

local function union(a, b)
  local dest = {}
  local function shallow_cp(s, d) for k,v in pairs(s) do d[k] = v end end
  shallow_cp(a, dest); 
  shallow_cp(b, dest); 
  return dest
end
--some problem with union... bad shallow copy (duplicate)

function Klass(...) 
  local class = {}
  local superclasses = {...}
  local method_pool = {}
  for i = 1, #superclasses do
    method_pool = union(method_pool, superclasses[i])
  end  
  setmetatable(class, {__index = method_pool})
  class.__index = class

  function class:new(data)
    local o = data or {}
    --local mt = {__index = self, __newindex = function() error('No harnessing.') end}
    --setmetatable(o, mt)
    setmetatable(o, self)
    return o
  end

  return class
end

EntityTemplate = {
  hp = 10,
  mp = 10,
  damage = function(self, n) self.hp = self.hp - n end,
  cast   = function(self, n) self.mp = self.mp - n end
}

C1 = Klass(EntityTemplate)
obj = C1:new{hp=5}
inspect(obj)
obj:damage(5)
inspect(obj)
obj.hp = obj.hp - 5
inspect(obj)
