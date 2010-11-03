-- study the iterator (generators) ---------------------------

local function getval(t) 
  local i = 0
  return function() i = i + 1; return t[i] end
end

local t = {1,2,3,4,5}

-- for in statement --
for v in getval(t) do 
  print(v) 
end 

-- equal while statement --
do
  local _iter, _invariant, _variable = getval(t)
  while true do
    local var_table = {_iter(_invariant, _variable)}
	_variable = unpack(var_table) -- unpack it and only use the first one to evaluate truthiness
	if _variable == nil then break end
	  print(_variable)
  end
end

-- encapsulate it in a function
local function foreach(factory, block)
  local _iter, _invariant, _variable = factory()
  while true do
    local var_table = {_iter(_invariant, _variable)}
	if var_table[1] == nil then break end
	  block(unpack(var_table))
  end  
end

foreach(function() return getval(t) end,
        function(v) return print(v) end)

