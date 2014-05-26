
local Map =      require 'map'
local director = require 'director'
local Cube     = require 'cube'

local scene = display.newGroup()

scene.xReference = 640
scene.yReference = 360
scene:rotate(90)

Cube.arrived_at_logical_position = function(self)
  if self.y_orient < 0 then 
    return self.body.y <= -280 + self.y * (self.pixel_size * self.scale_ratio)
  else
    return self.body.y >= 996 - self.y * (self.pixel_size * self.scale_ratio)
  end
end

Cube.update_real_pos = function(self)
  local pos_x = self.orig_x + self.x * (self.pixel_size * self.scale_ratio)
  self.body.x = pos_x
  if self:is_garbage() then self.garbage_body.x = pos_x end
  
  local pos_y
  if self.y_orient < 0 then 
    pos_y = -280 + self.y * (self.pixel_size * self.scale_ratio)
  else
    pos_y = 996 - self.y * (self.pixel_size * self.scale_ratio)
  end
  self.body.y = pos_y
  if self:is_garbage() then self.garbage_body.y = pos_y end
end

local LocalPvpGame = {}

function LocalPvpGame:new()
  local o = setmetatable({}, {__index = self})
  o:init()
  return o
end

function LocalPvpGame:init()
  self.map1 = Map:new(scene, 560, 1)
  self.map2 = Map:new(scene, 270, -1)
  self.map1:set_enemy(self.map2)
  self.map2:set_enemy(self.map1)
  
  self.heatgauge1_bk = display.newRect(480, 770, 48, 200)
  self.heatgauge1_bk:setFillColor(128, 32, 32)
  
  self.heatgauge1 = display.newRect(480, 770, 48, 200) -- forward declared
  self.heatgauge1:setFillColor(255, 64, 64)
  self.heatgauge1:setReferencePoint(display.BottomCenterReferencePoint)
  self.heatgauge1.yScale = 0.001
  
  scene:insert(self.heatgauge1_bk)
  scene:insert(self.heatgauge1)
  
  self.heatgauge2_bk = display.newRect(740, -240, 48, 200)
  self.heatgauge2_bk:setFillColor(128, 32, 32)
  
  self.heatgauge2 = display.newRect(740, -240, 48, 200) -- forward declared
  self.heatgauge2:setFillColor(255, 64, 64)
  self.heatgauge2:setReferencePoint(display.TopCenterReferencePoint)
  self.heatgauge2.yScale = 0.001
  
  scene:insert(self.heatgauge2_bk)
  scene:insert(self.heatgauge2)
end

function LocalPvpGame:cycle_event()
  if not self.cycle_event_ then 
    -- self.time = system.getTimer() -- not os.clock() here
    self.cycle_event_ = function(event)
      self.heatgauge1.yScale = self.map1.heat
      self.heatgauge2.yScale = self.map2.heat
      self.map1:cycle(event.time)
      self.map2:cycle(event.time)
    end
  end
  return self.cycle_event_
end

function LocalPvpGame:cleanup()
  self.map1:cleanup()
  self.map2:cleanup()
  self.heatgauge1:removeSelf()
  self.heatgauge2:removeSelf()
  self.heatgauge1_bk:removeSelf()
  self.heatgauge2_bk:removeSelf()
end

--------------------------------------------------------------------------

local game = LocalPvpGame:new()

local function button_handler(event)
  print(event.phase)
  if event.id == "back" and event.phase == "release" then
    print("go back pressed.")
    director:changeScene("menu","moveFromBottom")
  elseif event.id == "haste1" and event.phase == "press" then
    if game.map1:is_overheat() then return end
    game.map1:haste(true)
  elseif event.id == "haste2" and event.phase == "press" then
    if game.map2:is_overheat() then return end
    game.map2:haste(true)
  elseif event.id == "haste1" and event.phase == "release" then
    game.map1:haste(false)
  elseif event.id == "haste2" and event.phase == "release" then
    game.map2:haste(false)
  end
end

local SinglePlayerHolder = {}

function SinglePlayerHolder:new()

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
  
  local haste1 = ui.newButton{
    default = "rc/cw.png",
    over = "rc/cg.png",
    onEvent = button_handler,
    text = "Haste",
    id = "haste1",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  local haste2 = ui.newButton{
    default = "rc/cw.png",
    over = "rc/cg.png",
    onEvent = button_handler,
    text = "Haste",
    id = "haste2",
    textColor = {0,0,0,255},
    emboss = true,
    size = 24
  }
  
  button1:scale(0.66, 1)
  haste1:scale(0.5, 0.5)
  haste2:scale(0.5, 0.5)

  button1.x = 640
  button1.y = 360
  
  haste1.x, haste1.y = 360, 920
  haste2.x, haste2.y = 920, -200
  
  scene:insert(button1)
  scene:insert(haste1)
  scene:insert(haste2)

  Runtime:addEventListener("enterFrame", game:cycle_event())
  
  return scene
end

function SinglePlayerHolder:clean()
  Runtime:removeEventListener("enterFrame", game:cycle_event())
  game:cleanup()
end

return SinglePlayerHolder
