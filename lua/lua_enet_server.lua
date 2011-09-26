require "enet"
local host = enet.host_create("localhost:"..arg[1])
local farside
if arg[2] then
  farside = host:connect("localhost:"..arg[2])
end

while true do
  local event = host:service(100)
  if event then
    if event.type == "receive" then
      print("Got message: ", event.data, event.peer)
      event.peer:send(event.data)
    elseif event.type == "connect" then
      print("Some one connected.")
      event.peer:send("Jejeje.")
    end
  end
end