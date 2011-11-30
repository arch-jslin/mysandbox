
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[
typedef struct Simple Simple;
typedef struct Someotherclass Someotherclass;
typedef struct pSimplePtr pSimplePtr;

Someotherclass* new_Someotherclass();
char const* Someotherclass_getData(Someotherclass*);
char const* Someotherclass_setData(Someotherclass*, char const*);
void Someotherclass__gc(Someotherclass*);

pSimplePtr *get_SimplePtr(int);

Simple *new_Simple(int);
char const* Simple_getName(Simple*);
void Simple__gc(Simple*);
int Simple_getID(Simple*);
void Simple_setID(Simple*, int);
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
  return ffi.string(C.Simple_getName(self))
end
mt.getID = C.Simple_getID
mt.setID = C.Simple_setID
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

local t = os.clock()
for i = 1, 500000000 do 
  s:setID(12) -- fine
end
print( os.clock() - t )

t = os.clock()
for i = 1, 500000000 do
  C.Simple_setID(s, 12) -- best
end
print( os.clock() - t )

local test = C.Simple_setID  
t = os.clock()
for i = 1, 500000000 do 
  test(s, 18) -- NOT GOOD!
end
print( os.clock() - t )

print(s:getID())
