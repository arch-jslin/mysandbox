-- socket loopback test receiver ------------------------------
require 'luarocks.loader'
require 'socket'

local c = assert(socket.connect('localhost', 45678))
print('connected to a server, start receiving..')
t = os.clock()
data = assert(c:receive('*a')) -- *all
print('Receiving rate: '..( #data / (os.clock() - t) / 1024 / 1024 )..' MBytes per second\n')
print('Asserting Data: '..string.sub(data, 1, 50), #data)

c:close()