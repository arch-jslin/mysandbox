local ffi = require "ffi"

function new_array(w, h)
  local multiarray = ffi.new("char["..h.."]["..w.."]")
  for i = 0, h-1 do 
    --multiarray[i] = ffi.new("char[?]",w)
    for j = 0, w-1 do
      multiarray[i][j] = i*h + j
    end
  end
  return multiarray
end

local myarray = new_array(15, 10)

function print_array(a, w, h)
  for i = 0, h-1 do
    for j = 0, w-1 do
      io.write(string.format("%4d", a[i][j]))
    end
    print''
  end
end

while true do
  print_array(myarray, 15, 10)
  io.read()
end