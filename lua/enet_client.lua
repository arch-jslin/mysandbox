-- LuaJIT FFI ENet client test
local ffi = require 'ffi'
local ffi_helper = require 'ffi_helper'
local C = ffi.C
local out_bitrate = 57600 / 8;
local in_bitrate  = 14400 / 8;

local function main()
  local enet = ffi.load[[enet\libenet]]
  ffi.cdef( io.open([[enet\ffi_enet.h]]):read('*a') )
  ffi.cdef[[ int printf(const char*, ...); ]]

  if enet.enet_initialize() ~= 0 then
    io.stderr("An error occurred while initializing ENet.\n")
    os.exit(1)
  end
  
  local addr = ffi.new("ENetAddress[1]")
  addr[0].host = enet.ENET_HOST_ANY
  addr[0].port = tonumber(arg[1])

  local client = enet.enet_host_create(addr, 1, 2, out_bitrate, in_bitrate)
  if client == ffi_helper.NULL then
    io.stderr("An error occurred while trying to create the client.\n")
    os.exit(1)
  end
  
  local addr  = ffi.new("ENetAddress[1]")
  local event = ffi.new("ENetEvent[1]") 

  enet.enet_address_set_host(addr, "127.0.0.1")
  addr[0].port = 12345;

  -- Initiate the connection, allocating the two channels 0 and 1. 
  local peer = enet.enet_host_connect(client, addr, 2, 0);      
  if peer == ffi_helper.NULL then
    print("No available peers for initiating an ENet connection.")
    os.exit(1)
  end
    
  -- Wait up to 5 seconds for the connection attempt to succeed. 
  if enet.enet_host_service(client, event, 5000) > 0 and
     event[0].type == enet.ENET_EVENT_TYPE_CONNECT then
    print("Connection succeeded:", event[0].peer.address.host,
          event[0].peer.address.port)
    event[0].peer.data = ffi.new("char[128]", "[This is the server]")

    local event = ffi.new("ENetEvent[1]")
    while true do 
      while enet.enet_host_service(client, event, 0) > 0 do -- Wait up to 5 sec for an event
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


