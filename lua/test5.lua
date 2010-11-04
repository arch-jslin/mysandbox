-- some language facilities -----------------------------

function foo()
  local i = tonumber(io.read())
  if i < 10 then error("HAHAHAHA! attempt to input a value less than 10!", 2)
  else print(i) end
end
foo()

i = tonumber(io.read())
assert(i >= 10, "AHAHAHA! still less than 10!")

local file, msg
repeat
  print "enter a file name:"
  local name = io.read()
  if not name then return end
  file = assert(io.open(name, "r"))
  -- or don't use assert(), handle yourself.
until file

io.close(file)

if pcall(foo) then
  print "No error."
else 
  print "We need to handle error."
end  

stat, msg = pcall(foo)
print(stat, msg)

debug.debug()  -- This is super cool too.......
print(debug.traceback())  -- This is super cool

