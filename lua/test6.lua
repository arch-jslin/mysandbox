-- coroutine -----------------------------------------

co = coroutine.create (function() 
  print("co", coroutine.yield())
  return 6, 7
end)

print(coroutine.resume(co))
print(coroutine.resume(co, 4, 5)) -- true  6  7
print(coroutine.resume(co, 4, 5, 6))  -- false   cannot resume dead

function receive(p)
  local stat, value = coroutine.resume(p)
  return value
end

function send(...)
  coroutine.yield(...)
end

-- a consumer-driven coroutine from Lua book

function producer()
  return coroutine.create(function()
    for i = 0, 3 do
      local input = io.read()
      send(input)
    end
    send(nil)
  end)
end

function filter(p)
  return coroutine.create(function()
    for line = 1, math.huge do 
      local input = receive(p)
      if not input then send(nil); break end 
      local msg = "user says: "..input
      send(msg)
    end
  end)
end

function consumer(p)
  local str 
  repeat
    str = receive(p)
    io.write(str and str or "", "\n")
  until not str
end
    
consumer(filter(producer()))

-- powerset test -----------------------------------

local function map(t, f)
  local res = t and {unpack(t)} or {}
  for i=1, #res do res[i] = f(res[i]) end
  return res
end

local function cons(t1, t2)
  local res = t1 and {unpack(t1)} or {}
  for _,v in ipairs(t2) do table.insert(res, v) end
  return res
end

local function powerset(h, ...)
  if h == nil then
    return {{}}
  else
    local temp = powerset(...)
    return cons(temp, map(temp, function(x) return {h, unpack(x)} end) )    
  end
end

a = {1,2}
b = {3,4}
c = cons(a,b)

t = powerset(unpack(c))
for i = 1, #t do
  for j = 1, #(t[i]) do
    io.write(t[i][j], ", ")
  end
  print()
end

-- now lets try to change that powerset thing into iterator --

