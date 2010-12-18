-- test function binding 2, make functions to be called from C/C++

function method1(a, b)
  return a+b;
end

function identity(a, b, c)
  return a, b, c
end