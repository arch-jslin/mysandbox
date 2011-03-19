
local tablex = require 'pl.tablex'
local random = require 'helpers'.random

local MapUtils = {}
local floor = math.floor

function MapUtils.analyze(expr)
  return floor(expr / 10000),        -- length if horizontal
         floor(expr % 10000 / 1000), -- length if vertical
         floor(expr % 1000 / 100),   -- reserved
         floor(expr % 100 / 10),     -- pos x
         floor(expr % 10)            -- pos y
end

function MapUtils.add_chain_to_map(map, expr, chain)
  local lenH, lenV, color, x, y = MapUtils.analyze(expr)
  color = color == 0 and chain or color
  if lenH > 0 then
    return MapUtils.pushup_horizontally(map, x, y, lenH, color)
  elseif lenV > 0 then
    return MapUtils.pushup_vertically(map, x, y, lenV, color)
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

function MapUtils.gen_map_from_exprs(w, h, exprs)
  local map = MapUtils.create_map(w, h)
  for chain,v in ipairs(exprs) do
    MapUtils.add_chain_to_map(map, v, chain)
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
      io.write(string.format("%3d", map[y][x]))
    end
    print()
  end
end

-- MEMO: actually the combinations should be an object with specialized 
--       methods for ( len 3 / 4 / 5 ) * ( horizontal / vertical ) respectively
--       it will be far better to write small loops all over the place.
-- *** REFACTOR THIS ***
local function gen_combinations(w, h)
  local c = {}
  local starters = {} -- combinations that can be the "last-invoked" chain.
  for len = 3, 5 do -- for these different chain length
    for y = 1, h do
      for x = 1, w - len + 1 do
        table.insert(c, 10000*len + x*10 + y) -- horizontal
        if y == 1 then table.insert(starters, c[#c]) end
      end
    end
    for y = 1, h - len + 1 do
      for x = 1, w do
        table.insert(c, 1000*len + x*10 + y)  -- vertical
        -- don't use vertical combinations as starters.
      end
    end
  end
  return c, starters
end

-- Warning: UGLY CODE
local function list_of_intersect(key, combinations, height_limit) -- combinations should be immutable
  local intersects = {}
  local lenH0, lenV0, _, x0, y0 = MapUtils.analyze(key)
  local i = 1
  while i < #combinations do
    local v = combinations[i]; i = i + 1
    local lenH1, lenV1, c1, x1, y1 = MapUtils.analyze(v)
    -- tricky things to do here... 
    if lenV1 > 0 and lenH0 > 0 and lenV1 + y0 <= height_limit then                   
      -- vertical intercept horizontal
      if x1 >= x0 + (lenH0-3) and x1 < x0 + 3 and y1 <= y0 then
        table.insert(intersects, v) 
      end
    elseif lenV1 > 0 and lenV0 > 0 and lenV0 < 5 and lenV0 + lenV1 + y0 - 1 <= height_limit then 
      -- vertical intercept vertical
      if x1 == x0 and y1 > y0 and y1 < y0 + 3 then
        table.insert(intersects, v)
      end
    elseif lenH1 > 0 and lenV0 > 0 then               
      -- horizontal intercept vertical
      if x1 + lenH1 > x0 and x1 <= x0 and
         y1 > y0         and y1 < y0 + lenV0
      then
        table.insert(intersects, v)
      end
    elseif lenH1 > 0 and lenH0 > 0 and lenH0 < 5 then 
      -- horizontal intercept horizontal
      if (x1 < x0 and x1 + lenH1 - x0 < 3 and (x0 + lenH0) - (x1 + lenH1) < 3) or -- if x1 is left of x0
         (x1 > x0 and x1 < x0 + 3 and (x0 + lenH0) - x1 < 3)                  -- if x1 is right of x0
      then                                       
        if y1 <= y0 then
          table.insert(intersects, v)
        end        
      end
    end
  end
  return intersects
end

function MapUtils.create_intersect_sheet(w, h)
  w = (w > 9  and 9  or w) or 6 
  h = (h > 10 and 10 or h) or 10
  local c, starters = gen_combinations(w, h-1)
  local intersects_of = {}
  local counter = 0
  for _, v in ipairs(c) do
    intersects_of[v] = list_of_intersect(v, c, h)
    counter = counter + 1
  end
  return intersects_of, starters, counter
end

local function do_check_chain_h(row, x)
  local i = x + 1
  while row[i] == row[i-1] do i = i + 1 end
  local len = i - x
  return (len >= 3), len
end

local function do_check_chain_v(map, x, y)
  local i = y + 1
  while map[i] and map[i][x] == map[i-1][x] do i = i + 1 end
  local len = i - y
  return (len >= 3), len 
end

local function mark_for_delete_h(delete_mark, x, y, len)
  for i = 1, len do
    delete_mark[y][x+i-1] = 1
  end
end

local function mark_for_delete_v(delete_mark, x, y, len)
  for i = 1, len do
    delete_mark[y+i-1][x] = 1
  end
end

function MapUtils.find_chain(map)
  for y = 1, map.height do
    for x = 1, map.width do
      if map[y][x] > 0 then
        local res = do_check_chain_v(map, x, y)
        return res or do_check_chain_h(map[y], x)
      end
    end
  end
  return false
end

function MapUtils.destroy_chain(map)
  local delete_mark = MapUtils.create_map(map.width, map.height)
  local chained, count = false, 0
  for y = 1, map.height do
    for x = 1, map.width do
      if map[y][x] > 0 then
        local res, len = do_check_chain_v(map, x, y)
        if res then
          mark_for_delete_v(delete_mark, x, y, len)
          chained = true
        end
        res, len       = do_check_chain_h(map[y], x)
        if res then 
          mark_for_delete_h(delete_mark, x, y, len)
          chained = true
        end
      end
    end
  end
  for y = 1, map.height do
    for x = 1, map.width do
      if delete_mark[y][x] > 0 then
        map[y][x] = 0
        count = count + 1
      end
    end
  end
  return chained, count
end

function MapUtils.drop_blocks(map)
  for x = 1, map.width do
    local compact_col = {}
    for y = 1, map.height do
      if map[y][x] > 0 then 
        table.insert(compact_col, map[y][x])
        map[y][x] = 0
      end
    end
    for y = 1, #compact_col do
      map[y][x] = compact_col[y]
    end
  end
end

function MapUtils.check_puzzle_correctness(map, level)
  local clone = tablex.deepcopy(map)
  local chained, chain_count, destroy_count = true, -1, 3
  while chained and destroy_count >= 3 and destroy_count <= 5 do
    chained, destroy_count = MapUtils.destroy_chain(clone)
    MapUtils.drop_blocks(clone)
    chain_count = chain_count + 1
  end
  for y = 1, clone.height do
    for x = 1, clone.width do
      if clone[y][x] > 0 then
        return false
      end
    end
  end
  return true and chain_count == level
end

return MapUtils
