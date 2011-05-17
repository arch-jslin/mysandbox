
local director = require 'director'
local ui = require 'ui'
local scene = display.newGroup()
local Menu = {}

local function button_handler(event)
  if event.id == "endless" and event.phase == "release" then
    print("endless mode pressed.")
    director:changeScene("endless_sp","moveFromTop")
  elseif event.id == "puzzle" and event.phase == "release" then
    print("puzzle mode pressed.")
    director:changeScene("puzzle","moveFromTop")
  end
end

function Menu:new()

  local button1 = ui.newButton{
    default = "rc/buttonWhite.png",
    over = "rc/buttonWhiteOver.png",
    onEvent = button_handler,
    text = "Endless mode",
    id = "endless",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  local button2 = ui.newButton{
    default = "rc/buttonWhite.png",
    over = "rc/buttonWhiteOver.png",
    onEvent = button_handler,
    text = "Puzzle mode",
    id = "puzzle",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  button1.x = 240
  button1.y = 200
  
  button2.x = 240
  button2.y = 360

  scene:insert(button1)
  scene:insert(button2)
  
  return scene
end

function Menu:clean()
  print("Menu cleaned.")
end

return Menu
