
local MapUtils  = require 'maputils'
local PuzzleGen = require 'puzzle_gen'
local Cube      = require 'cube'

local WIDTH, HEIGHT = display.contentWidth, display.contentHeight
local PuzzleGame = {}

function PuzzleGame:init(chain_num)
  local t = os.clock()
  local map = PuzzleGen:generate(chain_num)
  MapUtils.display( map )
  
  for y = 1, 10 do
    for x = 1, 6 do
      if map[y][x] ~= 0 then
        Cube:new(map[y][x], x*72, 800-y*72)  
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

PuzzleGame:init(18)
PuzzleGame:init(8)
