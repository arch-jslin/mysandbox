-- KISS conway's game of life impl ---------------------------
-- added LuaJIT FFI usages -----------------------------------
  -- auto-padding and copy the edge for wrap around.

local ffi = require "ffi"

local randomseed, rand, floor, abs = math.randomseed, math.random, math.floor, math.abs
local band, rsh, lsh = bit.band, bit.rshift, bit.lshift
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


local function neighbor_count(old, y, x, h, w)
  local count = ( old[y-1][x-1] + old[y-1][x] + old[y-1][x+1] ) +
                ( old[ y ][x-1] +               old[ y ][x+1] ) +
                ( old[y+1][x-1] + old[y+1][x] + old[y+1][x+1] )
  return count
end

--local rule1 = ffi.new("char[9]", {0, 0, 1, 1, 0, 0, 0, 0, 0})
--local rule2 = ffi.new("char[9]", {0, 0, 0, 1, 0, 0, 0, 0, 0})
--what if we need different rule sets? how to do that with bitwise trick??
local function ruleset(now, count)
  return band(rsh(lsh(now, 2) + 8, count), 1)
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

local function grid_iteration(old, new, w, h, opt)

  if opt then jit.off(true, true) end 

  w, h = w or 15, h or 15
  wrap_padding(old, w, h)
  for y = 1, h do
    for x = 1, w do
      new[y][x] = ruleset( old[y][x], neighbor_count(old, y, x) )
    end
  end
  -- new and old can be used interchangably, no need to copy here
end

---------

local now = new_grid(20, 20)
local new = new_grid(20, 20)
randomseed(os.time())

local function test_by_hand()
  for i=1, 80 do
    now[random(20)+1][random(20)+1] = 1  -- random seeding 45 cells
  end
  local i, index = 0, 0
  local grids = {}
  grids[0], grids[1] = now, new
  while true do
    index = i % 2
    grid_iteration( grids[index], grids[bit.bxor(index, 1)], 20, 20 )
    grid_print( grids[bit.bxor(index, 1)], 20, 20)
    io.read()
    i = i + 1
  end
end

local function bench_test(n)
  for i=1, 80 do
    now[random(20)+1][random(20)+1] = 1  -- random seeding 45 cells
  end
  local function performance_test(n, now, new)
    print("Memory usage before first run: "..collectgarbage("count").." KiB.")
    local index = 0
    local grids = {}
    grids[0], grids[1] = now, new
    for i = 0, n-1 do
      index = i % 2
      grid_iteration(grids[index], grids[bit.bxor(index, 1)], 20, 20)
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