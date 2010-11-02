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

local v = {[0]='a'} -- index as 0 is not in the array part of table
print(v[0]) -- outputs: a
print(#v) -- outputs: 0 
