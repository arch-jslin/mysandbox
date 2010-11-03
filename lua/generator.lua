-- I want a generator working like this

-- encapsulate it in a function
local function foreach(factory, block)
  local _iter, _invariant, _variable = factory()
  while true do
    local var_table = {_iter(_invariant, _variable)}
    _variable = var_table[1]
	if _variable == nil then break end
	  block(unpack(var_table))
  end  
end

local function range_iter(invar, c)
  return c < invar and c+1 or nil
end

local function range(s, e)
  return range_iter, e, s-1 -- s-1 is actually bad!, might underflow!
end

local function range2(s, e)
  local i = s
  local res = nil
  return function()
    if i <= e then
      res = i    
      i = i + 1 
    else 
      res = nil
    end
    return res
  end
end

t = os.clock()
for x in range(1,1000000) do
  local y = x+x
end
print( os.clock() - t ) 

foreach(function() return range(1,5) end,
        function(x) return print(x) end)