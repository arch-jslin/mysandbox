local game1 = require '1drpg'
local game2 = require 'shooter1'
local res = {}

local game = game2

function love.load()
  print("Love app started, on load...")
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- we actually have to have a game hierarchy flow here,
  -- but for the sake of simplicity in the beginning, just init game here
  
  res.yuusha_img = love.graphics.newImage("img/yuusha1.png")
  res.yuusha_fighter_img = love.graphics.newImage("img/yuusha_fighter.png")
  res.fighter1_img = love.graphics.newImage("img/mob_fighter1.png")
  res.bullet1_img = love.graphics.newImage("img/bullet1.png")
  res.boss_img   = love.graphics.newImage("img/base.png")
  res.mob1_img   = love.graphics.newImage("img/mob1.png")
  res.cursor_img = love.graphics.newImage("img/cursor.png")
  res.smoke_img  = love.graphics.newImage("img/smoke.png")
  res.font1      = love.graphics.newFont("img/Exo-Medium.ttf", 14)
  res.bigfont    = love.graphics.newFont("img/Exo-Medium.ttf", 72)
  
  game1:init(res)
  game2:init(res)
end

function love.update(dt)
  if game:is_finished() then
    game2:pass_data(game.yuusha.level_)
    game = game2
  end  
  game:update(dt)
end

function love.draw()
  game:draw()
end

function love.keyreleased(key)
  game:keyreleased(key)
end

