-- test function binding 2, make functions to be called from C/C++

print("jit: "..tostring(jit.status()))

config = {key = 123}

function method1(a, b)
  return a+b;
end

function identity(a, b, c)
  return a, b, c
end

function call_c(a, b)
  return mylib.sine(a+b)
end

-- test function registered from c 
luaopen_mylib()
print(mylib.sine(1)) 
for _,v in ipairs( mylib.dir(".") ) do print(v) end

-- test function registered from c with a table input
local map = mylib.listmap
local a = {1,2,3,4,5}
map(a, function(x) return x*2 end)
for _,v in ipairs(a) do print(v) end

-- test function from c with string input
local b = "a,b,c,d,e"
local tt = mylib.split(b, ",")
for _,v in ipairs(tt) do print(v) end
