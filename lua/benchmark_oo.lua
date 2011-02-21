-- benchmark OO from Lua users wiki --------------------------

-- Benchmarking support.
do
  local function runbenchmark(name, code, count, ob)
    local f = loadstring([[
        local count,ob = ...
        local clock = os.clock
        local start = clock()
        for i=1,count do ]] .. code .. [[ end
        return clock() - start
    ]])
    io.write(f(count, ob), "\t", name, "\n")    
  end

  local nameof = {}
  local codeof = {}
  local tests  = {}
  function addbenchmark(name, code, ob)
    nameof[ob] = name
    codeof[ob] = code
    tests[#tests+1] = ob
  end
  function runbenchmarks(count)
    for _,ob in ipairs(tests) do
      runbenchmark(nameof[ob], codeof[ob], count, ob)
    end
  end
end

function makeob1()
  local self = {data = 0}
  function self:test()  self.data = self.data + 1  end
  return self
end
addbenchmark("Standard (solid)", "ob:test()", makeob1())

local ob2mt = {data = 0}
ob2mt.__index = ob2mt
function ob2mt:test()  self.data = self.data + 1  end
function makeob2()
  return setmetatable({}, ob2mt)
end
addbenchmark("Standard (metatable)", "ob:test()", makeob2())

function makeob3() 
  local self = {data = 0};
  function self.test()  self.data = self.data + 1 end
  return self
end
addbenchmark("Object using closures (PiL 16.4)", "ob.test()", makeob3())

function makeob4()
  local public = {}
  local data = 0
  function public.test()  data = data + 1 end
  function public.getdata()  return data end
  function public.setdata(d)  data = d end
  return public
end
addbenchmark("Object using closures (noself)", "ob.test()", makeob4())

function makeob5()
  local data = 0
  return function(action, v)
    if action == "get" then return data
    elseif action == "set" then data = v
    end    
  end
end
addbenchmark("Single method (PiL 16.5)", "ob('set', ob('get')+1)", makeob5())

addbenchmark("Direct Access", "ob.data = ob.data + 1", makeob1())

addbenchmark("Local Variable", "ob = ob + 1", 0)


runbenchmarks(select(1,...) or 10000000)
