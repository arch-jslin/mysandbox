
local Chain = {}

local function add_chain_to_map3H(self, map, num)
  if self.y + 1 > map.height then return false end 
  local color = o.color == 0 and num or o.color
  for y = map.height - 1, self.y, -1 do 
    map[y+1][ self.x ] = map[y][ self.x ] 
    map[y+1][self.x+1] = map[y][self.x+1]
    map[y+1][self.x+2] = map[y][self.x+2]
  end
  map[y][ self.x ], map[y][self.x+1], map[y][self.x+2] = color, color, color
  return true
end

local function add_chain_to_map4H(self, map, num)
  if self.y + 1 > map.height then return false end 
  local color = o.color == 0 and num or o.color
  for y = map.height - 1, self.y, -1 do 
    map[y+1][ self.x ] = map[y][ self.x ] 
    map[y+1][self.x+1] = map[y][self.x+1]
    map[y+1][self.x+2] = map[y][self.x+2]
    map[y+1][self.x+3] = map[y][self.x+3]
  end
  map[y][ self.x ], map[y][self.x+1], map[y][self.x+2], map[y][self.x+3] = color, color, color, color
  return true
end

local function add_chain_to_map5H(self, map, num)
  if self.y + 1 > map.height then return false end 
  local color = o.color == 0 and num or o.color
  for y = map.height - 1, self.y, -1 do 
    map[y+1][ self.x ] = map[y][ self.x ] 
    map[y+1][self.x+1] = map[y][self.x+1]
    map[y+1][self.x+2] = map[y][self.x+2]
    map[y+1][self.x+3] = map[y][self.x+3]
    map[y+1][self.x+4] = map[y][self.x+4]
  end
  map[y][ self.x ], map[y][self.x+1], map[y][self.x+2], map[y][self.x+3], map[y][self.x+4] = color, color, color, color, color
  return true
end

local function add_chain_to_map3V(self, map, num)
  if self.y + 3 > map.height then return false end
  local color = o.color == 0 and num or o.color
  for y = map.height - 3, y, -1 do
    map[y+3][self.x] = map[y][self.x]
  end
  map[ self.y ][self.x], map[self.y+1][self.x], map[self.y+2][self.x] = color, color, color
  return true
end

local function add_chain_to_map4V(self, map, num)
  if self.y + 4 > map.height then return false end
  local color = o.color == 0 and num or o.color
  for y = map.height - 4, y, -1 do
    map[y+4][self.x] = map[y][self.x]
  end
  map[ self.y ][self.x], map[self.y+1][self.x], map[self.y+2][self.x], map[self.y+3][self.x] = color, color, color, color
  return true
end

local function analyze(expr)
  return floor(expr / 10000),        -- length if horizontal
         floor(expr % 10000 / 1000), -- length if vertical
         floor(expr % 1000 / 100),   -- reserved
         floor(expr % 100 / 10),     -- pos x
         floor(expr % 10)            -- pos y
end

return function(initer)
  local o = {}
  o.lenH, o.lenV, o.color, o.x, o.y = analyze(expr)
  setmetatable(o, {__index = Chain})
  return o
end
