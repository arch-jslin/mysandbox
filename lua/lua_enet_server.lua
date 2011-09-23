require "enet"
local host = enet.host_create"localhost:6789"
while true do
    local event = host:service(100)
    if event and event.type == "receive" then
        print("Got message: ", event.data, event.peer)
        event.peer:send(event.data)
    end
end