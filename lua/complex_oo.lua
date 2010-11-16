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
    return search(k, superclasses)
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
BaseB = Class()

b = BaseA:new()

DerivedC = Class(BaseA, BaseB)

c = DerivedC:new()

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

