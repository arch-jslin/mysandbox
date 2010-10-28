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


