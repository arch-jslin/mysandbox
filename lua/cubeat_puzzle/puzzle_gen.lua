
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
  self.answers_of = MapUtils.create_answers_sheet(self.intersects_of, w, h)
  
  self:reinit()
  
  self.inited = true
end

function PuzzleGen:distribute_chain_lengths()
  local chain_lengths = nil
  if self.chain_limit > 15 then
    chain_lengths = {}
    for i = 1, self.chain_limit do table.insert(chain_lengths, 3) end
    local quota = random(20 - self.chain_limit + 1) + 1
    local i = 1
    while i <= self.chain_limit do
      local chance = random(10)
      if quota > 1 and chance <= 1 and i < self.chain_limit / 2 and chain_lengths[i-1] ~= 5 then
        chain_lengths[i] = 5
        quota = quota - 2
      elseif quota > 0 and chance <= 3 then
        chain_lengths[i] = 4
        quota = quota - 1
      else
        chain_lengths[i] = 3
      end      
      i = i + 1
    end
  end
  return chain_lengths
end

function PuzzleGen:reinit()
  self.start_time = os.time()
  self.row_ranges = {}
  self.heights = {}
  self.chains = Stack()
  self.colors = Stack()
  self.chain_lengths = self:distribute_chain_lengths()

  for i = 1, self.h do
    self.row_ranges[i] = {s = self.w, e = 0}
  end
  for i = 1, self.w do 
    self.heights[i] = 0
  end
  for k,v in pairs(self.intersects_of) do
    tablex.shuffle(v) -- randomize
    tablex.shuffle(self.answers_of[k])
  end

  local c
  repeat
    c = self.starter[random(#self.starter)+1]
    local lenH, lenV = MapUtils.analyze(c)
  until self:length_ok(1, lenH+lenV)
  self.chains:push(c)
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

local function color_chain(chains, colors)
  local chains_dup = Stack()
  for i,v in ipairs(chains) do chains_dup:push(v + colors[i]*100) end
  return chains_dup
end

function PuzzleGen:add_final_answer(colored_map)  
  local answers = self.answers_of[ self.chains:top() ]
  for _,ans in ipairs(answers) do
    if self:not_too_high(ans) then
      local _, _, color, ansx, ansy = MapUtils.analyze(ans)
      MapUtils.add_chain_to_map(colored_map, ans)
      if color ~= self.colors:top() then
        colored_map[ansy][ansx] = color
        if not MapUtils.find_chain(colored_map) then
          local colored_chain = color_chain(self.chains, self.colors)
          colored_chain:push(ans)
          self.chains = colored_chain
          return true -- answer found. chain construction complete.
        end      
      end
    end
  end
  return false
end

function PuzzleGen:length_ok(level, len)
  if not self.chain_lengths then return true 
  else
    return self.chain_lengths[level] == len
  end
end

-- 'fix' PuzzleGen:
-- break 'next_chain' apart, into small / modulize methods. don't pile lots of statements 
-- altogether, rather make sure the operation semantic makes sense literally.
-- pre-compute everywhere, and remove all the small loops:
--   1. all the 'if lenV elseif lenH'
--   2. all the 'for i to lenV or lenH'
-- => this optimization is very very important for luajit. Always write less branchy code,
-- => meta programming (loadstring) when I have time or when the need arises.

function PuzzleGen:next_chain(level)
  local intersects = self.intersects_of[ self.chains:top() ]
  for _,c in ipairs(intersects) do 
    local lenH, lenV = MapUtils.analyze(c)
    if self:length_ok(level, lenH+lenV) and self:not_float(c) and self:not_too_high(c) then
      self.chains:push(c)
      local len = lenH + lenV -- anyway get its length
      local old_ranges, old_heights = self:update_ranges_heights()
      for k = 0, 3 do 
        self.colors:push(((self.colors:top() + k) % 4) + 1)         
        local colored_chains = color_chain(self.chains, self.colors)
        local colored_map = MapUtils.gen_map_from_exprs(self.w, self.h, colored_chains)
        local chained, destroy_count = MapUtils.destroy_chain( colored_map )
        if destroy_count == len then
          if self.chains.size >= self.chain_limit then
            if self:add_final_answer(colored_map) then
              self.chains:display()
              return true
            end
          else
            self:next_chain( level + 1 )
          end
          if self.chains.size > self.chain_limit then 
            return true
          elseif level < self.chain_limit - 4 then 
            return false 
          end
        end
        self.colors:pop()
      end 
      self.chains:pop()
      self.row_ranges, self.heights = old_ranges, old_heights
    end
  end
  return false
end

function PuzzleGen:generate(chain_limit, w, h)
  w, h = w or 6, h or 10
  if not self.inited then self:init(chain_limit, w, h) end
  repeat
    self:reinit()
    --print("Generating..")
  until self:next_chain(2) 
  print("Ans: ", self.chains:top())
  local res = MapUtils.gen_map_from_exprs(w, h, self.chains)
  return res
end

Test.timer( "", 1, function(res) MapUtils.display( PuzzleGen:generate((tonumber(arg[1]) or 4), 6, 10) ) end)
