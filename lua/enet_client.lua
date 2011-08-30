-- LuaJIT FFI ENet client test
local ffi = require 'ffi'
local ffi_helper = require 'ffi_helper'
local out_bitrate = 57600 / 8;
local in_bitrate  = 14400 / 8;

local function main()
  local enet = ffi.load[[enet\libenet]]
  ffi.cdef( io.open([[enet\ffi_enet.h]]):read('*a') )

  if enet.enet_initialize() ~= 0 then
    io.stderr("An error occurred while initializing ENet.\n")
    os.exit(1)
  end

  local client = enet.enet_host_create(ffi_helper.NULL, 1, 2, out_bitrate, in_bitrate)
  if client == ffi_helper.NULL then
    io.stderr("An error occurred while trying to create the client.\n")
    os.exit(1)
  end
  
  local addr  = ffi.new("ENetAddress[1]")
  local event = ffi.new("ENetEvent[1]") 
  local peer  = ffi.new("ENetPeer*")

  enet.enet_address_set_host(addr, "127.0.0.1")
  addr[0].port = 12345;

  -- Initiate the connection, allocating the two channels 0 and 1. 
  peer = enet.enet_host_connect(client, addr, 2, 0);      
  if peer == ffi_helper.NULL then
    print("No available peers for initiating an ENet connection.")
    os.exit(1)
  end
    
  -- Wait up to 5 seconds for the connection attempt to succeed. 
  if enet.enet_host_service(client, event, 5000) > 0 and
     event[0].type == enet.ENET_EVENT_TYPE_CONNECT then
    print("Connection to 127.0.0.1:12345 succeeded.")
  else
    -- Either the 5 seconds are up or a disconnect event was
    -- received. Reset the peer in the event the 5 seconds  
    -- had run out without any significant event.           
    enet.enet_peer_reset(peer)
    print("Connection to 127.0.0.1:12345 failed.")
  end
  ffi.C.atexit (enet.enet_deinitialize);
end

main()


