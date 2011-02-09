-- KISS conway's game of life impl ---------------------------
-- added LuaJIT FFI usages -----------------------------------
  -- The most annoying change would be zero-based / one-based scalar type differences.

local ffi = require "ffi"
ffi.cdef[[

]]

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
  local grid = ffi.new("char*[?]", h)
  w, h = w or 15, h or 15
  for y = 0, h-1 do
    grid[y] = ffi.new("char[?]", w)
    for x = 0, w-1 do
      grid[y][x] = 0
    end
  end
  return grid
end

local function grid_print(grid, w, h)
  w, h = w or 15, h or 15
  if not grid then return end
  for y = 0, h-1 do
    for x = 0, w-1 do 
      io.write(string.format("%d ", grid[y][x]))
    end
    print()
  end
end

local dir = ffi.new("char[8][2]", {{-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1}})
local function neighbor_count(old_grid, y, x, h, w)
  local count = 0
  for i=0, 7 do
    local ny, nx = y + dir[i][0], x + dir[i][1]
    if ny < 0 then ny = h-1
    elseif ny > h then ny = 0 end
    if nx < 0 then nx = w-1
    elseif nx > w then nx = 0 end
    if old_grid[ny][nx] > 0 then count = count + 1 end
  end
  print("count trace: "..count)
  return count
end

local rule1 = ffi.new("char[9]", {0, 0, 1, 1, 0, 0, 0, 0, 0});
local rule2 = ffi.new("char[9]", {0, 0, 0, 1, 0, 0, 0, 0, 0}); 
local function ruleset(now, n)
  return now > 0 and rule1[n] or rule2[n]
end

local function grid_iteration(old_grid, new_grid, w, h)
  w, h = w or 15, h or 15
  for y = 0, h-1 do
    for x = 0, w-1 do
      io.write(string.format("%4d", old_grid[y][x]))
      new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x, h, w) )
    end
    print''
  end
  for y = 0, h-1 do 
    for x = 0, w-1 do 
      old_grid[y][x] = new_grid[y][x] -- grid data copy
      new_grid[y][x] = 0              -- clean new grid data
    end
  end
end

---------

local now = new_grid(15, 15)
local new = new_grid(15, 15)
randomseed(os.time())

local function test_by_hand()
  for i=1, 45 do
    now[random(15)][random(15)] = 1  -- random seeding 45 cells
  end

  while true do
    grid_iteration(now, new, 15, 15)
    grid_print(now, 15, 15)
    io.read()
  end
end

local function bench_test(n)
  for i=1, 45 do
    now[random(15)][random(15)] = 1  -- random seeding 45 cells
  end
  local function performance_test(n, now, new)
    --print("Memory usage before first run: "..collectgarbage("count").." KiB.")
    for i = 1, n do
      grid_iteration(now, new, 15, 15)
    end
    --print("Memory usage after last run: "..collectgarbage("count").." KiB.")
  end
  grid_print(now, 15, 15)
  bench(string.format("Life's game most easy way %d iter: ", n), 
        function() return performance_test(n, now, new) end)
  grid_print(now, 15, 15)
end

bench_test(2)

--test_by_hand()