
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
    return x1, y1
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

function PuzzleGen:next_chain(level)
  local intersects = self.intersects_of[ self.chains:top() ]
  local i = 1
  while os.time() - self.start_time < 2 and intersects[i] do
    local c = intersects[i]
    if self:not_float(c) and self:not_too_high(c) then
      self.chains:push(intersects[i])
      local lenH, lenV = MapUtils.analyze(self.chains:top())
      local len = lenH + lenV -- anyway get its length
      local old_ranges, old_heights = self:update_ranges_heights()
      --local ansx, ansy = self:add_answer_to(self.chains)
      for color = 0, 3 do
        self.colors:push(color)
        local colored_chain = color_chain(self.chains, self.colors)
        local cloned_map = MapUtils.gen_map_from_exprs(self.w, self.h, self.chains))
        local chained, count = MapUtils.destroy_chain( cloned_map ) 
        if chained and count == len then
          if self.chains.size >= self.chain_limit then
            if self:add_answer_to(self.chains, last_color) then
              self.chains:display()
              return true
            end
          else
            self:next_chain( level + 1 )
          end
          if self.chains.size > self.chain_limit then return true 
          elseif level < self.chain_limit - 4 then return false end
        end
        self.colors:pop()
      end
    -- if ansx and not MapUtils.destroy_chain(MapUtils.gen_map_from_exprs(self.w, self.h, self.chains)) 
    -- then
      -- for j = 0, 3 do
        -- self.colors:push(((self.colors:top() + j) % 4) + 1) 
        -- for k = 0, 3 do 
          -- self.colors:push(((self.colors:top() + k) % 4) + 1)
          -- if self.colors:top() ~= self.colors[self.colors.size - 1] then            
            -- local colored_chains = color_chain(self.chains, self.colors)
            -- local colored_map = MapUtils.gen_map_from_exprs(self.w, self.h, colored_chains)
            -- local state = not MapUtils.destroy_chain( colored_map )
            -- colored_map[ansy][ansx] = 0 -- clear answer block
            -- for y = ansy + 1, self.h do  -- pull down things above the answer
              -- colored_map[y-1][ansx] = colored_map[y][ansx]
            -- end
            -- local chained, destroy_count = MapUtils.destroy_chain( colored_map )
            -- state = state and destroy_count == len
            -- if state then
              -- if self.chains.size > self.chain_limit then
                -- self.chains = color_chain(self.chains, self.colors)
                -- self.chains:display()
                -- return true
              -- end
              -- local ans = self.chains:pop()
              -- local ans_color = self.colors:pop()
              -- self:next_chain( level + 1 )
              -- if self.chains.size > self.chain_limit then 
                -- return true
              -- elseif level < self.chain_limit - 4 then
                -- return false -- never backtrack
              -- end
              -- self.colors:push(ans_color)
              -- self.chains:push(ans)
            -- end
          -- end
          -- self.colors:pop()
        -- end 
        -- self.colors:pop()          
      -- end 
    -- end
      self.chains:pop() -- if ansx then self.chains:pop() end
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
    --print("Generating..")
  until self:next_chain(3) 
  print("Ans: ", self.chains:top())
  local res = MapUtils.gen_map_from_exprs(w, h, self.chains)
  return res
end

Test.timer( "", 1, function(res) MapUtils.display( PuzzleGen:generate((tonumber(arg[1]) or 4), 6, 10) ) end)


