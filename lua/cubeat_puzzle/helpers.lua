
local Helper = {}

function push(self, v) table.insert(self, v); self.top = self.top + 1 end
function pop (self)    local r = self[self.top]; self.top = self.top - 1; return r end
function display(self) for i = 1, self.top do print(i, self[i]) end end

function Helper.stack() 
  local stack = {}
  stack.top = 0
  stack.push    = push
  stack.pop     = pop
  stack.display = display
  return stack  
end

function Helper.random(n) 
  n = n or 1
  return math.floor(math.random()*math.abs(n)) 
end

return Helper
