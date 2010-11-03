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

-- equivalent while statement --
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

-- Stateless iterators --------------------------------------

for k,v in next, t do
  print(k, v)
end

--linked list from Lua book
local function getnext(list, node)
  return not node and list or node.next
end

function traverse(list)
  return getnext, list,     nil
end   -- ^^ iter  ^^ invar  ^^ control var (counter)

list = nil
for line in io.lines() do
  list = {val = line, next = list}  -- this will make it a stack
end

for node in traverse(list) do
  print(node.val)
end

-- if the state is more complex, the invariant can be the state itself,
-- state can change, but the real invariant is the reference to state.
-- otherwise use closures, it should be cheaper compare to tables). 
-- (From Pil 7.4 Summary)




