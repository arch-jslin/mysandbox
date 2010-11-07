-- coroutine and socket -----------------------------------

require 'luarocks.loader'
require 'socket'

host = 'www.w3.org'
threads = {}

function receive_from(conn)
  conn:settimeout(0)                         -- to make it non-blocking
  local s, err, partial = conn:receive(2^10) -- read the source by 1KBytes a time
  if err == "timeout" then                   -- if it timed-out
    coroutine.yield(conn)                    -- then yield s'th not nil to signal this is still running
  end  
  return s or partial, err
end

function download(host, file)
  local c = assert(socket.connect(host, 80))
  local size = 0
  c:send('GET '..file..' HTTP/1.0\r\n\r\n')
  while true do
    local s, err = receive_from(c)           -- will yield here.
    size = size + #s
    if err == 'closed' then break end
  end
  c:close()
  print(file, size)
end

function get(host, file)
  local co = coroutine.create(function()
    return download(host, file)
  end)
  table.insert(threads, co)
end

function dispatcher()
  while #threads > 0 do
    local conns = {}
    local i = 1
    while i <= #threads do
      local err, res = coroutine.resume(threads[i])
      if not res then -- this coroutine finished
        table.remove(threads, i)
        -- we don't add i here since there's one element removed from the collection.
      else
        i = i + 1
        conns[#conns + 1] = res  -- result of a yielded thread
        if #conns == #threads then -- all threads yielded
          socket.select(conns)   -- QUESTION: what does this do?
        end
      end
    end
  end
end

get(host, '/TR/html401/html40.txt')
get(host, '/TR/REC-html32.html')
get(host, '/TR/2002/REC-xhtml1-20020801/xhtml1.pdf')
get(host, '/TR/2000/REC-DOM-Level-2-Core-20001113/DOM2-Core.txt')

dispatcher()

