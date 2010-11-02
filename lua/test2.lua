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

-- Basics of functions.. ---------------------------


