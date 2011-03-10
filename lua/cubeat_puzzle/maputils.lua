
local MapUtils = {}
local floor = math.floor

local function analyze(expr)
  return floor(expr / 10000),        -- length if horizontal
         floor(expr % 10000 / 1000), -- length if vertical
         floor(expr % 1000 / 100),   -- color
         floor(expr % 100 / 10),     -- pos x
         floor(expr % 10)            -- pos y
end

local function add_chain_to_map(map, expr)
  local lenH, lenV, color, x, y = analyze(expr)
  if lenH > 0 then
    MapUtils.pushup_horizontally(map, x, y, lenH, color)
  elseif lenV > 0 then
    MapUtils.pushup_vertically(map, x, y, lenV, color)
  end
end

function MapUtils.pushup_horizontally(map, x, y, len, color)
  if y + 1 > map.height then return false end 
  for i = x, x + len - 1 do
    for j = map.height - 1, y, -1 do
      map[j+1][i] = map[j][i]
    end
    map[y][i] = color or 0
  end
  return true
end

function MapUtils.pushup_vertically(map, x, y, len, color)
  if y + len > map.height then return false end
  for j = map.height - len, y, -1 do
    map[j+len][x] = map[j][x]
  end
  for j = y, y + len - 1 do
    map[j][x] = color or 0
  end
  return true
end

function MapUtils.genmap_from_exprs(exprs)
  local map = MapUtils.create_map(exprs.width, exprs.height)
  for _,v in ipairs(exprs) do
    add_chain_to_map(map, v)
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

return MapUtils
