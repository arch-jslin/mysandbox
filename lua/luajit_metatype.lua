
-- test for luajit FFI inheritable metatype

local ffi = require 'ffi'
local C   = ffi.C

ffi.cdef[[
typedef struct { int a, b; } Base;
typedef struct { int a, b, c; } Derived;
]]

local BaseMT = {}
BaseMT.__index = BaseMT
BaseMT.add     = function(self) return self.a + self.b end

ffi.metatype("Base", BaseMT)

local DerivedMT = {}
DerivedMT.__index = DerivedMT
DerivedMT.add     = BaseMT.add     -- explictly inherit this method.. seemed redundant.
DerivedMT.mul     = function(self) return self.a * self.b * self.c end

setmetatable(DerivedMT, BaseMT) 
-- This is deemed no good, for "Base" and "Derived" are really not compatible here.
-- But if they come from C and are in pointer type, I think it's still a go. 

ffi.metatype("Derived", DerivedMT)

local base    = ffi.new("Base", 2, 3) 
local derived = ffi.new("Derived", 2, 3, 4)

print(derived:add(), derived:mul())

for i = 1, 10000000 do
  local a = derived:add()
  local b = derived:mul()
end

