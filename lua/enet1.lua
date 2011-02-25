-- Testing LuaJIT2 FFI to enet binding
local ffi = require 'ffi'
local enet = ffi.load[[enet\libenet]]
ffi.cdef( io.open([[enet\ffi_enet.h]]):read('*a') )

if enet.enet_initialize () ~= 0 then
  io.stderr("An error occurred while initializing ENet.\n")
  os.exit(1)
end

local addr = ffi.new("ENetAddress[1]")
addr[0].host = enet.ENET_HOST_ANY
addr[0].port = 12345

local serv = enet.enet_host_create(addr, 32, 2, 0, 0)
if tonumber(ffi.cast("int", serv)) == 0 then
  io.stderr("An error occurred while trying to create the host.\n")
  os.exit(1)
end

ffi.C.atexit (enet.enet_deinitialize);

