
local Helper = {}

local function push(self, v) 
  self[self.size+1] = v 
  self.size = self.size + 1 
end

local function pop (self)    
  local r = self[self.size] 
  self[self.size] = nil
  self.size = self.size - 1; 
  return r 
end

local function rear(self)    
  return self[self.size] 
end

local function display(self) 
  for i = 1, self.size do print(i, self[i]) end 
end

function Helper.stack(data) 
  data = data or {}
  local stack = setmetatable({}, {__index = data})
  stack.data = data
  stack.size = 0
  stack.push    = push
  stack.pop     = pop
  stack.top     = rear
  stack.display = display
  return stack  
end

local function permgen(a, n)
  if n == 0 then
    coroutine.yield(a)
  else
    for i=1,n do
      a[n], a[i] = a[i], a[n]
      permgen(a, n - 1)
      a[n], a[i] = a[i], a[n]
    end
  end
end

function Helper.shufflex(a)
  return coroutine.wrap(function() 
    for i = 1, math.floor(#a/2) do
      local pos1 = math.floor(math.random()*#a) + 1
      local pos2 = math.floor(math.random()*#a) + 1
      a[pos1], a[pos2] = a[pos1], a[pos2]
      coroutine.yield(a)
    end
  end)
end

function Helper.random(n) 
  n = n or 1
  return math.floor(math.random()*math.abs(n)) 
end

return Helper
