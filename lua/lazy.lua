-- is it possible to implement lazy in Lua? -------------

function force(f)
  return type(f) == 'function' and f() or f
end

-- This comes from an answer at stackoverflow: 
-- http://stackoverflow.com/questions/2834579/
--   print-all-local-variables-accessible-to-the-current-scope-in-lua
function upvalues() 
  local variables = {}
  local idx = 1
  while true do
    local ln, lv = debug.getlocal(3, idx)
    if ln ~= nil then variables[ln] = lv else break end
    idx = 1 + idx
  end
  return variables
end

local compiled_string = {} -- stores the compiled "string lambdas"
setmetatable(compiled_string, {__mode = "kv"}) -- make it full weak

-- the input is a string, which will be compiled into a function.
-- the args must be assigned to be used with setfenv(), otherwise 
-- it will call upvalues(), using debug module which should NOT be
-- a good idea in production code.. (very slow) 
-- when the lazy object(table) is called through __call, 
-- it forces the result, which should return a function, and pass
-- the arguments to the delayed function; however, if the original
-- "string lambda" would not return a function, then this call simply
-- returns the delayed result.
function lazy(src, args)
  local f = {}
  if not compiled_string[src] then 
    compiled_string[src] = assert(loadstring("return "..src))
  end
  local fun = compiled_string[src]
  setfenv(fun, args and args or upvalues())
  setmetatable(f, {__call = 
    function(t, ...)
      local forced_res = force(fun)
      return type(forced_res) == "function" and forced_res(...) or forced_res
    end
  })
  return f
end

local Y = function(f)
  return (function(x)
    return f( lazy("x(x)",{x=x}) )
  end) (function(x)
      return f ( lazy("x(x)",{x=x}) )
    end)
end

local almost_fac = function(f)
  return function(n)
    return n < 1 and 1 or n * f(n-1)
  end
end

print( Y(almost_fac)(10) )

-- performance test about lazy --------------------------

local a = 5; local b = 10;

local t = os.clock()
for i = 0, 100000 do
  local func = lazy("a+b", {a=a, b=b})
  func() -- the delayed result of a+b
end
local t2= os.clock()
print( "time: "..(t2-t) )

-- a pseudo fibonacci
local almost_fib = function(f)  
  return function(n)
    if n < 1 then return 0
    elseif n == 1 then return 1     
    else return f(n-2) + f(n-1)
    end
  end
end

local t3= os.clock()
print( Y(almost_fib)(24) )
print( "time: "..(os.clock()-t3) )

-- a pseudo ackermann
local almost_ackermann = function(f)
  return function(m, n)
    if m == 0 then return n+1
    elseif m > 0 and n == 0 then return f(m-1, 1)
    else return f(m-1, f(m, n-1))
    end
  end
end

local t4= os.clock()
print( Y(almost_ackermann)(3, 6) )
print( "time: "..(os.clock()-t4) )