
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
  self.intersects_of, self.starter = MapUtils.create_intersect_sheet(w, h)
  
  self:reinit()
  
  self.inited = true
end

function PuzzleGen:reinit()
  self.start_time = os.time()
  self.row_ranges = {}
  self.heights = {}
  self.chains = Stack()
  self.colors = Stack()

  for i = 1, self.h do
    self.row_ranges[i] = {s = self.w, e = 0}
  end
  for i = 1, self.w do 
    self.heights[i] = 0
  end
  for k,v in pairs(self.intersects_of) do
    tablex.shuffle(v) -- randomize
  end

  self.chains:push(self.starter[random(#self.starter)+1])
  self.colors:push(1)
  self:update_ranges_heights()
end

function PuzzleGen:update_ranges_heights()
  --print("stack: "..self.chains.size )
  local old_ranges, old_heights = tablex.deepcopy(self.row_ranges), tablex.deepcopy(self.heights)
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
  return old_ranges, old_heights
end

function PuzzleGen:not_float(c)
  local lenH, lenV, _, x, y = MapUtils.analyze(c)
  return y == 1 or (x >= self.row_ranges[y-1].s) and (x + lenH - 1 <= self.row_ranges[y-1].e)
end

function PuzzleGen:not_too_high(c)
  local lenH, lenV, _, x, y = MapUtils.analyze(c)
  if lenH > 0 then
    for i = x, x + lenH - 1 do
      if self.heights[i] + 1 > self.h then return false end
    end
  elseif lenV > 0 then
    if self.heights[x] + lenV > self.h then return false end
  end
  return true
end

function PuzzleGen:add_answer_to(chains)
  local lenH, lenV, color, x, y = MapUtils.analyze(chains:top())
  local x1, y1
  if lenH > 0 then
    x1 = random(lenH) + x
    y1 = random(y) + 1
  elseif lenV > 0 then
    x1 = x
    y1 = random(lenV) + y
  end
  if self:not_too_high(10000 + x1*10 + y1) then
    chains:push(10000 + x1*10 + y1)
    return {x1, y1}
  else 
    return nil
  end
end

local function color_chain(chains, colors)
  local chains_dup = Stack()
  for i,v in ipairs(chains) do chains_dup:push(v + colors[i]*100) end
  return chains_dup
end

-- 失敗。permutation 方法耗費太多時間在無用 permutation；
-- shuffle 法因為使用 coroutine 結果其實效果不彰。
-- 還可能挑戰的方式：不要 shuffle，只隨機換兩三個，然後不要用 iterator 法 (所以不用 coroutine)

-- 其他要馬上加強的點：
-- next_chain 要拆掉，越細越好，確立 operation semantic 而不是一堆 statement
-- 把所有可以先寫死的地方寫死：
--   e.g. 要 if lenV elseif lenH 的地方，要 for i to lenV or lenH 的地方 -- 非常重要
--   有時間再改寫成 meta programming (loadstring) 版本

function PuzzleGen:next_chain()
  local intersects = self.intersects_of[ self.chains:top() ]
  local i = 1
  while os.time() - self.start_time < 1 and intersects[i] do
    local c = intersects[i]
    if self:not_float(c) and self:not_too_high(c) then
      self.chains:push(intersects[i])
      local old_ranges, old_heights = self:update_ranges_heights()
      local ans = self:add_answer_to(self.chains)
      if ans and not MapUtils.destroy_chain(MapUtils.gen_map_from_exprs(self.w, self.h, self.chains)) 
      then
        local colors_dup = tablex.deepcopy(self.colors)
        colors_dup:push((colors_dup:top() % 4) + 1) 
        colors_dup:push((colors_dup:top() % 4) + 1) 
        local n = colors_dup.size
        for j = 1, n do
          local chains_dup = color_chain(self.chains, colors_dup)
          local state = MapUtils.destroy_chain( MapUtils.gen_map_from_exprs(self.w, self.h, chains_dup ) )
          chains_dup:pop() -- pop answer
          state = not state and MapUtils.check_puzzle_correctness( MapUtils.gen_map_from_exprs(self.w, self.h, chains_dup) ) 
          if state then
            if self.chains.size > self.chain_limit then
              self.chains:display()
              colors_dup:display()
              self.chains = color_chain(self.chains, colors_dup)
              self.colors = colors_dup
              return true
            end
            local last_ans = self.chains:pop()
            local last_color = colors_dup:pop() -- last chain's color
            self.colors = colors_dup
            self:next_chain()
            if self.chains.size > self.chain_limit then return true end
            colors_dup:push(last_color)
            self.chains:push(last_ans)
          end          
          tablex.rotate(colors_dup)
        end 
        colors_dup:pop() colors_dup:pop()
      end
      self.chains:pop() if ans then self.chains:pop() end
      self.row_ranges, self.heights = old_ranges, old_heights
    end
    i = i + 1
  end
  return false
end

function PuzzleGen:generate(chain_limit, w, h)
  w, h = w or 6, h or 10
  if not self.inited then self:init(chain_limit, w, h) end
  repeat
    self:reinit()
    print("Generating..")
  until self:next_chain()
  print("Ans: ", self.chains:top())
  local res = MapUtils.gen_map_from_exprs(w, h, self.chains)
  return res
end
Test.timer( "", 1, function(res) MapUtils.display( PuzzleGen:generate((tonumber(arg[1]) or 4), 6, 10) ) end)


