-- which one is better? benchmark 2D arrays ---------------

local NUM = 2000

function bench(desc, f)
  local t = os.clock()
  f()
  print( desc or "", os.clock() - t )
end

function init_real2dtable(n, m)
  local mt = {}
  for i=1, n do 
    mt[i] = {}
    for j=1, m do
      mt[i][j] = 0
    end
  end
  return mt
end

function init_fake2dtable(n, m)
  local mt = {}
  for i=1, n do
    for j=1, m do
      mt[(i-1)*m + j] = 0
    end
  end
  return mt
end

bench("init_real2dtable: ", function() return init_real2dtable(NUM,NUM) end)
bench("init_fake2dtable: ", function() return init_fake2dtable(NUM,NUM) end)

function array_getter_2d(n, m)
  local mt = init_fake2dtable(n, m)
  return function(i,j) 
    return mt[(i-1)*m + j]
  end
end

global_dummy = nil
mt1 = init_real2dtable(NUM,NUM)
mt2 = array_getter_2d(NUM,NUM)

function iterate_through_array1(n, m)
  for i=1, n do
    for j=1, m do
      global_dummy = mt1[i][j] -- direct_access
    end
  end
end

function iterate_through_array2(n, m)
  for i=1, n do
    for j=1, m do
      global_dummy = mt2(i,j) -- it's a function!
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
