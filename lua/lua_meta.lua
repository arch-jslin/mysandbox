-- suppose you have a Vec2 and Vec3 type, and a T type which will use them accordingly

-- The Class information should be available out side of this file scope, e.g
-- require 'Vec2'
-- require 'Vec3'
-- require 'Class_with_dimension'
-- I wrote it down here just for simplification

local Vec2 = {}
function Vec2:new(x, y) return setmetatable({x, y}, {__index = self}) end
function Vec2:len() return math.sqrt(self[1]*self[1] + self[2]*self[2]) end

local Vec3 = {}
function Vec3:new(x, y, z) return setmetatable({x, y, z}, {__index = self}) end
function Vec3:len() return math.sqrt(self[1]*self[1] + self[2]*self[2] + self[3]*self[3]) end

function Class_with_dimension(n)
  local c = {}
  -- omit the inheritance chain here, not the keypoint 
  c.__index = c
  if n == 2 then
    c.Vec = Vec2
  elseif n == 3 then
    c.Vec = Vec3
  end
  -- afterwards, when you need corresponding VecT in type T, use T.VecT
  -- its pretty much like using typedefs and templates in conjunction in C++
  function c:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
  end
  return c
end

------------------------

DIM = tonumber(io.read())
    -- you must (and should) have the information when it comes to this.
    -- just get or define it somewhere when you actually need it. Either it 
    -- come from a user input or a file, or something else

T = Class_with_dimension(DIM) 

local helper, collect
if DIM == 3 then 
  helper = function(blah, delta)
    local len = T.Vec:new(delta+1, delta+2, delta+3):len()
    blah.a, blah.b, blah.c = blah.a + len, 
                             blah.b + len, 
                             blah.c + len
  end
  collect = function(blah) return blah.a + blah.b + blah.c end
elseif DIM == 2 then
  helper = function(blah, delta)
    local len = T.Vec:new(delta+1, delta+2):len()
    blah.a, blah.b = blah.a + len, 
                     blah.b + len
  end
  collect = function (blah) return blah.a + blah.b end
end

function T:method(delta) 
  -- now I need some vector related manipulations
  helper(self, delta)
  return collect(self)
end

-- now actually instantiate T

local obj = T:new{a=1, b=2, c=3}
print( obj:method(3), obj.a, obj.b, obj.c )

-- and you'll finally notice there's bound to be some dimension mismatch
-- or you'll have to use DIM info to switch which dimension to use all-over 
-- the place.. But that's a similar logical problem as in C++ template,
-- the design will be "contagious" 

-- But C++ template has served us well towards some degree, if just have
-- to be careful in design, the above example probably is awful anyway..
-- but it's not that hard. 
