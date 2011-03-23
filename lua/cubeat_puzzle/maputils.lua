
local tablex = require 'pl.tablex'
local random = require 'helpers'.random
local C3H, C4H, C5H, C3V, C4V = unpack(require 'chain')

local MapUtils = {}
local floor = math.floor

function MapUtils.analyze(expr)
  -- return floor(expr / 10000),        -- length if horizontal
         -- floor(expr % 10000 / 1000), -- length if vertical
         -- floor(expr % 1000 / 100),   -- reserved
         -- floor(expr % 100 / 10),     -- pos x
         -- floor(expr % 10)            -- pos y
  return floor(expr[1] / 10000),        -- length if horizontal
         floor(expr[1] % 10000 / 1000), -- length if vertical
         floor(expr[1] % 1000 / 100),   -- reserved
         floor(expr[1] % 100 / 10),     -- pos x
         floor(expr[1] % 10)            -- pos y  
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
    map[y][i] = color
  end
  return true
end

function MapUtils.pushup_vertically(map, x, y, len, color)
  if y + len > map.height then return false end
  for j = map.height - len, y, -1 do
    map[j+len][x] = map[j][x]
  end
  for j = y, y + len - 1 do
    map[j][x] = color
  end
  return true
end

function MapUtils.gen_map_from_exprsx(w, h, exprs)
  local map = MapUtils.create_map(w, h)
  for chain,v in ipairs(exprs) do
    v:add_chain_to_map(map, chain)
  end
  return map
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

local function gen_combinationsH_(c, w, h, len, ctor, starters)
  for y = 1, h do
    for x = 1, w - len + 1 do
      local temp = ctor(x*10 + y)
      table.insert(c, temp)
      if y == 1 then table.insert(starters, temp) end
    end
  end
end

local function gen_combinationsV_(c, w, h, len, ctor)
  for y = 1, h - len do -- don't +1 here, leave last row empty
    for x = 1, w do
      table.insert(c, ctor(x*10 + y))
      -- don't use vertical combinations as starters.
    end
  end
end

local function gen_combinationsx(w, h)
  local c = {}
  local starters = {} -- combinations that can be the "last-invoked" chain.
  gen_combinationsH_(c, w, h, 3, C3H, starters)
  gen_combinationsH_(c, w, h, 4, C4H, starters)
  gen_combinationsH_(c, w, h, 5, C5H, starters)
  gen_combinationsV_(c, w, h, 3, C3V)
  gen_combinationsV_(c, w, h, 4, C4V)
  return c, starters
end

local function gen_combinations(w, h)
  local c = {}
  local starters = {} -- combinations that can be the "last-invoked" chain.
  for len = 3, 5 do -- for these different chain length
    for y = 1, h do
      for x = 1, w - len + 1 do
        table.insert(c, {10000*len + x*10 + y}) -- horizontal
        if y == 1 then table.insert(starters, c[#c]) end
      end
    end
  end
  for len = 3, 4 do -- VERTICAL 5's WILL NEVER BE USABLE!!!!!
    for y = 1, h - len do
      for x = 1, w do
        table.insert(c, {1000*len + x*10 + y})  -- vertical
        -- don't use vertical combinations as starters.
      end
    end
  end
  return c, starters
end

local function list_of_intersectx(key, combinations, height_limit) -- combinations should be immutable
  key.intersects = {}
  for _,v in ipairs(combinations) do 
    key:intersect_add(v, height_limit) -- it will just simply insert it if passed
  end 
  return intersects
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
    elseif lenV1 > 0 and lenV0 > 0 and lenV0 + lenV1 + y0 - 1 <= height_limit then 
      -- vertical intercept vertical
      if x1 == x0 then
        if lenV0 == 3 and (y1 == y0 + 1 or y1 == y0 + 2) then
          table.insert(intersects, v)
        elseif lenV0 == 4 and y1 == y0 + 2 then
          table.insert(intersects, v)
        end
      end
    elseif lenH1 > 0 and lenV0 > 0 then               
      -- horizontal intercept vertical
      if x1 + lenH1 > x0 and x1 <= x0 then
        if lenV0 == 3 and (y1 == y0 + 1 or y1 == y0 + 2) then
          table.insert(intersects, v)
        elseif lenV0 == 4 and y1 == y0 + 2 then
          table.insert(intersects, v)
        end
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

function MapUtils.create_intersect_sheetx(w, h)
  w = (w > 9  and 9  or w) or 6 
  h = (h > 10 and 10 or h) or 10
  local c, starters = gen_combinationsx(w, h-1)
  local intersects_of = {}
  local counter = 0
  for _, v in ipairs(c) do
    intersects_of[v] = list_of_intersectx(v, c, h)
    counter = counter + 1
  end
  return intersects_of, starters, counter
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

local function list_of_answers(key)
  local answers = {}
  local lenH, lenV, _, x, y = MapUtils.analyze(key)
  local i = 1
  for color = 1, 4 do
    if lenH == 3 then
      for y1 = 1, y do 
        table.insert(answers, {10000 + color*100 + x*10 + y1})
        table.insert(answers, {10000 + color*100 + (x+1)*10 + y1})
        table.insert(answers, {10000 + color*100 + (x+2)*10 + y1})
      end
    elseif lenH == 4 then
      for y1 = 1, y do 
        table.insert(answers, {10000 + color*100 + (x+1)*10 + y1})
        table.insert(answers, {10000 + color*100 + (x+2)*10 + y1})
      end
    elseif lenH == 5 then
      for y1 = 1, y do 
        table.insert(answers, {10000 + color*100 + (x+2)*10 + y1})
      end
    elseif lenV == 3 then
      table.insert(answers, {10000 + color*100 + x*10 + y+1})
      table.insert(answers, {10000 + color*100 + x*10 + y+2})
    elseif lenV == 4 then
      table.insert(answers, {10000 + color*100 + x*10 + y+2})
    end
  end
  return answers
end

function MapUtils.create_answers_sheet(intersects_of, w, h)
  w = (w > 9  and 9  or w) or 6 
  h = (h > 10 and 10 or h) or 10
  local answers_of = {}
  local counter = 0
  for k, _ in pairs(intersects_of) do
    answers_of[k] = list_of_answers(k)
    counter = counter + 1
  end
  return answers_of, counter
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
        local res1 = do_check_chain_v(map, x, y)
        local res2 = do_check_chain_h(map[y], x)
        if res1 or res2 then return true end
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
        res, len = do_check_chain_h(map[y], x)
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
