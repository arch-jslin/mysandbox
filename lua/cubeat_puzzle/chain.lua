
local floor = math.floor
local Horizontal, Vertical = {}, {}
local Chain3H, Chain4H, Chain5H, Chain3V, Chain4V = 
  {len=3, dir=Horizontal}, 
  {len=4, dir=Horizontal}, 
  {len=5, dir=Horizontal}, 
  {len=3, dir=Vertical}, 
  {len=4, dir=Vertical}

-- add_chain_to_map --
  
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

-- intersect_test --

local intersect_add__ = {}
intersect_add__[Horizontal] = {
  [Horizontal] = function(self, other, height_limit) -- H intersect H
    if (other.x < self.x and other.en - self.x <= 1 --[[and self.en - other.en <= 2]]) or -- if x1 is left of x0
       (other.x > self.x and other.x <= self.x + 2 and self.en - other.x <= 1)        -- if x1 is right of x0
    then                                       
      if other.y <= self.y then
        table.insert(self.intersects, other)
      end        
    end
  end,
  [Vertical]   = function(self, other, height_limit) -- V intersect H
    if other.len + self.y <= height_limit then                   
      if other.x >= self.x + (self.len-3) and other.x <= self.x + 2 and other.y <= self.y then
        table.insert(self.intersects, other) 
      end
    end
  end}
intersect_add__[Vertical]   = {
  [Horizontal] = function(self, other, height_limit) -- H intersect V
    if other.en >= self.x and other.x <= self.x then
      if self.len == 3 and (other.y == self.y + 1 or other.y == self.y + 2) then
        table.insert(self.intersects, other) 
      elseif self.len == 4 and other.y == self.y + 2 then
        table.insert(self.intersects, other) 
      end
    end    
  end,
  [Vertical]   = function(self, other, height_limit) -- V intersect V
    if other.x == self.x then
      if self.len == 3 and (other.y == self.y + 1 or other.y == self.y + 2) then
        table.insert(self.intersects, other) 
      elseif self.len == 4 and other.y == self.y + 2 then
        table.insert(self.intersects, other) 
      end
    end    
  end}

local function intersect_add_(self, other, height_limit)
  intersect_add__[self.dir][other.dir](self, other, height_limit)
end

Chain3H.intersect_add = intersect_add_
Chain4H.intersect_add = intersect_add_
Chain5H.intersect_add = intersect_add_
Chain3V.intersect_add = intersect_add_
Chain4V.intersect_add = intersect_add_

local function analyze(expr)
  return floor(expr / 100),   -- color
         floor(expr % 100 / 10),     -- pos x
         floor(expr % 10)            -- pos y
end

local function ctor_of(proto)
  return function(expr)
    local o = {}
    o.color, o.x, o.y = analyze(expr)
    o.en = proto.dir == Horizontal and o.x + proto.len - 1 or o.y + proto.len - 1
    setmetatable(o, {__index = proto})
    return o
  end
end

return {ctor_of(Chain3H), ctor_of(Chain4H), ctor_of(Chain5H), ctor_of(Chain3V), ctor_of(Chain4V)}
