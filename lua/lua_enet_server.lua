require "luarocks.loader"
local enet    = require "enet"
local gettime = require "socket".gettime

-- get self ip
local self_ip = socket.dns.toip( socket.dns.gethostname() )
print( "Self IP: "..self_ip )

local function random(n) return math.floor(math.random()*n) end 

-- now we start talking to server using enet
local t = 0
local host = enet.host_create(arg[1])
local farside
if arg[2] then
  farside = host:connect(arg[2])
end

while true do
  local event = host:service(0)
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
 
  if farside and gettime() - t > 1 then
    t = gettime()
    for i = 1, 10 do 
      farside:send("@"..("xkcd"):rep(1+random(10)))
      farside:send("#"..("xkcd"):rep(1+random(10)))
    end
  end    
end
