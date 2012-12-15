local game1 = require '1drpg'

function love.load()
  print("Love app started, on load...")
  if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- we actually have to have a game hierarchy flow here,
  -- but for the sake of simplicity in the beginning, just init game here
  game1:init()
end

function love.update(dt)
  game1:update(dt)
end

function love.draw()
  game1:draw()
end

function love.keyreleased(key)
  game1:keyreleased(key)
end
