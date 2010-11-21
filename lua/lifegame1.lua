-- KISS conway's game of life impl ---------------------------

local randomseed, rand, floor, abs = math.randomseed, math.random, math.floor, math.abs
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

function bench(desc, f)
  local t = os.clock()
  f()
  print( desc or "", os.clock() - t )
end

-------------

local function new_grid(w, h) 
  local grid = {}
  w, h = w or 15, h or 15
  for y = 1, h do
    grid[y] = {}
    for x = 1, w do
      grid[y][x] = 0
    end
  end
  return grid
end

local function grid_print(grid, w, h)
  w, h = w or 15, h or 15
  if not grid then return end
  for y = 1, h do
    for x = 1, w do 
      io.write(string.format("%d ", grid[y][x]))
    end
    print()
  end
end

local dir = {{-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1}}
local function neighbor_count(old_grid, y, x, h, w)
  local count = 0
  for i=1, #dir do
    local ny, nx = y + dir[i][1], x + dir[i][2]
    if ny < 1 then ny = h
    elseif ny > h then ny = 1 end
    if nx < 1 then nx = w
    elseif nx > w then nx = 1 end
    if old_grid[ny][nx] > 0 then count = count + 1 end
  end
  return count
end

local rule1 = {0, 0, 1, 1, 0, 0, 0, 0, 0}
local rule2 = {0, 0, 0, 1, 0, 0, 0, 0, 0}
local function ruleset(n, now)
  return now > 0 and rule1[n+1] or rule2[n+1]
end

local function grid_iteration(old_grid, new_grid, w, h)
  w, h = w or 15, h or 15
  for y = 1, h do
    for x = 1, w do
      new_grid[y][x] = ruleset( neighbor_count(old_grid, y, x, h, w), old_grid[y][x] )
    end
  end
  for y = 1, h do 
    for x = 1, w do 
      old_grid[y][x] = new_grid[y][x] -- grid data copy
      new_grid[y][x] = 0              -- clean new grid data
    end
  end
end

---------

local function test_by_hand()
  local now = new_grid(15, 15)
  local new = new_grid(15, 15)
  randomseed(os.time())
  for i=1, 45 do
    now[random(15)+1][random(15)+1] = 1  -- random seeding
  end

  while true do
    grid_iteration(now, new, 15, 15)
    grid_print(now, 15, 15)
    io.read()
  end
end

local function bench_test(n)
  local now = new_grid(15,15)
  local new = new_grid(15,15)
  randomseed(os.time())
  for i=1, 45 do
    now[random(15)+1][random(15)+1] = 1  -- random seeding
  end
  local function performance_test(n, now, new)
    for i = 1, n do
      grid_iteration(now, new, 15, 15)
    end
  end
  grid_print(now, 15, 15)
  bench(string.format("Life's game most easy way %d iter: ", n), 
        function() return performance_test(n, now, new) end)
  grid_print(now, 15, 15)
end

bench_test(20000)

--test_by_hand()