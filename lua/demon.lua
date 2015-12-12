local bid = {1, 2, 3}
local order = {1, 2, 3,4,5,6}

math.randomseed(os.time())

local function random(n)
  return math.floor(math.random()*n)
end

local function shuffle(t)
  for i = 1, #t do 
    local temp = random(#t) + 1
    local swap = t[temp]
    t[temp] = t[i]
    t[i] = swap
  end
  return t
end

print( unpack(shuffle(bid)) )
print( unpack(shuffle(order)) )

