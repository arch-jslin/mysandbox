-- some function tests ---------------------------------

-- only way to set up default values?
function fun(n, m)
  n = n or 1
  m = m or 1
  -- do things..
  return n+m, n*m
end

print( fun(3) ) 

function foo1() return "a", "b" end
function foo2() return "c", "d" end

function bar(a, b, ...) -- on multiple assignments... 
  local t = {...}  
  return t
end

for k,v in ipairs(bar(foo1(), foo2())) do print(k,v) end 
-- this only prints "d"

-- manually unpack
function unpac(t, i)
  i = i or 1
  if t[i] then
    return t[i], unpac(t, i+1)
  end
end

print( unpac({1,2,3}) ) 

function printf(fmt, ...)
  io.write(string.format(fmt, ...))
end

printf("haha: %d\n", 5)

-- select! -------------------------------------------

function haha(...)
  for i=1, select("#", ...) do -- THIS STARTS FROM 1 AS WELL!!!!!
    print( select(i, ...) ) -- This is SURPRISING: it prints the rest of the list!
  end
end

haha(1,2,3,nil,4,5)

-- Default named variable pattern --------------------

function _Widget(name, w, h, a, b, c)
  print("Widget created with: ", name, w, h, a, b, c)
  return {}
end

function Widget(o)
  return _Widget(o.name or "default", 
                 o.w or 1, o.h or 1, 
                 o.a, o.b, o.c)
end

zzz = Widget{}

-- scoped variable ------------------------------------

function newCounter()
  local count = 0
  return function() 
    count = count + 1
    return count
  end
end

c = newCounter()
print(c(), c(), c()) -- not undefined behaviour ! XD

-- Non-global function --------------------------------

MyLib = {}
function MyLib.foo(x,y) return x+y end
function MyLib.bar(x,y) return x*y end

-- forward declariation for mutual recursion ----------

local f,g
f = function()
  return g() -- this is a tail call
end
g = function()
  f() -- this is not. if the return callee cannot be instantly returned
end   -- then it is not a proper tail-call.
-- don't call it! will overflow...



