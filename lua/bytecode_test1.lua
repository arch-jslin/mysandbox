-- test for loadstring and native string closure bytecode differences --
-- LuaJIT-beta5 --

local bench = require 'bench' . bench

local stash = setmetatable({}, {__mode = "k"})
local get = function(self)
  return stash[self].value
end

local str, get2
for _,v in ipairs({"value"}) do 
  str = "return function(s) return function(self) return s[self]."..v.." end end"
  get2= loadstring(str)()(stash)
end

local o2 = {}
stash[o2] = {}
stash[o2].value = 2

local function test1() 
  local o1 = {get = get}
  stash[o1] = {value = 1}
  for i=1, 100000000 do 
    o1:get()
  end
end

local function test2()
  local o2 = {get = get2}
  stash[o2] = {value = 2}
  for i=1, 100000000 do
    o2:get()
  end
end

bench("Test1: ", function() return test1() end, 10)
bench("Test2: ", function() return test2() end, 10)
