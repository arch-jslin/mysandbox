-- from http://lua-users.org/wiki/ExpressionTemplatesInLua

-- Expression object.
local expression_mt = {}
function Expression(name)
  return setmetatable(
    {name=name, eval=function(vars) return vars[name] end},
    expression_mt)
end
local function eval(o, vars)
  if type(o) == 'table' then return o(vars) else return o end
end
function expression_mt.__add(a, b)
  return setmetatable(
    {eval=function(vars) return eval(a, vars) + eval(b, vars) end},
    expression_mt)
end
function expression_mt.__pow(a, b)
  return setmetatable(
    {eval=function(vars) return eval(a, vars) ^ eval(b, vars) end},
    expression_mt)
end
function expression_mt.__call(a, vars)
  return a.eval(vars)
end

-- auto-create expression objects from globals
local G_mt = {}
function G_mt:__index(k)
  return Expression(k)
end
setmetatable(_G, G_mt)

-- example usage:

local function sum(expr, first, last)
  local result = 0
  for x=first,last do
    result = result + expr{x=x}
  end
  return result
end

print( sum(x^2 + 1, 1, 10) )  --> 395
