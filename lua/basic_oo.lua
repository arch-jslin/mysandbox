-- some basic oo tests ----------------------------------

Vec2D = {x = 0, y = 0}

function Vec2D:new(initer) 
  local obj = initer or {}
  setmetatable(obj, self) -- this essentially sets up the prototype chain
  self.__index = self     -- this make any undefined method call in "o" resolve to
  return obj              -- "self", which is Vec2D.
end

function Vec2D:abs()
  local x = self.x
  local y = self.y
  return math.sqrt(x*x + y*y)
end

p1 = Vec2D:new{x = 4, y = 3}
print(p1:abs())

Vec2D.__add = function(a, b)
  return Vec2D:new{ x = a.x + b.x, y = a.y + b.y }
end

print((p1+p1).x)

-- Simple inheritance -----------------------------------

Size2D = Vec2D:new()      -- Size2D extends Vec2D

function Size2D:area()
  return self.x * self.y
end

s = Size2D:new{x = 6, y = 8}

print( s:area() )

-- Pass Multiple inheritance (Mixins) for now -----------

-- Privacy ----------------------------------------------

Vec3D = function(o)
  o = o or {0, 0, 0}
  local x, y, z = unpack(o)
  local instance = {
    getX = function() return x end, -- closure
	getY = function() return y end, -- closure
	getZ = function() return z end, -- closure
	abs = function() return math.sqrt(x*x + y*y + z*z) end, -- closure
  }
  setmetatable(instance, {
    __add = function(a, b) -- closure
	  return Vec3D{x + b.getX(), y + b.getY(), z + b.getZ()}
	end}
  )
  -- too much closure! overhead more than means above
  return instance
end

v3 = Vec3D{3, 4, 5}
v4 = Vec3D{1, 3, 5}
print( v3.getY() ) 
print( v4.abs() )
print( (v4+v3).getY() )

Size3D = function(o)
  local instance = {}
  setmetatable(instance, {__index = Vec3D(o)})
  local getX, getY, getZ = instance.getX, instance.getY, instance.getZ
  function instance.volume() return getX()*getY()*getZ() end
  return instance
end

s2 = Size3D{1,2,3}
s3 = Size3D{2,3,4}
print(s2.volume() + s3.volume())
print(s3.abs())
-- print((s2+s3).getY()) -- must override operator, of course... 

