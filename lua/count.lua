
local f = io.open("ans.txt")
local s1 = f:read()
local s2 = f:read():upper()

local function count(s)
  local t = {}
  for w in s:gmatch("%a") do
    t[w] = (t[w] or 0) + 1
  end
  return t
end

local function output(t)
  for k, v in pairs(t) do
    print(k, v)
  end
  print()
end

output(count(s1))
output(count(s2))
