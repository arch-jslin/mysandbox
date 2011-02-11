-- KISS conway's game of life impl ---------------------------
-- added LuaJIT FFI usages -----------------------------------
  -- auto-padding and copy the edge for wrap around.

local ffi = require "ffi"

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
  local grid = ffi.new("char[?]["..(w+2).."]", h+2) -- added automatic padding
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

--local dir = ffi.new("char[8][2]", {{-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1}})
local function neighbor_count(old, y, x, h, w)
  --[[local count = 0
  for i=0, 7 do
    local ny, nx = y + dir[i][0], x + dir[i][1]
    if ny < 0 then ny = h-1
    elseif ny >= h then ny = 0 end
    if nx < 0 then nx = w-1
    elseif nx >= w then nx = 0 end
    if old[ny][nx] > 0 then count = count + 1 end
  end]]
  local count = (old[y-1][x-1] + old[y-1][x] + old[y-1][x+1]) +
                (old[y][x-1]   +               old[y][x+1])   +
                (old[y+1][x-1] + old[y+1][x] + old[y+1][x+1])
  return count
end

local rule1 = ffi.new("char[9]", {0, 0, 1, 1, 0, 0, 0, 0, 0});
local rule2 = ffi.new("char[9]", {0, 0, 0, 1, 0, 0, 0, 0, 0}); 
local function ruleset(now, n)
  return now > 0 and rule1[n] or rule2[n]
end

local function wrap_padding(old, w, h)
  w, h = w or 15, h or 15
  -- side wrapping.
  for x = 2, w-1 do 
    old[h+1][x] = old[1][x]
    old[ 0 ][x] = old[h][x]
  end
  for y = 2, h-1 do 
    old[y][w+1] = old[y][1]
    old[y][ 0 ] = old[y][w]
  end
  -- .. and corner wrapping, obviously I am too stupid.
  old[1][w+1], old[h+1][1], old[h+1][w+1] = old[1][1], old[1][1], old[1][1]
  old[1][0],   old[h+1][0], old[h+1][w]   = old[1][w], old[1][w], old[1][w]
  old[0][1],   old[0][w+1], old[h][w+1]   = old[h][1], old[h][1], old[h][1]
  old[0][0],   old[0][w],   old[h][0]     = old[h][w], old[h][w], old[h][w]
end

local function grid_iteration(old, new, w, h)
  w, h = w or 15, h or 15
  wrap_padding(old, w, h)
  for y = 1, h do
    for x = 1, w do
      --new[y][x] = ruleset( old[y][x], neighbor_count(old, y, x, h, w) )
      new[y][x] = bit.band(bit.rshift(bit.lshift(old[y][x],2)+8, neighbor_count(old, y, x, h, w)), 1)
    end
  end
  ffi.copy(old, new, (w+2)*(h+2))
  ffi.fill(new, (w+2)*(h+2)) 
end

---------

local now = new_grid(20, 20)
local new = new_grid(20, 20)
randomseed(os.time())

local function test_by_hand()
  for i=1, 80 do
    now[random(20)+1][random(20)+1] = 1  -- random seeding 45 cells
  end

  while true do
    grid_iteration(now, new, 20, 20)
    grid_print(now, 20, 20)
    io.read()
  end
end

local function bench_test(n)
  for i=1, 80 do
    now[random(20)+1][random(20)+1] = 1  -- random seeding 45 cells
  end
  local function performance_test(n, now, new)
    print("Memory usage before first run: "..collectgarbage("count").." KiB.")
    for i = 1, n do
      grid_iteration(now, new, 20, 20)
    end
    print("Memory usage after last run: "..collectgarbage("count").." KiB.")
  end
  --grid_print(now, 20, 20)
  bench(string.format("Conway's Game of Life %d iterations: ", n),
        function() return performance_test(n, now, new) end)
  --grid_print(now, 20, 20)
end

bench_test(100000)

--test_by_hand()