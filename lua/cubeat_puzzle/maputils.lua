
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

local function gen_combinations(w, h)
  local c = {}
  for len = 3, 5 do -- for these different chain length
    for y = 1, h do
      for x = 1, w - len + 1 do
        c[#c+1] = 10000*len + x*10 + y -- horizontal
      end
    end
    for y = 1, h - len + 1 do
      for x = 1, w do
        c[#c+1] = 1000*len + x*10 + y  -- vertical
      end
    end
  end
  return c
end

local function list_of_intersect(key, combinations) -- combinations should be immutable
  local intersects = {}
  local lenH0, lenV0, _, x0, y0 = analyze(key)
  
  for _, v in ipairs(combinations) do
    local lenH1, lenV1, _, x1, y1 = analyze(v)
    -- tricky things to do here... 
    if     lenV1 > 0 and lenH0 > 0 then               -- vertical intercept horizontal
      if x1 >= x0 + (lenH0-3) and x1 < x0 + 3 and y1 <= y0 then
        table.insert(intersects, v) 
      end
    elseif lenV1 > 0 and lenV0 > 0 and lenV0 < 5 then -- vertical intercept vertical
      if x1 == x0 and y1 > y0 and y1 < y0 + 3 then
        table.insert(intersects, v)
      end
    elseif lenH1 > 0 and lenV0 > 0 then               -- horizontal intercept vertical
      if x1 + lenH1 > x0 and x1 <= x0 and
         y1 > y0         and y1 < y0 + lenV0
      then
        table.insert(intersects, v)
      end
    elseif lenH1 > 0 and lenH0 > 0 and lenH0 < 5 then -- horizontal intercept horizontal
      if (x1 < x0 and x1 + lenH1 > x0 and (x0 + lenH0) - (x1 + lenH1) < 3) or -- if x1 is left of x0
         (x1 > x0 and x1 < x0 + 3) then                                       -- if x1 is right of x0
        if y1 <= y0 then
          table.insert(intersects, v)
        end        
      end
    end
  end
  return intersects
end

function MapUtils.create_intersect_sheet(w, h)
  w = (w > 9 and 9 or w) or 6 -- we don't want w be more than 9 here.
  h = (h > 9 and 9 or h) or 9 -- we don't want h be more than 9 here.
  local c = gen_combinations(w, h)
  local intersects_of = {}
  local counter = 0
  for _, v in ipairs(c) do
    intersects_of[v] = list_of_intersect(v, c)
    counter = counter + 1
  end
end

-- 實際在檢查上，具現化前還要看 intersects 下去會不會造成 column 高度爆炸，
-- 或是 row 浮空了

return MapUtils
