-- which one is better? benchmark 2D arrays ---------------

package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path

local array2d = require 'pl.array2d'
local NUM = 2000

local function bench(desc, f)
  local t = os.clock()
  f()
  print( desc or "", os.clock() - t )
end

local function init_real2dtable(n, m)
  local mt = {}
  for i=1, n do 
    mt[i] = {}
    for j=1, m do
      mt[i][j] = i*m + j
    end
  end
  return mt
end

local function init_fake2dtable(n, m)
  local mt = {}
  for i=1, n do
    for j=1, m do
      mt[(i-1)*m + j] = i*m + j
    end
  end
  return mt
end

bench("init_real2dtable: ", function() return init_real2dtable(NUM,NUM) end)
bench("init_fake2dtable: ", function() return init_fake2dtable(NUM,NUM) end)

local function array_getter_2d(n, m)
  local mt = init_fake2dtable(n, m)
  return function(i,j) 
    return mt[(i-1)*m + j]
  end
end

local dummy = nil
local mt1 = init_real2dtable(NUM,NUM)
local mt2 = array_getter_2d(NUM,NUM)

local function iterate_through_array1(n, m)
  for i=1, n do
    for j=1, m do
      dummy = mt1[i][j] -- direct_access
    end
  end
end

local function iterate_through_array2(n, m)
  for i=1, n do
    for j=1, m do
      dummy = mt2(i,j) -- it's a function!
    end
  end
end

bench("iterate_real2dtable: ", function() return iterate_through_array1(NUM,NUM) end)
bench("iterate_fake2dtable: ", function() return iterate_through_array2(NUM,NUM) end)

-- result: --
--[[ 
  This is a interesting case .... real 2d array initializes slower
  because of those additional tables. However the difference is less 
  than a half of the time. And without any doubt, access array
  through function interface is slower too (the function call),
  and more implementation code.
  
  Since the 1d-simulated 2d array might run into other troubles
  in the future (like what would you do if you want to cache a row?)
  using simulated 2d array doesn't seem to be a good way of doing it.
--]]

print "--now we test for iterator/foreach 2d"

local function foreach2d(t, proc)
  local x, y = 1, 1
  local w, h = #t[1], #t
  for y = 1, h do
    for x = 1, w do
      proc(t[y][x])
    end
  end
end

local function iter2d(t)
  local x, y = 0, 1
  local w, h = #t[1], #t
  return function()
    x = x + 1
    if x > w then 
      y = y + 1
      x = 1 
      if y > h then return nil end
    end
    return t[y][x]
  end
end

local function iterate_through_array3()
  foreach2d(mt1, function(v)
    dummy = v
  end)
end

local function iterate_through_array4()
  for v in iter2d(mt1) do
    dummy = v
  end
end

local function iterate_through_array5()
  for v in array2d.iter(mt1) do
    dummy = v
  end
end

local function iterate_through_array6()
  array2d.forall(mt1, function(row, j)
    dummy = row[j]
  end)
end

bench("iterate_real2dtable_using_foreach2d: ", function() return iterate_through_array3() end)
bench("iterate_real2dtable_using_iter2d: ", function() return iterate_through_array4() end)
bench("iterate_real2dtable_using_pl.array2d.iter: ", function() return iterate_through_array5() end)
bench("iterate_real2dtable_using_pl.array2d.forall: ", function() return iterate_through_array6() end)