
local director = require 'director'
local ui = require 'ui'
local scene = display.newGroup()
local Menu = {}

system.activate("multitouch")

local function button_handler(event)
  if event.id == "endless" and event.phase == "release" then
    print("endless mode pressed.")
    director:changeScene("endless_sp","moveFromTop")
  elseif event.id == "puzzle" and event.phase == "release" then
    print("puzzle mode pressed.")
    director:changeScene("puzzle","moveFromTop")
  elseif event.id == "local_2p" and  event.phase == "release" then
    print("local_2p mode pressed.")
    director:changeScene("local_2p","moveFromTop")
  elseif event.id == "local_2p2" and event.phase == "release" then
    print("local_2p2 mode pressed.")
    director:changeScene("local_2p2","moveFromTop")
  elseif event.id == "local_2p3" and event.phase == "release" then
    print("local_2p3 mode pressed.")
    director:changeScene("local_2p3","moveFromTop")
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
  
  local button3 = ui.newButton{
    default = "rc/buttonWhite.png",
    over = "rc/buttonWhiteOver.png",
    onEvent = button_handler,
    text = "Local 2P",
    id = "local_2p",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  local button4 = ui.newButton{
    default = "rc/buttonWhite.png",
    over = "rc/buttonWhiteOver.png",
    onEvent = button_handler,
    text = "2P Portrait",
    id = "local_2p2",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  local button5 = ui.newButton{
    default = "rc/buttonWhite.png",
    over = "rc/buttonWhiteOver.png",
    onEvent = button_handler,
    text = "2P Side By Side",
    id = "local_2p3",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  button1.x = 300
  button1.y = 100
  
  button2.x = 300
  button2.y = 220
  
  button3.x = 300
  button3.y = 340
  
  button4.x = 300
  button4.y = 460
  
  button5.x = 300
  button5.y = 580

  scene:insert(button1)
  scene:insert(button2)
  scene:insert(button3)
  scene:insert(button4)
  scene:insert(button5)
  
  return scene
end

function Menu:clean()
  print("Menu cleaned.")
end

return Menu
