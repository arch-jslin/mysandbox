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
    return n < 1 and 1 or n * f(n-1)
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
  return loadstring(src)(...)
end

print( fn('L1*L2*P1', 5, 10)(15) )

-------------------------------------------------

print(0 and 'true' or 'false')
print(nil and 'true' or 'false')
print(4, 0.4, 4.5e-3, 0.3e12, 5e+20, 0xab)

print( "aaa\b  \fbbb  \v\049" ) 
src = [[
#include <iostream>
int main() {
  return 0;
}
]]
print( src ) 

-- potentially bad ideas:
print( "10" + 1 ) 
print( "-5" * "-2")
--print( "af" * 3 )

print( 10 .. 20 ) 
-- funny, 10..20 will become a malformed fixed-point number
--[[ 
  "Today we are not sure that these automatic coercions were
   a good idea in the design of Lua. As s rule, it's better 
   not to count on them. They are handy in a few places, but
   add complexity to the language and sometimes to program 
   that uses them. After all, strings and numbers are different 
   things, despite these conversions. A comparison like 10=="10"
   is false, because 10 is a number and "10" is a string. If
   you need to convert a string to a number explicitly, you 
   can use the function tonumber(), which returns nil if the 
   string does not denote a proper number:
   
   From Programming in Lua 2/e 
--]]
-- I guess it's just an unfortunate legacy of design.
line = io.read()
n = tonumber(line)
if n == nil then error(line.." is not a number")
else print(n*2) end

print( tostring( #(tostring(10).."Hihi") == 6 ) == "true" )
print( "what if there is a null \0 can we print this?" )

-- so we know that there's no "null character"
print( #"\000" == #" " ) -- \000 counts in length and is printed as a space.

