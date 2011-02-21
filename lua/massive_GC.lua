
ffi = require 'ffi'

local function new_2d_table(w, h) 
  local grid = {}             
  assert(w ~= 0 and h ~= 0)
  for y = 1, h do
    grid[y] = {}
    for x = 1, w do
      grid[y][x] = 0
    end
  end
  return grid
end

local function new_2dVLA(w, h)
  return ffi.new("double["..h.."]["..w.."]");
end

local function new_1dVLA(w, h)
  return ffi.new("double["..h*w.."]");
end

--local array2d = new_2d_table(1000, 1000)
local array2d = new_2dVLA(1000, 1000)
--local array2d = new_1dVLA(1000, 1000)

local function test(csize)
  local length = 0
  local px = 0
  for y = 1, 999 do
    for x = 1, 999 do
      array2d[y][x] = x*csize 
      --array2d[length] = x*csize
      length = length + 1
    end
  end
end

for i = 0, 1000 do
  test(i)
  print("mem usage: "..collectgarbage("count"))
end