
local function debug_msg()
  print(debug.getinfo(2,'l').currentline)
end
    
local function test()
  print('hello')
  debug_msg()
end
    
test()
    