-- LuaJIT FFI ENet server test
local ffi = require 'ffi'
local ffi_helper = require 'ffi_helper'
local C = ffi.C

local function main()
  local enet = ffi.load[[enet\libenet]]
  ffi.cdef( io.open([[enet\ffi_enet.h]]):read('*a') )

  if enet.enet_initialize() ~= 0 then
    io.stderr("An error occurred while initializing ENet.\n")
    os.exit(1)
  end

  local addr = ffi.new("ENetAddress[1]")
  addr[0].host = enet.ENET_HOST_ANY
  addr[0].port = tonumber(arg[1])

  local serv = enet.enet_host_create(addr, 32, 2, 0, 0)
  if serv == ffi_helper.NULL then
    io.stderr("An error occurred while trying to create the server.\n")
    os.exit(1)
  end
  
  local event = ffi.new("ENetEvent[1]")
  while true do 
    while enet.enet_host_service(serv, event, 0) > 0 do -- Wait up to 5 sec for an event
      if event[0].type == enet.ENET_EVENT_TYPE_CONNECT then
        io.write(("A new client connected from: %d:%d\n"):format(
                 event[0].peer.address.host,
                 event[0].peer.address.port))
        event[0].peer.data = ffi.new("char[128]", "[This is a client]")
        
      elseif event[0].type == enet.ENET_EVENT_TYPE_RECEIVE then
        io.write(("%d %s; %d %s\n"):format(
                 event[0].channelID, event[0].peer.data, event[0].packet.dataLength, 
                 event[0].packet.data))
        -- use the packet here
        enet.enet_packet_destroy(event[0].packet) -- done using it, kill it.
             
      elseif event[0].type == enet.ENET_EVENT_TYPE_DISCONNECT then
        io.write(("Disconnected: %s\n"):format(event[0].peer.data))
        event[0].peer.data = ffi_helper.NULL -- drop it.
      end
    end
  end
  ffi.C.atexit (enet.enet_deinitialize);
end

main()
