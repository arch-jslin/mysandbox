
local Game =     require 'game'
local director = require 'director'
local Cube =     require 'cube'
local random =   require 'helpers'.random

local scene = display.newGroup()

local SinglePlayerGame = Game:new()

function SinglePlayerGame:create_new_cubes_event()
  if not self.create_new_cubes_event_ then 
    self.create_new_cubes_event_ = function()
    
      for x = 1, self.cubes.width do
        if not self.cubes[self.cubes.height - 1][x] then
          local c = Cube:new(random(4)+1, x, self.cubes.height)
          self.cubes[self.cubes.height][x] = c
          
          local self_cubes = self.cubes -- avoid "self" clashes.
          c.event_handler.touch = function(self, event)            
            if event.phase == "began" then
              if not c:is_dropping() and not c:is_waiting() then return false end 
              self.owner:remove_body()
              self_cubes[self.owner.y][self.owner.x] = nil
              return true
            end
          end
          
          c.body:addEventListener("touch", c.event_handler)
          scene:insert(c.body)
        end
      end
    end
  end
  return self.create_new_cubes_event_
end

--------------------------------------------------------------------------

local game = SinglePlayerGame:new()
local dropping_timer = nil

local function button_handler(event)
  if event.id == "back" and event.phase == "release" then
    print("go back pressed.")
    director:changeScene("menu","moveFromBottom")
  end
end

local SinglePlayerHolder = {}

function SinglePlayerHolder:new()
  -- do nothing for game, but we need to add menu here
  dropping_timer = timer.performWithDelay(2500, game:create_new_cubes_event(), -1)
  Runtime:addEventListener("enterFrame", game:cycle_event())

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

function SinglePlayerHolder:clean()
  timer.cancel( dropping_timer )
  Runtime:removeEventListener("enterFrame", game:cycle_event())
  game:cleanup()
end

return SinglePlayerHolder
