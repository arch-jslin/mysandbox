local enet = require "enet"
local host = enet.host_create()
local server = host:connect("localhost:6789")

local done = false
while not done do
  local event = host:service(5000)
  if event then
    if event.type == "connect" then
      print("Connected to", event.peer)
      event.peer:send("hello world")
    elseif event.type == "receive" then
      print("Got message: ", event.data, event.peer)
      if event.data == "hello world" then
        done = true
      end      
    end
  end
end

server:disconnect()
host:flush()