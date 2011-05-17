
local Game =      require 'game'
local director =  require 'director'
local Cube =      require 'cube'
local random =    require 'helpers'.random
local MapUtils  = require 'maputils'
local PuzzleGen = require 'puzzle_gen'

local scene = display.newGroup()

local Puzzle = Game:new()

function Puzzle:load_map(level)
  self.level = level or 3
  
  local t = os.clock()
  local generated_puzzle = PuzzleGen:generate(self.level)
  
  local temprow = {} -- Puzzle only produce "just fit" puzzles. We have to make reservations.
  for x = 1, self.cubes.width do temprow[x] = 0 end
  generated_puzzle[self.cubes.height] = temprow
  
  self.cubes:for2d_with_idx(function(_, x, y)
    if generated_puzzle[y][x] ~= 0 then
      local c = Cube:new(generated_puzzle[y][x], x, y) 
      c.state = "waiting"
      c.need_check = false
      
      self.cubes[y][x] = c
      
      local game = self -- avoid "self" clashes. 
      c.event_handler.touch = function(self, event)
        if event.phase == "began" then
          self.owner:remove_body()
          game.cubes[self.owner.y][self.owner.x] = nil
          timer.performWithDelay(1, game:remove_all_touch_event())
          game.check_success_timer = timer.performWithDelay(50, game:check_success_event(), -1)
          return true
        end
      end

      c.body:addEventListener("touch", c.event_handler)
      scene:insert(c.body)
    end
  end)
end

function Puzzle:remove_all_touch_event()
  if not self.remove_all_touch_event_ then
    self.remove_all_touch_event_ = function(event)
      self.cubes:for2d(function(c)
        c.body:removeEventListener("touch", c.event_handler)
      end)
    end
  end
  return self.remove_all_touch_event_
end

function Puzzle:check_success_event()
  if not self.check_success_event_ then
    self.check_success_event_ = function() 
      local some_cube_still_alive, all_waiting = false, true
      
      self.cubes:for2d(function(c)
        some_cube_still_alive = true
        if c:is_dropping() or (c:is_waiting() and self:is_below_empty(c)) then 
          all_waiting = false 
        end
      end)
      
      if some_cube_still_alive then
        if all_waiting then
          Runtime:dispatchEvent( {name="CuBeat_Puzzle_Lose", target=self} )
        end
      else
        Runtime:dispatchEvent( {name="CuBeat_Puzzle_Win", target=self} )
      end
    end
  end
  return self.check_success_event_
end

--------------------------------------------------------------------------

local function button_handler(event)
  if event.id == "back" and event.phase == "release" then
    print("go back pressed.")
    director:changeScene("menu","moveFromBottom")
  end
end

local PuzzleModeHolder = {}
local game = nil -- this is pretty bullshit. see below

function PuzzleModeHolder : CuBeat_Puzzle_Win(event)
  local next_level = game.level >= 19 and 19 or game.level + 1
  print("game: SUCCESS -> "..tostring(next_level))
  -- self.clean() -- this is actually bad, dont try removing listeners in listener's callback.
  -- self.new(next_level)
  timer.performWithDelay(1, function()
    self.clean()
    self.new(next_level)
  end)
end

function PuzzleModeHolder : CuBeat_Puzzle_Lose(event)
  print("game: FAILED")
  timer.performWithDelay(1, function()
    self.clean()
    self.new(game.level)
  end)
end

function PuzzleModeHolder . new(level) -- bullshit, director.lua don't handle any argument passing. 
  game = Puzzle:new()
  game:load_map(level)
  Runtime:addEventListener("enterFrame", game:cycle_event())
  Runtime:addEventListener("CuBeat_Puzzle_Win", PuzzleModeHolder)
  Runtime:addEventListener("CuBeat_Puzzle_Lose", PuzzleModeHolder)
  
  local button1 = ui.newButton{
    default = "rc/buttonWhite.png",
    over = "rc/buttonWhiteOver.png",
    onEvent = button_handler,
    text = "Go Back",
    id = "back",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  button1.x = 240
  button1.y = 750
  
  scene:insert(button1)  
  
  return scene
end
 
function PuzzleModeHolder . clean() -- bullshit, director.lua don't handle any argument passing. 
  if game.check_success_timer then 
    timer.cancel( game.check_success_timer )
  end
  Runtime:removeEventListener("enterFrame", game:cycle_event())
  Runtime:removeEventListener("CuBeat_Puzzle_Win", PuzzleModeHolder)
  Runtime:removeEventListener("CuBeat_Puzzle_Lose", PuzzleModeHolder)
  game:cleanup()
end

return PuzzleModeHolder
