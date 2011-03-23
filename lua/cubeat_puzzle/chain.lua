
local floor = math.floor
local Chain3H, Chain4H, Chain5H, Chain3V, Chain4V = {}, {}, {}, {}, {}

function Chain3H:add_chain_to_map(map, num)
  if self.y + 1 > map.height then return false end 
  local color = self.color == 0 and num or self.color
  for y = map.height - 1, self.y, -1 do 
    map[y+1][ self.x ] = map[y][ self.x ] 
    map[y+1][self.x+1] = map[y][self.x+1]
    map[y+1][self.x+2] = map[y][self.x+2]
  end
  map[self.y][ self.x ], map[self.y][self.x+1], map[self.y][self.x+2] = color, color, color
  return true
end

function Chain4H:add_chain_to_map(map, num)
  if self.y + 1 > map.height then return false end 
  local color = self.color == 0 and num or self.color
  for y = map.height - 1, self.y, -1 do 
    map[y+1][ self.x ] = map[y][ self.x ] 
    map[y+1][self.x+1] = map[y][self.x+1]
    map[y+1][self.x+2] = map[y][self.x+2]
    map[y+1][self.x+3] = map[y][self.x+3]
  end
  map[self.y][ self.x ], map[self.y][self.x+1], map[self.y][self.x+2], 
  map[self.y][self.x+3] = color, color, color, color
  return true
end

function Chain5H:add_chain_to_map(map, num)
  if self.y + 1 > map.height then return false end 
  local color = self.color == 0 and num or self.color
  for y = map.height - 1, self.y, -1 do 
    map[y+1][ self.x ] = map[y][ self.x ] 
    map[y+1][self.x+1] = map[y][self.x+1]
    map[y+1][self.x+2] = map[y][self.x+2]
    map[y+1][self.x+3] = map[y][self.x+3]
    map[y+1][self.x+4] = map[y][self.x+4]
  end
  map[self.y][ self.x ], map[self.y][self.x+1], map[self.y][self.x+2], 
  map[self.y][self.x+3], map[self.y][self.x+4] = color, color, color, color, color
  return true
end

function Chain3V:add_chain_to_map(map, num)
  if self.y + 3 > map.height then return false end
  local color = self.color == 0 and num or self.color
  for y = map.height - 3, self.y, -1 do
    map[y+3][self.x] = map[y][self.x]
  end
  map[ self.y ][self.x], map[self.y+1][self.x], map[self.y+2][self.x] = color, color, color
  return true
end

function Chain4V:add_chain_to_map(map, num)
  if self.y + 4 > map.height then return false end
  local color = self.color == 0 and num or self.color
  for y = map.height - 4, self.y, -1 do
    map[y+4][self.x] = map[y][self.x]
  end
  map[ self.y ][self.x], map[self.y+1][self.x], map[self.y+2][self.x], map[self.y+3][self.x] = color, color, color, color
  return true
end

local function analyze(expr)
  return floor(expr / 100),   -- color
         floor(expr % 100 / 10),     -- pos x
         floor(expr % 10)            -- pos y
end

local function ctor_of(proto)
  return function(expr)
    local o = {}
    o.color, o.x, o.y = analyze(expr)
    setmetatable(o, {__index = proto})
    return o
  end
end

return {ctor_of(Chain3H), ctor_of(Chain4H), ctor_of(Chain5H), ctor_of(Chain3V), ctor_of(Chain4V)}
