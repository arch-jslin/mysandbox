-- socket loopback test sender ------------------------------
require 'luarocks.loader'
require 'socket'

local data = string.rep("oisdjoirgiwuhfiu", 1024)
local s = socket.tcp()
s:bind('localhost', 45678)
assert(s:listen(1))
c = s:accept()
print("a client connected from "..c:getsockname()..", stat:"..c:getstats())
print("Start sending... ")

local t = os.clock()
local len = 0
for i=1, 100 do
  c:send(data)
  len = len + #data
end
print('('..#data..' bytes per packet): '..( len / (os.clock() - t) / 1024 / 1024 )..' MBytes per second\n')

s:close()

