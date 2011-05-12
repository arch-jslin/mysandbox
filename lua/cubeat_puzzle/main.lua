
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
  self.cubes_ = {}
  self.cubes_.height_ = 11
  self.cubes_.width_  = 6
  for y = 1, self.cubes_.height_ do 
    self.cubes_[y] = {}
  end
  self.cubes_.for2d = Helper.foreach2d
  self.cubes_.for2d_with_i = Helper.foreach2d_with_index
  -- self:load_map(chain_num) -- if it is puzzle mode
end

function Game:load_map()
  local MapUtils  = require 'maputils'
  local PuzzleGen = require 'puzzle_gen'
  
  local t = os.clock()
  local generated_puzzle = PuzzleGen:generate(self.level_ or 3)
  MapUtils.display( generated_puzzle )
  
  local temprow = {} -- Puzzle only produce "just fit" puzzles. We have to make reservations.
  for x = 1, self.cubes_.width_ do temprow[x] = 0 end
  generated_puzzle[self.cubes_.height_] = temprow
  
  self.cubes_:for2d_with_i(function(c, x, y)
    if generated_puzzle[y][x] ~= 0 then
      self.cubes_[y][x] = Cube:new(generated_puzzle[y][x], x, y)  
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
      for x = 1, self.cubes_.width_ do
        self.cubes_[self.cubes_.height_][x] = Cube:new(random(4)+1, x, self.cubes_.height_)
      end
    end
  end
  return self.create_new_cubes_event_
end

function Game:cycle_event()
  if not self.cycle_event_ then
    self.cycle_event_ = function()
      local cubes_need_update = {}    
      self.cubes_:for2d(function(c)
        if c.y > 1 and not self.cubes_[c.y-1][c.x] then -- temp for "can_drop" state change
          c.body.y = c.body.y + 25
          if c:needs_update() then
            c:set_pos(c.x, c.y - 1)
            if c.y == 1 or self.cubes_[c.y-1][c.x] then c:update_real_pos() end 
            cubes_need_update[#cubes_need_update + 1] = c
          end
        end
      end)
      for i = 1, #cubes_need_update do
        local c = cubes_need_update[i]
        self.cubes_[c.y][c.x] = self.cubes_[c.y+1][c.x]
        self.cubes_[c.y+1][c.x] = nil -- this is a must. move reference...
      end
    end
  end
  return self.cycle_event_
end

function Game:cleanup()
  print("cleaning up...")
  self.cubes_:for2d(function(c)
    c:remove_body()
  end)
  collectgarbage("collect") -- just in case. might not be needed.
  print("garbage collected.")
end

local game = Game:new()

Runtime:addEventListener("tap", function()
  game:cleanup()
  local level = game.level_ < 19 and game.level_ + 1 or game.level_
  game = Game:new(level)
end)

--temp dropping cubes
timer.performWithDelay(3000, game:create_new_cubes_event(), 10)
timer.performWithDelay(10, game:cycle_event(), -1)