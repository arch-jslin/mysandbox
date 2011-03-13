
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = require 'maputils'
local List = require 'pl.List'
local Test = require 'pl.test'
local tablex = require 'tablex2'
local Helper = require 'helpers'
local random, Stack = Helper.random, Helper.stack

-- 實際在檢查上，具現化前還要看 intersects 下去會不會造成 column 高度爆炸，
-- 或是 row 浮空了

-- 　function chain_limit
-- 　　//找出能把 30011 截斷的組合 => 故得知查表「A 能被 a b c 截斷」較有效益：
-- 　　stack = {30011} //從能被放到最底下的組合中隨機取一個出來當底
-- 　　iterate on「A 能被 a, b, c, ... 截斷」之 a, b, c；A 為 stack[top]
-- 　　　push one of {a,b,c...} into stack
-- 　　　依照謎題表示法具現盤面，檢查：
-- 　　　不能有人浮空
-- 　　　　(不用具現盤面也能檢查？我可以 keep track 目前盤面每個 row 的範圍，
-- 　　　　 並在用謎題表示法的階段就剔除擺下去一定會浮空者)
-- 　　　不能有 invoke (在還沒上色的情況下會有這問題嗎？)
-- 　　　iterate on colors
-- 　　　　放入發火點，並給該段上色 (必需考慮發火點顏色)，驗證正確性：
-- 　　　　連同發火點考慮，不能有 invoke
-- 　　　　拿掉發火點並測試能否跑到全消盤面，不能剩下東西
-- 　　　　if 都沒剩下 then ++chain and break loop
-- 　　　end
-- 　　　if 所有顏色都試過還是失敗，pop stack
-- 　　　if time >= time_limit then return nil to indicate generation failed
-- 　　　if chain >= chain_limit then break loop
-- 　　end
-- 　　if chain < chain_limit return nil to indicate generation failed
-- 　　將謎題表示式具現化成盤面
-- 　　return 盤面
-- 　end 

math.randomseed(os.time())

local PuzzleGen = {}

function PuzzleGen:init(chain_limit, w, h)
  self.chain_limit = chain_limit
  self.w = w
  self.h = h
  self.row_ranges = {}
  self.heights = {}
  self.chains = Stack()
  self.colors = Stack()
  self.intersects_of, self.starter = MapUtils.create_intersect_sheet(w, h)
  for i = 1, h do
    self.row_ranges[i] = {s = w, e = 0}
  end
  for i = 1, w do 
    self.heights[i] = 0
  end
  for k,v in pairs(self.intersects_of) do
    tablex.shuffle(v) -- randomize
  end
  self.inited = true
end

function PuzzleGen:update_ranges_heights()
  --print("stack: "..self.chains.size )
  local lenH, lenV, _, x, y = MapUtils.analyze( self.chains:top() )
  if lenH > 0 then
    for i = x, x + lenH - 1 do
      self.heights[i] = self.heights[i] + 1
    end
    if self.row_ranges[y].s > x            then self.row_ranges[y].s = x end
    if self.row_ranges[y].e < x + lenH - 1 then self.row_ranges[y].e = x + lenH - 1 end
  elseif lenV > 0 then
    self.heights[x] = self.heights[x] + lenV
    -- it's impossible for vertical combinations to expand row ranges
  end
end

function PuzzleGen:check_float(c)
  local lenH, lenV, _, x, y = MapUtils.analyze(c)
  if y > 1 then
    if x < self.row_ranges[y-1].s or x + lenH - 1 > self.row_ranges[y-1].e then
      return true
    end
  end
  return false
end

function PuzzleGen:check_too_high(c)
  local lenH, lenV, _, x, y = MapUtils.analyze(c)
  if lenH > 0 then
    for i = x, x + lenH - 1 do
      if self.heights[i] + 1 > self.h then return true end
    end
  elseif lenV > 0 then
    if self.heights[x] + lenV > self.h then return true end
  end
  return false
end

function PuzzleGen:add_answer()
  local lenH, lenV, color, x, y = MapUtils.analyze(self.chains:top())
  local x1, y1
  --print("trying to add answer for: ")  
  --MapUtils.display( MapUtils.gen_map_from_exprs(self.w, self.h, self.chains) )
  --print()
  if lenH > 0 then
    x1 = random(lenH) + x
    y1 = random(y) + 1
  elseif lenV > 0 then
    x1 = x
    y1 = random(lenV) + y
  end
  if self:check_too_high(10000 + x1*10 + y1) then return false end
  self.chains:push(10000 + x1*10 + y1)
  return true
end

function PuzzleGen:next_chain()
  local intersects = self.intersects_of[ self.chains:top() ]
  local i = 1
  while intersects[i] do
    local c = intersects[i]
    if not self:check_float(c) and not self:check_too_high(c) then
      self.chains:push(intersects[i])
      local old_ranges1 = tablex.deepcopy(self.row_ranges)      
      local old_heights1= tablex.deepcopy(self.heights)
      self:update_ranges_heights()
      local ans = self:add_answer()            -- temp
      self.colors:push(self.colors.size + 1)   -- temp
      local new_map = MapUtils.gen_map_from_exprs(self.w, self.h, self.chains)
      if ans and not MapUtils.destroy_chain(new_map) then
        if self.chains.size > self.chain_limit then return end
        self.chains:pop() -- pop only the answer  
        self.colors:pop() 
        -- we have to update the row ranges and heights here too... shit 
        self:next_chain()
        if self.chains.size > self.chain_limit then return end
        self.heights = old_heights1
        self.row_ranges = old_ranges1
      else
        self.chains:pop() if ans then self.chains:pop() end -- pop answer and the last chain ????
        self.colors:pop()
        self.heights = old_heights1
        self.row_ranges = old_ranges1
      end
    end
    i = i + 1
  end
  self.chains:pop() -- pop last chain
  self.colors:pop()
end

function PuzzleGen:generate(chain_limit, w, h)
  w, h = w or 6, h or 10
  if not self.inited then self:init(chain_limit, w, h) end
 
  self.chains:push(self.starter[random(#self.starter)+1])
  self.colors:push(1)
  self:update_ranges_heights()

  self:next_chain()
  
  local res = MapUtils.gen_map_from_exprs(w, h, self.chains)
  return res
end

MapUtils.display( PuzzleGen:generate(16, 6, 10) )

