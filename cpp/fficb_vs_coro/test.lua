local ffi = require 'ffi'
ffi.cdef[[ 
typedef struct {
    int type;
} Event;
void set_callback(void (*cb)(int));
int poll();
]]

local function func(value)
  value = value + 123894729
end

function func2(value)
  value = value + 129286418
end

function start_loop()
  print "lua tight loop triggered"
  while true do
    local sum = ffi.C.poll() + 129379128
  end
end

ffi.C.set_callback(func)
