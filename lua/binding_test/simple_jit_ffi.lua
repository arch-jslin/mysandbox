
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[
typedef struct Someotherclass Someotherclass;
typedef struct pSimple pSimple;

typedef struct {
  enum { PSC_AI_NONE = 0, PSC_AI_SHOOT, PSC_AI_HASTE };
  int x, y;
  int delay;
  unsigned int type; //enum
} Data;

void verify_data(Data*);

Someotherclass* new_Someotherclass();
char const* Someotherclass_getData(Someotherclass*);
char const* Someotherclass_setData(Someotherclass*, char const*);
void Someotherclass__gc(Someotherclass*);

pSimple* new_Simple(int);
char const* Simple_getName(pSimple*);
void Simple__gc(pSimple*);
int  Simple_getID(pSimple*);
void Simple_setID(pSimple*, int);
void Simple_change_somedata(pSimple*, Someotherclass*);

pSimple** create_a_list(int n);
void      simple_list__gc(pSimple**, int);
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
mt.__gc  = C.Simple__gc
ffi.metatype("pSimple", mt)

--[[
local function Simple(...)
  local self = {super = C.new_Simple(...)}
  ffi.gc(self.super, C.Simple__gc)
  return setmetatable(self, mt)
end --]]

print "testing compatible structure (pointers) accessing speed when passed to C functions.."
local data = ffi.new("Data", {1, 2, 3, C.PSC_AI_SHOOT})
local t = os.clock()
for i = 1, 500000000 do 
  data.x = i
  data.y = i*2
  C.verify_data(data)
end
print( os.clock() - t )

local l = ffi.gc(C.create_a_list(2), function(list) C.simple_list__gc(list, 2) end)
for i = 0, 1 do 
  print(l[i]:getID())
end

local d = ffi.gc(C.new_Someotherclass(), C.Someotherclass__gc)
d:setData("hahahaha")

local s = C.new_Simple(6)

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
