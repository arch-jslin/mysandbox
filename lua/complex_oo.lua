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
