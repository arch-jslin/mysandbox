-- Another OO Benchmark 6 -----------------------------------------
-- modified from:
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

local bench = require 'bench' . bench

local function inspect(t, indent)
  indent = indent or 0
  local heading = indent > 0 and string.rep(" ", indent) or ""
  for k,v in pairs(t) do
    if type(v) == "table" then 
      if v == t then io.write(heading..k.."\tself\n")
      else io.write(heading..k.."\t"..tostring(v).."\n"); inspect(v, indent+8) end
    else io.write(heading..k.."\t"..tostring(v).."\n") end
  end
end

local function shallow_merge(s, d) 
  if s == nil then return end
  for k,v in pairs(s) do d[k] = v end 
end
local function deepcopy(t)
    if type(t) ~= 'table' then return t end
    local mt = getmetatable(t)
    local res = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            v = deepcopy(v)
        end
        res[k] = v
    end
    setmetatable(res,mt)
    return res
end


local function union(a, b)
  local dest = {}
  shallow_merge(a, dest); 
  shallow_merge(b, dest); 
  return dest
end

local Klass, Scope = nil, {}
do
  function Scope.reader(methods, list, scoped)
    if list == nil then return end
    for _,v in ipairs(list) do
      local code = "local stash = ...; return function(self) return stash[self]."..v.." end"
      methods["get"..v] = loadstring(code)(scoped)
    end
  end
  
  function Scope.writer(methods, list, scoped)
    if list == nil then return end
    for _,v in ipairs(list) do
      local code = "local stash = ...; return function(self, v) stash[self]."..v.." = v end"
      methods["set"..v] = loadstring(code)(scoped)
    end    
  end
  
  function Scope.accessor(methods, list, scoped)
    Scope.reader(methods, list, scoped)
    Scope.writer(methods, list, scoped)
  end
  
  local function MakeClass(spec) 
    local class = {}
    local private_ = spec.private_scope or setmetatable({}, {__mode = "k"})
    spec.private, spec.protected, spec.public = spec.private or {}, spec.protected or {}, spec.public or {}
    spec.public.init = spec.public.init or function(self, data) end -- default constructor
    class.super = spec.super or {}
    class.private, class.protected, class.public = {}, {}, {}

    for _,superclass in ipairs(class.super) do
      class.public = union(class.public, superclass.public)
      class.protected = union(class.protected, superclass.protected)
    end
    
    class.public = union(class.public, spec.public)
    class.protected = union(class.protected, spec.protected)
    class.private = union(class.private, spec.private)
    
    --function Scope.gen_accessors(scope)
      Scope.reader(class.public, spec.public.reader, private_)
      Scope.writer(class.public, spec.public.writer, private_)
      Scope.accessor(class.public, spec.public.accessor, private_)
    --end
    setmetatable(class, {__index = class.public})
    local private_mt = {__index = class.private}
    class.__index = class
    class.new = function(self, init_list, o)
      init_list, o = init_list or {}, o or {}
      local data, data_inited = {}, false
      for k,v in pairs(init_list) do
        if spec.private[k] or spec.protected[k] then 
          data[k] = v; init_list[k] = nil
          data_inited = true
        elseif spec.public[k] then
          o[k] = v; init_list[k] = nil
        end
      end
      for _,v in ipairs(self.super) do
        v:new(init_list, o)
      end
      if data_inited then
        private_[o] = data 
        setmetatable(data, private_mt)
      end
      setmetatable(o, self)
      o.super = self.super[1] -- let it be this for now
      o:init(data)
      return o 
    end
    return class
  end
  Klass = MakeClass
end --end of Klass module
  
local C = {};
do -- Now this is class defining state -- conceptual compile-time
  local hidden_stash = setmetatable({}, {__mode = "k"}) --private
  C = Klass{
    private_scope = hidden_stash,
    private = {
      hp = 10, mp = 10, some_caled_value = nil,
    },
    protected = {
      update_value = function(self) 
        hidden_stash[self].some_caled_value = self:gethp()*2 + self:getmp()*2
      end
    },
    public = {
      --accessor = {"hp", "mp"},
      --getter = {"some_caled_value"},
      some_public_member = 1,
      gethp  = function(self) return hidden_stash[self].hp end,
      sethp  = function(self, v) hidden_stash[self].hp = v end,
      getmp  = function(self) return hidden_stash[self].mp end,
      setmp  = function(self, v) hidden_stash[self].mp = v end,
      damage = function(self, n) self:sethp(self:gethp() - n) end,
      cast   = function(self, n) self:setmp(self:getmp() - n) end,
    }
  }
  --Scope.gen_accessors(hidden_stash)
end

local C2 = {};
do -- Another Scope for defining derived class
  local hidden_stash = setmetatable({}, {__mode = "k"}) --private
  C2= Klass{
    private_scope = hidden_stash,
    super = {C},
    private = {pp = 100},
    public = {
      gp = 200,
      accessor = {"pp"},
      fireball = function(self, enemy) enemy:damage(5); self:cast(5) end,
      heal     = function(self) self:damage(-5); self:cast(5) end
    }
  }
  --Scope.gen_accessors(hidden_stash)
end

local q = C:new{mp=20}
print("..", q:gethp(), q:getmp())
local p = C2:new{hp=5}
print("..", q.gethp, p.gethp)
print("..", p:gethp(), p:getmp())

local function my_klass1(n)
  local m = C2:new{hp=5}
  local m1= C2:new{mp=20}
  print(m.hp == nil)               -- this must not read anything.
  print(m.some_caled_value == nil) -- this too.
  --print(m:getCalculatedValue())  -- this should do fine.
  for i = 1, n do
    m:fireball(m1)
    m:heal()
  end
end

local function my_klass1_m(n)
  local mariners = {}
  for i = 1, n do
    mariners[i] = C2:new{some_public_number=2, gp=10, hp=5, mp=20}
  end
  print ("Memory in use for "..n.." units: "..collectgarbage ("count").." Kbytes")
end

bench("my_klass1 for 10M iterations: ", function() return my_klass1(10000000) end, 10)
bench("my_klass1 mem-usage: ", function() return my_klass1_m(100000) end)

