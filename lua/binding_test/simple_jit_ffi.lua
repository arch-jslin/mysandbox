
local ffi = require 'ffi'
local C = ffi.C

ffi.cdef[[
typedef struct Simple Simple;

Simple *Simple_Simple(int);
void Simple__gc(Simple *);
int Simple_id(Simple *);
]]

-- wrap into class like behavior
local mt = {}
mt.__index = mt
function mt.id(self, ...)
  return C.Simple_id(self.super, ...)
end

local function Simple(...)
  local self = {super = C.Simple_Simple(...)}
  ffi.gc(self.super, C.Simple__gc)
  return setmetatable(self, mt)
end

s = Simple(6)
print(s:id())
