-- LuaJIT2 beta5 bug? ------------------------------------------

local bench = require 'bench' . bench

local class = {}
do
  local private = setmetatable({}, {__mode = "k"}) -- private scoped properties
  function class.gethp(self) return private[self]["hp"] end
  function class.sethp(self, v) private[self]["hp"] = v end
   
  local k1 = "mp" -- it happens to be closure/upvalue problem ... 
  function class.getmp(self) return private[self][k1] end
  function class.setmp(self, v) private[self][k1] = v end
  
  class.__index = class
  class.new = function(self, o)
    o = o or {}
    private[o] = o
    setmetatable(o, self)
    return o
  end
end
  
local function benchmark_1(n)
  local o = class:new{hp=10, mp=10}
  for i = 1, n do
    o:sethp( o:gethp() + 1 )
  end
end

local function benchmark_2(n)
  local o = class:new{hp=10, mp=10}
  for i = 1, n do
    o:setmp( o:getmp() + 1 )
  end
end

local N = 10000000
bench(string.format("access using string literals, %d times: ", N), 
      function() return benchmark_1(N) end)

bench(string.format("access using upvalues, %d times: ", N), 
      function() return benchmark_2(N) end)
            
