-- Applicative-Order Y-Combinator ---------------

local Y = function(f)
  return (function(x)
    return f (function(y) return (x(x))(y) end)
  end) (function(x)
      return f (function(y) return (x(x))(y) end)
    end)
end

local almost_fac = function(f)
  return function(n)
    if n < 1 then 
      return 1 
    else 
      return n*f(n-1) 
    end
  end
end

print( Y(almost_fac)(10) )

-- Test types -----------------------------------

print( type("Hi") )
print( type(10*42) )
print( type(type) )
print( type(true) )
print( type(nil) )
print( type({}) )
print( type([[]]) )

-- Short Anonymous Functions from lua user wiki -

function fn(s, ...) -- Short Anonymous Function from lua users wiki
  local src = [[
    local L1, L2, L3, L4, L5, L6, L7, L8, L9 = ...
    return function(P1,P2,P3,P4,P5,P6,P7,P8,P9) return ]] .. s .. [[ end
  ]]
  print(  )
  return loadstring(src)(...)
end

-------------------------------------------------

print(0 and 'true' or 'false')
print(nil and 'true' or 'false')
print(4, 0.4, 4.5e-3, 0.3e12, 5e+20)

