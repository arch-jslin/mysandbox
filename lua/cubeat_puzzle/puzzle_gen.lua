
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = require 'maputils'
local List = require 'pl.List'
local Test = require 'pl.test'
local tablex = require 'tablex2'
local Helper = require 'helpers'
local random, Stack = Helper.random, Helper.stack

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

-- 'fix' PuzzleGen:
-- break 'next_chain' apart, into small / modulize methods. don't pile lots of statements 
-- altogether, rather make sure the operation semantic makes sense literally.
-- pre-compute everywhere, and remove all the small loops:
--   1. all the 'if lenV elseif lenH'
--   2. all the 'for i to lenV or lenH'
-- => this optimization is very very important for luajit. Always write less branchy code,
-- => meta programming (loadstring) when I have time or when the need arises.

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


