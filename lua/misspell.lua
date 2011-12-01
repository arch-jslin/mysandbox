
local input = arg[1]

math.randomseed(os.time())
local function random(n) return math.floor(math.random()*n) end
local function chararray(w) 
  local t = {}; 
  for i = 1, #w do t[i] = w:sub(i,i) end 
  return t
end

local function misspell(w)
  local t = chararray(w)
  for i = 2, #t-1 do
    local dest = random(#t-i-2) + i + 1
    t[i], t[dest] = t[dest], t[i]
  end
  return table.concat(t, "")
end

local output = input:gsub("%w+", function(w)  
  if #w > 3 then
    return misspell(w)
  end
  return w
end)

print "----------------------------"
print(output) 
