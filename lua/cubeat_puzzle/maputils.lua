
local MapUtils = {}
local floor = math.floor

local function analyze(expr)
  return floor(expr / 10000),        -- length if horizontal
         floor(expr % 10000 / 1000), -- length if vertical
         floor(expr % 1000 / 100),   -- reserved
         floor(expr % 100 / 10),     -- pos x
         floor(expr % 10)            -- pos y
end

local function add_chain_to_map(map, expr, chain)
  local lenH, lenV, _, x, y = analyze(expr)
  if lenH > 0 then
    MapUtils.pushup_horizontally(map, x, y, lenH, chain)
  elseif lenV > 0 then
    MapUtils.pushup_vertically(map, x, y, lenV, chain)
  end
end

function MapUtils.pushup_horizontally(map, x, y, len, chain)
  if y + 1 > map.height then return false end 
  for i = x, x + len - 1 do
    for j = map.height - 1, y, -1 do
      map[j+1][i] = map[j][i]
    end
    map[y][i] = chain or 0
  end
  return true
end

function MapUtils.pushup_vertically(map, x, y, len, chain)
  if y + len > map.height then return false end
  for j = map.height - len, y, -1 do
    map[j+len][x] = map[j][x]
  end
  for j = y, y + len - 1 do
    map[j][x] = chain or 0
  end
  return true
end

function MapUtils.gen_map_from_exprs(exprs)
  local map = MapUtils.create_map(exprs.width, exprs.height)
  for chain,v in ipairs(exprs) do
    add_chain_to_map(map, v, chain)
  end
  return map
end

function MapUtils.create_map(w, h)
  local map = {}
  map.width = w
  map.height = h
  for y = 1, h do
    map[y] = {}; for x = 1, w do map[y][x] = 0 end
  end
  return map
end

function MapUtils.display(map)
  for y = map.height, 1, -1 do
    for x = 1, map.width do
      io.write(string.format("%2d", map[y][x]))
    end
    print()
  end
end

function MapUtils.create_

return MapUtils
