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
        
for x in range(1,5) do
  for y in range(1,5) do
    for z in range(1,5) do
      --print(x,y,z)
    end
  end
end

local function clist(block, factory)
  --[[local _iter, _invariant, _variable = factory--]]
  while true do
    local var_table = {factory()--[[_iter(_invariant, _variable)--]]}
    _variable = var_table[1]
	if _variable == nil then break end
	  block(unpack(var_table))
  end
end

clist(function(x) if x > 5 then print(2*x) end end, range2(1,10))
--crude try on list comprehension, it might actually usable
--if adapt to list style or iterator style. (change clist() function)
--that's it for now..
