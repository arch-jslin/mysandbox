require "enet"

local t = 0
local host = enet.host_create(arg[1])
local farside
if arg[2] then
  farside = host:connect(arg[2])
end

while true do
  local event = host:service(100)
  if event then
    if event.type == "receive" then
      print("Got message: ", event.data, event.peer)
    elseif event.type == "connect" then
      print("Some one connected.")
      if not farside then 
        farside = event.peer 
      end
      event.peer:send("Greetings.")
    end
  end
 
  if farside and os.clock() - t > 1 then
    t = os.clock()
    farside:send "Jejeje."
  end    
end
