
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = require 'maputils'
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
  self.all_combinations, self.starters = MapUtils.create_all_combinations(w, h)
  
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

local time_used_on_shuffle = 0

function PuzzleGen:reinit()
  --self.start_time = os.time()
  self.heights = {}
  self.chains = Stack()
  self.chain_lengths = self:distribute_chain_lengths()
  
  for i = 1, self.w do 
    self.heights[i] = 0
  end
  local t = os.clock()
  for _,v in ipairs(self.all_combinations) do
    --tablex.shuffle(v.intersects) -- randomize
    --tablex.shuffle(v.answers)
    v.intersects_ptr = random(#v.intersects) + 1
    v.answers_ptr = random(#v.answers) + 1
  end
  time_used_on_shuffle = time_used_on_shuffle + (os.clock() - t)
  local c
  repeat
    c = self.starters[random(#self.starters)+1]
  until self:length_ok(1, c.len)
  self.chains:push(c)
  self:update_heights()
end

local function array_copy(src)
  local ret = {}
  for _,v in ipairs(src) do table.insert(ret, v) end
  return ret
end

function PuzzleGen:update_heights() -- inplace modification
  local old_heights = array_copy(self.heights)
  self.chains:top():update_heights(self.heights)
  return old_heights
end

function PuzzleGen:length_ok(level, len)
  if not self.chain_lengths then return true 
  else
    return self.chain_lengths[level] == len
  end
end

function PuzzleGen:not_float(c)
  return c:not_float(self.heights)
end

function PuzzleGen:not_too_high(c)
  return not c:too_high(self.heights, self.h)
end

local answer_called_times = 0
local back_track_times = 0
local regen_times = 0

function PuzzleGen:add_final_answer(colored_map)  
  answer_called_times = answer_called_times + 1
  for _,ans in ipairs(self.chains:top().answers) do
    if self:not_too_high(ans) then
      ans:add_chain_to_map(colored_map)
      if not MapUtils.find_chain(colored_map) then
        self.chains:push(ans)
        return true -- answer found. chain construction complete.
      end      
      ans:remove_from_map(colored_map) -- restore map to try next answer
    end
  end
  return false
end

function PuzzleGen:next_chain(level)
  local intersects = self.chains:top().intersects
  local ptr = self.chains:top().intersects_ptr
  for i = 1, #intersects do
    local c = intersects[ ((i + ptr) % #intersects) + 1 ]
    if self:length_ok(level, c.len) and self:not_float(c) and self:not_too_high(c) then
      self.chains:push(c)
      local old_heights = self:update_heights() 
      local colored_map = MapUtils.gen_map_from_exprs(self.w, self.h, self.chains)
      local chained, destroy_count = MapUtils.destroy_chain( colored_map )
      if destroy_count == c.len then
        if self.chains.size >= self.chain_limit then
          MapUtils.drop_blocks(colored_map)
          self.chains:top():add_chain_to_map(colored_map) -- add it back.. dirty way.
          if self:add_final_answer(colored_map) then
            self.chains:display()
            return true
          end
        else
          self:next_chain( level + 1 )
        end
        os.time() -- dummy call to prevent JIT bug
        if self.chains.size > self.chain_limit then 
          return true
        elseif level < self.chain_limit - 5 then 
          return false 
        end
        back_track_times = back_track_times + 1
      end
      self.chains:pop() 
      self.heights = old_heights
    end
  end
  return false
end

function PuzzleGen:generate(chain_limit, w, h)
  w, h = w or 6, h or 10
  if not self.inited then self:init(chain_limit, w, h) end
  repeat
    self:reinit()
    regen_times = regen_times + 1
  until self:next_chain(2) 
  print("Ans: ", self.chains:top())
  local res = MapUtils.gen_map_from_exprs(w, h, self.chains)
  return res
end

Test.timer( "", 1, function(res) MapUtils.display( PuzzleGen:generate((tonumber(arg[1]) or 4), 6, 10) ) end)
--MapUtils.display( PuzzleGen:generate((tonumber(arg[1]) or 4), 6, 10) ) 

print("answer_called_times: "..answer_called_times)
print("back_track_times: "..back_track_times)
print("regen_times: "..regen_times)
print("time_used_on_shuffle: "..time_used_on_shuffle)