require 'luarocks.loader'
local socket = require 'socket'

local t = 0
local farside
local host = socket.udp()

host:settimeout(0.1)
host:setsockname(arg[1], tonumber(arg[2]))
if arg[3] and arg[4] then
  local stat, msg = host:setpeername(arg[3], tonumber(arg[4]))
  print( "connection success? "..tostring(stat)..tostring(msg) )
  if stat then
    farside = arg[3]..":"..arg[4]
  end
end

print( host:getsockname() )

local data = nil
while true do
  if farside then
    if socket.gettime() - t > 1 then
      t = socket.gettime()
      host:send("Hello world.")
    end
    data = host:receive()
  else
    data, a, b = host:receivefrom()
    if data then
      print(data, a, b)
      host:setpeername(a, b)
      farside = a..":"..b
    end
  end
  if data and data:len() > 0 then
    print(data)
  end
end

host:close()
