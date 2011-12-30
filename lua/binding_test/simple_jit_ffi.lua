
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[
typedef struct abc Someotherclass;
typedef struct cde SimpleBase;
typedef struct fgh Simple;

Someotherclass* new_Someotherclass();
char const* Someotherclass_getData(Someotherclass*);
char const* Someotherclass_setData(Someotherclass*, char const*);
void Someotherclass__gc(Someotherclass*);

Simple* new_Simple(int);
char const* SimpleBase_getName(SimpleBase*);
void Simple__gc(Simple*);
int Simple_getID(Simple*);
void SimpleBase_setID(SimpleBase*, int);
void Simple_change_somedata(Simple*, Someotherclass*);
]]

-- wrap into class like behavior

local mt2 = {}
mt2.__index = mt2
mt2.getData = function(self)
  return ffi.string(C.Someotherclass_getData(self))
end
mt2.setData = C.Someotherclass_setData
ffi.metatype("Someotherclass", mt2)

local mt = {}
mt.__index = mt
mt.getName = function(self) 
  return ffi.string(C.SimpleBase_getName(ffi.cast("SimpleBase*", self)))
end
mt.getID = C.Simple_getID
mt.setID = function(self, n)
  C.SimpleBase_setID(ffi.cast("SimpleBase*", self), n)
end
mt.change_somedata = C.Simple_change_somedata
ffi.metatype("Simple", mt)

--[[
local function Simple(...)
  local self = {super = C.new_Simple(...)}
  ffi.gc(self.super, C.Simple__gc)
  return setmetatable(self, mt)
end --]]

local d = ffi.gc(C.new_Someotherclass(), C.Someotherclass__gc)
d:setData("hahahaha")

local s = ffi.gc(C.new_Simple(6), C.Simple__gc)

s:change_somedata(d)

print(s:getName())
print(s:getID())

local counter = 0
local t = os.clock()
for i = 1, 50000 do
  for j = 1, 10000 do  
    s:setID(s:getID()+1) -- fine
  end
end
print( os.clock() - t )
print( s:getID() )

t = os.clock()
for i = 1, 500000000 do
  C.SimpleBase_setID(ffi.cast("SimpleBase*", s), 12) -- best
end
print( os.clock() - t )

local test = C.SimpleBase_setID  
t = os.clock()
for i = 1, 500000000 do 
  test(ffi.cast("SimpleBase*", s), 18) -- NOT GOOD!
end
print( os.clock() - t )

print(s:getID())
