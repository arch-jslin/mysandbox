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

local function each(t, f)
  for _,v in ipairs(t) do f(v) end
end

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

local function powerset(h, ...) -- done through head::tail pattern matching..
  if h == nil then
    return {{}}
  else
    local temp = powerset(...)
    return cons(map(temp, function(x) return {h, unpack(x)} end), temp)    
  end
end

a = {1,2}
b = {3}
c = cons(a,b)

t = powerset(unpack(c))
for i = 1, #t do                -- this is ugly to traverse.
  for j = 1, #(t[i]) do
    io.write(t[i][j], ", ")
  end
  print()
end

-- now lets try to change that powerset thing into iterator --
-- note: try to remember what makes an general iterator factory:
--   the iterator itself, and the invariant, lastly the variable.
-- the pattern matching way probably can't achieve this objective.

local function unpac_rem(t, n, i)
  i = i or 1
  if t[i] and i <= #t - n then 
    return t[i], unpac_rem(t, 1, i+1)
  end
end

local h = {unpac_rem({1,2,3}, 1)}
--each(h, io.write) print()

local function powerset2(list, i, stack)
  if i > #list then return end
  table.insert(stack, list[i])
  coroutine.yield(stack)
  powerset2(list, i+1, stack)
  table.remove(stack)
  powerset2(list, i+1, stack)
end

local function powerset_it(list)
  local co = coroutine.create(function() powerset2(list, 1, {}) end)
  return function()
    local err, result = coroutine.resume(co)
    return result
  end
end

for v in powerset_it({1,2,3}) do
  io.write("{ ")
  for _,u in ipairs(v) do 
    io.write(u, " ") 
  end
  print("}")
end

local function powerset_it2(list)
  return coroutine.wrap(function() powerset2(list, 1, {}) end)
end

iter = powerset_it2{1,2,3} -- powerset_it will do just fine
local v = iter()
while v do 
  for _,u in ipairs(v) do io.write(u, " ") end
  print()
  v = iter()
end