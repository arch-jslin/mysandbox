local ffi = require 'ffi'
ffi.cdef[[
typedef int (__stdcall *WNDENUMPROC)(void *hwnd, intptr_t l);
int EnumWindows(WNDENUMPROC func, intptr_t l);
]]

-- Explicitly convert to a callback via cast.
local count = 0
local cb = ffi.cast("WNDENUMPROC", function(hwnd, l)
  count = count + 1
  print(count)
  return true
end)

-- Pass it to a C function.
ffi.C.EnumWindows(cb, 0)
-- EnumWindows doesn't need the callback after it returns, so free it.

cb:free()
-- The callback function pointer is no longer valid and its resources
-- will be reclaimed. The created Lua closure will be garbage collected.