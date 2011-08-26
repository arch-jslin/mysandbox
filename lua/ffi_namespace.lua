local ffi = require 'ffi'

ffi.cdef[[
void print(char*) asm("printf");
]]

ffi.C.print(ffi.new("char[10]", 'abc\n'))

ffi.cdef[[
void print(char*, char*) asm("sprintf");
]]

local s = ffi.new("char[10]")
ffi.C.print(s, ffi.new("char[6]",'abcd\n'))

print(s)