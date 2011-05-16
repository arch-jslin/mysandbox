
local SCREEN_WIDTH, SCREEN_HEIGHT = display.contentWidth, display.contentHeight
local Helper = require 'helpers'
local random = Helper.random
local Cube = require 'cube'
local Game = {}

function Game:new(chain_num)
  local o = setmetatable({}, {__index = self})
  o:init(chain_num)
  return o
end

function Game:init(chain_num) 
  self.level_ = chain_num or 3
  self.cubes = {}
  self.cubes.height = 11
  self.cubes.width  = 6
  for y = 1, self.cubes.height do 
    self.cubes[y] = {}
  end
  self.cubes.for2d = Helper.foreach2d
  self.cubes.for2d_with_idx = Helper.foreach2d_with_index
  -- self:load_map(chain_num) -- if it is puzzle mode
end

function Game:load_map()
  local MapUtils  = require 'maputils'
  local PuzzleGen = require 'puzzle_gen'
  
  local t = os.clock()
  local generated_puzzle = PuzzleGen:generate(self.level_ or 3)
  MapUtils.display( generated_puzzle )
  
  local temprow = {} -- Puzzle only produce "just fit" puzzles. We have to make reservations.
  for x = 1, self.cubes.width do temprow[x] = 0 end
  generated_puzzle[self.cubes.height] = temprow
  
  self.cubes:for2d_with_idx(function(c, x, y)
    if generated_puzzle[y][x] ~= 0 then
      self.cubes[y][x] = Cube:new(generated_puzzle[y][x], x, y)  
    end
  end)
  
  print("Time spent calculating puzzle: "..(os.clock()-t) )

  print("answer_called_times: "..PuzzleGen.answer_called_times)
  print("back_track_times: "..PuzzleGen.back_track_times)
  print("regen_times: "..PuzzleGen.regen_times)
  print("time_used_by_shuffle: "..PuzzleGen.time_used_by_shuffle)
  print("time_used_by_find_chain: "..PuzzleGen.time_used_by_find_chain)  
end

function Game:create_new_cubes_event()
  if not self.create_new_cubes_event_ then 
    self.create_new_cubes_event_ = function()
      print("creating cubes...")
      for x = 1, self.cubes.width do
        if not self.cubes[self.cubes.height - 1][x] then
          local c = Cube:new(random(4)+1, x, self.cubes.height)
          self.cubes[self.cubes.height][x] = c
          c.body:addEventListener("touch", function(event)
            if event.phase == "began" then
              c:remove_body()
              self.cubes[c.y][c.x] = nil
              return true
            end
          end)
        end
      end
    end
  end
  return self.create_new_cubes_event_
end

function Game:is_below_empty(c)
  return c.y > 1 and not self.cubes[c.y-1][c.x]
end

local function drop_cube(c, now_t, last_t)
  c.body.y = c.body.y + 4 * (1/(1000/60)) * (now_t - last_t)
end

local function drop_cube_logical(c, cubes)
  c:set_pos(c.x, c.y - 1)
  c.need_check = false
  cubes[c.y][c.x] = c     -- this is actually quite dangerous. we can only do this
  cubes[c.y+1][c.x] = nil -- when we are sure "below_is_empty."
end

local function stop_cube(c, now_t, last_t) end
local function stop_cube_logical(c)
  c.need_check = true
end

function Game:process_dropping(now_t, last_t)
  self.cubes:for2d(function(c)        
    if c.cycle ~= drop_cube and self:is_below_empty(c) then 
      c.state_change = drop_cube_logical
      c.cycle = drop_cube
    end
    
    if c.state_change then c:state_change(self.cubes); c.state_change = nil end
    if c.cycle then c:cycle(now_t, last_t) end 
    
    if c:arrived_at_logical_position() then
      if self:is_below_empty(c) then
        c.state_change = drop_cube_logical
      else
        c:update_real_pos()
        c.state_change = stop_cube_logical
        c.cycle = nil
      end
    end
  end)
end

local function do_check_chain_h(row, x)
  local i = x + 1
  while row[i] and row[i].need_check and row[i].id == row[i-1].id do i = i + 1 end
  local len = i - x
  return (len >= 3), len
end

local function do_check_chain_v(map, x, y)
  local i = y + 1
  while map[i][x] and map[i][x].need_check and map[i][x].id == map[i-1][x].id do i = i + 1 end
  local len = i - y
  return (len >= 3), len 
end

local function mark_for_delete_h(map, x, y, len)
  for i = 1, len do
    map[y][x+i-1].need_delete = true
  end
end

local function mark_for_delete_v(map, x, y, len)
  for i = 1, len do
    map[y+i-1][x].need_delete = true
  end
end

function Game:process_chaining()
  local chained, count = false, 0
  self.cubes:for2d(function(c)
    if c.need_check then 
      local res, len = do_check_chain_v(self.cubes, c.x, c.y)
      if res then
        mark_for_delete_v(self.cubes, c.x, c.y, len)
        chained = true
      end
      res, len = do_check_chain_h(self.cubes[c.y], c.x)
      if res then 
        mark_for_delete_h(self.cubes, c.x, c.y, len)
        chained = true
      end
    end
  end)
  self.cubes:for2d(function(c)
    if c.need_delete then
      c:remove_body()
      self.cubes[c.y][c.x] = nil
      count = count + 1
    end
  end)
  return chained, count
end

function Game:cycle_event()
  if not self.cycle_event_ then
    self.last_t = system.getTimer() -- not os.clock() here
    self.cycle_event_ = function(event)
      self:process_dropping(event.time, self.last_t)
      self:process_chaining()
      self.last_t = event.time
    end
  end
  return self.cycle_event_
end

function Game:cleanup()
  print("cleaning up...")
  self.cubes:for2d(function(c)
    c:remove_body()
  end)
  collectgarbage("collect") -- just in case. might not be needed.
  print("garbage collected.")
end

local game = Game:new()

--[[
Runtime:addEventListener("tap", function()
  game:cleanup()
  local level = game.level_ < 19 and game.level_ + 1 or game.level_
  game = Game:new(level)
end)
--]]
--temp dropping cubes
timer.performWithDelay(2000, game:create_new_cubes_event(), -1)
--[[
timer.performWithDelay(1000, function()
  for y = game.cubes.height, 1, -1 do
    for x = 1, game.cubes.width do
      io.write(string.format("%2d", game.cubes[y][x] and game.cubes[y][x].id or 0))
    end
    print()
  end
  print()
end, -1)
--]]
Runtime:addEventListener("enterFrame", game:cycle_event())