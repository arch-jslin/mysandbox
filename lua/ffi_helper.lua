local ffi = require 'ffi'
return {
  NULL = ffi.cast("void*", ffi.new("int",0)),
  ZERO = ffi.new("int", 0)
}

