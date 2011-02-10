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
  for y = 1, h+2 do
    grid[y] = {}
    for x = 1, w+2 do
      grid[y][x] = 0
    end
  end
  return grid
end

local function grid_print(grid, w, h)
  w, h = w or 15, h or 15
  if not grid then return end
  for y = 2, h+1 do
    for x = 2, w+1 do 
      io.write(string.format("%d ", grid[y][x]))
    end
    print()
  end
end

local function neighbor_count(old, y, x, h, w)
  --[[local count = 0
  for i=1, #dir do
    local ny, nx = y + dir[i][1], x + dir[i][2]
    if ny < 1 then ny = h
    elseif ny > h then ny = 1 end
    if nx < 1 then nx = w
    elseif nx > w then nx = 1 end
    if old_grid[ny][nx] > 0 then count = count + 1 end
  end]]
  local count = (old[y-1][x-1] + old[y-1][x] + old[y-1][x+1]) +
                (old[y][x-1]   +               old[y][x+1])   +
                (old[y+1][x-1] + old[y+1][x] + old[y+1][x+1])
  return count
end

local rule1 = {0, 0, 1, 1, 0, 0, 0, 0, 0}
local rule2 = {0, 0, 0, 1, 0, 0, 0, 0, 0}
local function ruleset(now, n)
  return now > 0 and rule1[n+1] or rule2[n+1]
end

local function wrap_padding(old, w, h)
  w, h = w or 15, h or 15
  -- side wrapping.
  for x = 3, w do 
    old[h+2][x] = old[ 2 ][x]
    old[ 1 ][x] = old[h+1][x]
  end
  for y = 3, h do 
    old[y][w+2] = old[y][ 2 ]
    old[y][ 1 ] = old[y][w+1]
  end
  -- .. and corner wrapping, obviously I am too stupid.
  local tl, tr, bl, br = old[2][2], old[2][w+1], old[h+1][2], old[h+1][w+1]
  old[2][w+2], old[h+2][2], old[h+2][w+2] = tl, tl, tl
  old[2][1],   old[h+2][1], old[h+2][w+1] = tr, tr, tr
  old[1][2],   old[1][w+2], old[h+1][w+2] = bl, bl, bl
  old[1][1],   old[1][w+1], old[h+1][1]   = br, br, br
end

local function grid_iteration(old_grid, new_grid, w, h)
  w, h = w or 15, h or 15
  wrap_padding(old_grid)
  for y = 2, h+1 do
    for x = 2, w+1 do
      new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x, h, w) )
    end
  end
  for y = 1, h+2 do 
    for x = 1, w+2 do 
      old_grid[y][x] = new_grid[y][x] -- grid data copy
      new_grid[y][x] = 0              -- clean new grid data
    end
  end
end

---------

local now = new_grid(20, 20)
local new = new_grid(20, 20)
randomseed(os.time())

local function test_by_hand()
  for i=1, 80 do
    now[random(20)+2][random(20)+2] = 1  -- random seeding
  end

  while true do
    grid_iteration(now, new, 20, 20)
    grid_print(now, 20, 20)
    io.read()
  end
end

local function bench_test(n)
  for i=1, 80 do
    now[random(20)+2][random(20)+2] = 1  -- random seeding
  end
  local function performance_test(n, now, new)
    print("Memory usage before first run: "..collectgarbage("count").." KiB.")
    for i = 1, n do
      grid_iteration(now, new, 20, 20)
    end
    print("Memory usage after last run: "..collectgarbage("count").." KiB.")
  end
  grid_print(now, 20, 20)
  bench(string.format("Conway's Game of Life %d iterations: ", n), 
        function() return performance_test(n, now, new) end)
  grid_print(now, 20, 20)
end

bench_test(100000)

--test_by_hand()