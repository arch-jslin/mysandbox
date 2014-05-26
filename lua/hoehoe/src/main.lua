local SpriteSheet = require 'SpriteSheet'
local Chartypes = {}
local framewidth = 72
local frameheight = 96
local S = {}

local Kumas = {}
local Hero = nil

local function hero_update(self, dt)
  local moveunit = (300 * dt)
  if love.keyboard.isDown('left') then
    self.x = self.x - moveunit
    self.facing = 4
  elseif love.keyboard.isDown('right') then
    self.x = self.x + moveunit
    self.facing = 2
  end
  if love.keyboard.isDown('up') then
    self.y = self.y - moveunit
    self.facing = 3
  elseif love.keyboard.isDown('down') then
    self.y = self.y + moveunit
    self.facing = 1
  end
  
  self.anims[self.facing]:update(dt)
end

local function kumas_update(self, dt)
  self.anims[self.facing]:update(dt)
end

local function newKuma(ktype, is_hero)
  local o = {}
  o.type = ktype
  o.anims = {}
  o.facing = 1
  o.x = 0
  o.y = 0
  for row = 1, 3 do
    local a = S[o.type]:createAnimation()
    a:addFrame(1, row)
    a:addFrame(2, row)
    a:addFrame(3, row)
    a:addFrame(2, row)
    o.anims[row] = a
  end
  
  -- flipped right == left
  local a = S[o.type]:createAnimation()
  a:addFrame(1, 2, true)
  a:addFrame(2, 2, true)
  a:addFrame(3, 2, true)
  a:addFrame(2, 2, true)
  o.anims[#o.anims+1] = a
  
  if is_hero then 
    o.update = hero_update
  else 
    o.update = kumas_update 
  end
  
  return o
end


--- Program Start // Loading ---

function love.load()
  math.randomseed(os.time())
  -- Load character images and other resources
  local i = 0
  repeat 
    i = i + 1
    local img = 'char'..tostring(i)..'.png'
    S[i] = SpriteSheet.new(img, framewidth, frameheight)
  until S[i] == nil
    
  -- Generate Hero
  Hero = newKuma(1, true)
  Hero.x = 400
  Hero.y = 300
  
  -- Generate Other Kumas
  for i = 1, 10 do
    local o = newKuma(2)
    o.x = math.random(600)
    o.y = math.random(400)
    Kumas[#Kumas+1] = o
  end
end


---- Universal Methods below


function love.update(dt)
  Hero:update(dt)
  
  for k,v in ipairs(Kumas) do 
    v:update(dt)
  end
end

function love.draw()
  Hero.anims[Hero.facing]:draw(Hero.x, Hero.y)
  
  for k,v in ipairs(Kumas) do 
    v.anims[v.facing]:draw(v.x, v.y)
  end
end

function love.keypressed(k)
  if k=='q' or k=='escape' then
    love.event.quit()
  end
end