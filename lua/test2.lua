-- some basic/rudimentary table usages ------------------

local t = {}
t[1] = 10
t[0.5] = 15
t["1"] = 20
print( #t )

for k,v in pairs(t) do print(k,v) end
print("---")
for k,v in ipairs(t) do print(k,v) end
print("---")

local u = {}
for i = -10, 10 do u[i] = i end
for k,v in pairs(u) do print(k,v) end
print("---")
for k,v in ipairs(u) do print(k,v) end
print("Number of elements in u's array: " .. #u)
print("---")

local v = {[0]='a'} -- index as 0 is not in the array part of table
print(v[0]) -- outputs: a
v[#v+1] = 'cc'
print(#v) -- outputs: 1
v[500] = 2
print(#v)
for k,v in pairs(v) do print(k,v) end
print("---")
for k,v in ipairs(v) do print(k,v) end
print("max index of table v: " .. table.maxn(v))
print("---")

local i = 10; local j = "10"; local k = "+10"
v[i] = "aaa"
v[j] = "bbb"
v[k] = "ccc"
print( v[i]..v[j]..v[k]..v[tonumber(j)]..v[tonumber(k)] )
print( "---\n" )

-- Expressions worth noting -----------------------------

local x = math.pi
print( x - x%0.01 ) -- a%b == a - floor(a/b)*b

-- Some control structure practices ---------------------

local i = 0 -- faster than numeric for
while i < 10 do
  local j = 0
  while j < i do
    io.write "*"; 
    j = j + 1
  end
  i = i + 1
  print ""
end

for i=0,10 do
  for j=0, 10-i do io.write " " end
  for j=0, i do io.write "*" end
  print ""
end

local line
repeat
  line = io.read()
until line ~= ""
print(line)

print(math.huge) -- this is funny 

-- builds a reverse table
local reverse_of = function(t)
  local res = {}
  for k,v in pairs(t) do res[v] = k end
  return res
end

