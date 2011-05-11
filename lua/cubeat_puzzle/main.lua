
local MapUtils  = require 'maputils'
local PuzzleGen = require 'puzzle_gen'
local Cube      = require 'cube'

local WIDTH, HEIGHT = display.contentWidth, display.contentHeight
local Level = 3
local PuzzleGame = {}

function PuzzleGame:init(chain_num) --this needs to be an instance
  local t = os.clock()
  local map = PuzzleGen:generate(chain_num)
  MapUtils.display( map )
  
  self.cubes_ = {}
  for y = 1, 10 do
    self.cubes_[y] = {}
    for x = 1, 6 do
      if map[y][x] ~= 0 then
        self.cubes_[y][x] = Cube:new(map[y][x], x*72, 800-y*72)  
      end
    end
  end
  
  print("Time spent calculating puzzle: "..(os.clock()-t) )

  print("answer_called_times: "..PuzzleGen.answer_called_times)
  print("back_track_times: "..PuzzleGen.back_track_times)
  print("regen_times: "..PuzzleGen.regen_times)
  print("time_used_by_shuffle: "..PuzzleGen.time_used_by_shuffle)
  print("time_used_by_find_chain: "..PuzzleGen.time_used_by_find_chain)
end

function PuzzleGame:cleanup()
  print("cleaning up...")
  for y = 1, 10 do
    for x = 1, 6 do
      if self.cubes_[y][x] ~= nil then
        self.cubes_[y][x]:removeBody()
      end
    end
  end
  collectgarbage("collect") -- just in case. might not be needed.
  print("garbage collected.")
end

PuzzleGame:init(Level)

Runtime:addEventListener("tap", function() 
  PuzzleGame:cleanup()
  Level = Level < 19 and Level + 1 or Level
  PuzzleGame:init(Level)  
end)
