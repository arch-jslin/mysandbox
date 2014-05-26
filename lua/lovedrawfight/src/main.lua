
local timer = require 'timer'
local HC    = require 'hardoncollider'
local collider_

local time_elapsed_ = 0
local WIDTH, HEIGHT

local function random(n)
  return math.floor(math.random()*n)
end

local function unordered_remove(t, o)
  -- for simplicity's sake, we swap it with the last object
  for i = 1, #t do 
    if o == t[i] then
      t[i] = t[#t]
      t[#t] = nil
      break
    end
  end
end

-- Hero setup --

local hero_ = {}

local function new_hero()
  local o = {}
  o.x = 150
  o.y = 400
  o.width = 50
  o.height = 150
  return o
end

local function draw_hero()
  love.graphics.rectangle('fill', hero_.x, hero_.y, hero_.width, hero_.height)
end

local hero_bullets_ = {}

local function generate_hero_bullets1(vx, vy)
  local o = {}
  o.vx = vx
  o.vy = vy
  o.x = hero_.x
  o.y = hero_.y
  
  o.area = collider_:addRectangle(o.x, o.y, 200, 10)
  o.area._polygon.centroid.x = o.x + 200
  o.area.id = random(100)
 
  o.area:rotate( math.atan2(o.vy, o.vx) )
  
  table.insert(hero_bullets_, o)
end

local function update_hero_bullets(dt)
  local delete_bullets = {}
  for _, b in ipairs(hero_bullets_) do
    b.x = b.x + b.vx
    b.y = b.y + b.vy
    b.area:moveTo(b.x, b.y)
    if b.x > 1200 or b.y < 0 or b.y > 720 then 
      table.insert(delete_bullets, b)
    end
  end
  for _, b in ipairs(delete_bullets) do
    collider_:remove(b.area)
    unordered_remove(hero_bullets_, b)
  end
end

local function draw_hero_bullets()
  for _, b in ipairs(hero_bullets_) do 
    love.graphics.circle( "fill", b.x, b.y, 5, 20 )
    b.area:draw('line')
  end
end
      
-- type 1 stuff --
local bullets_ = {}
      
local function generate_bullets()
  local o = {}
  o.vx = -15
  o.vy = 0
  o.x = 1200
  o.y = 300 + random(200) 
  
  o.area = collider_:addRectangle(o.x, o.y, 200, 10)
  o.area._polygon.centroid.x = o.x + 200
  o.area.id = 100 + random(100)
 
  o.area:rotate( math.atan2(o.vy, o.vx) )
  
  table.insert(bullets_, o)
end
      
local function update_bullets(dt)
  local delete_bullets = {}
  for _, b in ipairs(bullets_) do
    b.x = b.x + b.vx
    b.y = b.y + b.vy
    b.area:moveTo(b.x, b.y)
    if b.x < 50 then 
      table.insert(delete_bullets, b)
    end
  end
  for _, b in ipairs(delete_bullets) do
    collider_:remove(b.area)
    unordered_remove(bullets_, b)
  end
end

local function draw_bullets()
  for _, b in ipairs(bullets_) do 
    love.graphics.circle( "fill", b.x, b.y, 5, 20 )
    b.area:draw('line')
  end
end
      
--

local function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
  print("Something collide: ", shape_a.id, shape_b.id, mtv_x, mtv_y)
  local enemy_shape = shape_a.id >= 100 and shape_a or shape_b
  enemy_shape.dead = true 
end

local function collision_stop(dt, shape_a, shape_b)
end

function love.load()
  WIDTH, HEIGHT = love.graphics.getWidth(), love.graphics.getHeight()
  
  collider_ = HC(100, on_collision, collision_stop)

  hero_ = new_hero()

  timer.set(function() print('hi') end, 0.5, 5)
  
  timer.set(generate_bullets, 1, -1)
end
      
local function cleanup_dead_bullets()
  for _, b in ipairs(bullets_) do
    if b.area.dead then 
      collider_:remove(b.area)
      unordered_remove(bullets_, b)
    end
  end
end
      
function love.update(dt)
  time_elapsed_ = time_elapsed_ + dt
  timer.update(dt)
  
  update_hero_bullets(dt)
  update_bullets(dt)
  collider_:update(dt)
  
  cleanup_dead_bullets()
end
   
function love.draw()
  love.graphics.printf("Hello World! " .. time_elapsed_ .. " screen_size: " .. WIDTH ..", " .. HEIGHT, 0, 10, 250, 'center')
  
  draw_hero()
  draw_hero_bullets()
  draw_bullets()
end

local mstart_x, mstart_y = nil, nil

function love.mousepressed(x, y, b)
  if b == 'l' then
    mstart_x = x
    mstart_y = y
  end
end

function love.mousereleased(x, y, b) 
  if b == 'l' and mstart_x then
    local vx = (x - mstart_x) / 20
    local vy = (y - mstart_y) / 20
    if vx * vx + vy * vy >= 225 then  
      generate_hero_bullets1(vx, vy)
    end
    mstart_x, mstart_y = nil, nil
  end
end
  
function love.keyreleased(k)
  print( k .. ' is released' )
end
  