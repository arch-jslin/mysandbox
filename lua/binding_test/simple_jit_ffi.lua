
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[
typedef struct abc Someotherclass;
typedef struct cde pSimpleBase;
typedef struct fgh pSimple;

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
char const* SimpleBase_getName(pSimpleBase*);
void Simple__gc(pSimple*);
int  Simple_getID(pSimple*);
void SimpleBase_setID(pSimpleBase*, int);
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
--mt.__index = mt
mt.__index = mt
mt.getName = function(self) 
  return ffi.string(C.SimpleBase_getName(ffi.cast("pSimpleBase*", self)))
end
mt.getID = C.Simple_getID
mt.setID = function(self, n)
  C.SimpleBase_setID(ffi.cast("pSimpleBase*", self), n)
end
mt.change_somedata = C.Simple_change_somedata
-- mt.__gc  = C.Simple__gc this should not be useful under this use case
ffi.metatype("pSimple", mt)

local function dupe_cdata_mt(meta)
  local t = {} 
  for k, v in pairs(meta) do
    t[k] = function(self, ...) return meta[k](self._cdata, ...) end
  end
  t.__index = t
  return t
end

local wrapped_mt = dupe_cdata_mt(mt)

-- now this wrapped_mt only happens per "inheritance" or per "composition"
-- speed-wise it makes no difference and memory-wise it's cool now
-- other inheritance impl in Lua involve table caching as well. So it's the same.

local function new_simple(o)
  o._cdata = ffi.gc(C.new_Simple(o[1]), C.Simple__gc)
  o = setmetatable(o, wrapped_mt)
  return o
end

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

local d = C.new_Someotherclass()
d:setData("hahahaha")

local s = new_simple {6}

s:change_somedata(d)

print(s:getName())
print(s:getID())

local counter = 0
local t = os.clock()
for i = 1, 500000000 do  
  s:setID(s:getID()+1) -- fine
end
print( os.clock() - t )
print( s:getID() )

t = os.clock()
for i = 1, 500000000 do
  -- C.SimpleBase_setID(ffi.cast("pSimpleBase*", s), 12) -- best
  s:setID(12)
end
print( os.clock() - t )

local test = C.SimpleBase_setID  
t = os.clock()
for i = 1, 500000000 do 
  --test(ffi.cast("pSimpleBase*", s), 18) -- NOT GOOD!
  test(ffi.cast("pSimpleBase*", s._cdata), 18) -- NOT GOOD!
end
print( os.clock() - t )

print(s:getID())
