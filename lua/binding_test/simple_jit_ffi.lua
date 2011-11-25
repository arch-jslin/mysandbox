
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[
typedef struct Simple Simple;

Simple *new_Simple(int);
void Simple__gc(Simple*);
int Simple_getID(Simple*);
void Simple_setID(Simple*, int);
]]

-- wrap into class like behavior

local mt = {}
mt.__index = mt
mt.getID = C.Simple_getID
mt.setID = C.Simple_setID
ffi.metatype("Simple", mt)
--[[
local function Simple(...)
  local self = {super = C.new_Simple(...)}
  ffi.gc(self.super, C.Simple__gc)
  return setmetatable(self, mt)
end --]]

local s = ffi.gc(C.new_Simple(6), C.Simple__gc)
print(C.Simple_getID(s))
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
