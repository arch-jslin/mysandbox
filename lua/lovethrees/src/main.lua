local stage_ = {}
local highest_number_ = 0
local current_deck_ = {0,0,0,0,0,0,0,0,0,0,0,0} -- #12
local deck_index_ = 0
local next_number_ = 0

local nstage_up_ = {}
local nstage_down_ = {}
local nstage_left_ = {}
local nstage_right_ = {}

local font50_ = love.graphics.setNewFont(50)
local font45_ = love.graphics.setNewFont(45)
local font34_ = love.graphics.setNewFont(34)
local font30_ = love.graphics.setNewFont(30)
local font25_ = love.graphics.setNewFont(25)
local font20_ = love.graphics.setNewFont(20)
local font15_ = love.graphics.setNewFont(15)

local function urandom(n)
  return math.floor(math.random()*n)
end
----

local function generate_new_deck()
  local limit = 12
  deck_index_ = 1
  for i = 0, limit-1 do
    current_deck_[i+1] = (i % 3) + 1
  end
  for i = 1, #current_deck_ do
    local temp = current_deck_[i]
    local dest = urandom(#current_deck_) + 1
    current_deck_[i] = current_deck_[dest]
    current_deck_[dest] = temp
  end
  
  for i = 1, #current_deck_ do
    io.write(current_deck_[i].." ")
  end
  print()
end

local function generate_next()
  local big_num_choices = {6, 12, 24, 48, 96, 192, 384, 768}  
  local chance = urandom(21)
  local res = nil
  if highest_number_ >= 48 and chance == 20 then
    local threshold_number = highest_number_ / 8
    local i = threshold_number / 6
    res = big_num_choices[urandom(i) + 1]
  else
    res = current_deck_[deck_index_] 
    deck_index_ = deck_index_ + 1
    if deck_index_ > 12 then
      generate_new_deck()
    end
  end
  return res
end

local function set_next_number()
  next_number_ = generate_next()
end

local function find_highest()
  for y = 1, 4 do
    for x = 1, 4 do 
      if stage_[y][x] > highest_number_ then
        highest_number_ = stage_[y][x]
      end
    end
  end
end

local function can_add(a, b) 
  if b == 0 then return false end
  if a > 2 then return a == b end
  return (a + b == 3) or (a == 0)
end

local update_prediction = nil

local function move_tiles(stage, dx, dy, simulate)
  local empty_side = {}
  local moved = false
  simulate = simulate or false
  if dx == 0 then              -- move up or down
    if dy > 0 then
      for x = 1, 4 do
        for y = 3, 1, -1 do
          if can_add(stage[y + dy][x], stage[y][x]) then 
            stage[y + dy][x] = stage[y + dy][x] + stage[y][x]
            stage[y][x] = 0
            moved = (not simulate) and true
          end
        end
        if stage[1][x] == 0 then table.insert(empty_side, x) end
      end
      if moved then 
        stage[1][ empty_side[urandom(#empty_side) + 1] ] = next_number_
      else
        -- if it's prediction stage, it will still create empty slots on the side, but not flag as moved
        -- and empty_side will still be populated 
        for i = 1, 4 do
          if stage[1][i] == 0 then
            stage[1][i] = - next_number_ -- hackery, using negative number to fill out possible positions
          end
        end
      end
    elseif dy < 0 then
      for x = 1, 4 do
        for y = 2, 4 do
          if can_add(stage[y + dy][x], stage[y][x]) then 
            stage[y + dy][x] = stage[y + dy][x] + stage[y][x]
            stage[y][x] = 0 
            moved = (not simulate) and true
          end
        end
        if stage[4][x] == 0 then table.insert(empty_side, x) end
      end
      if moved then
        stage[4][ empty_side[urandom(#empty_side) + 1] ] = next_number_
      else
        -- if it's prediction stage, it will still create empty slots on the side, but not flag as moved
        -- and empty_side will still be populated 
        for i = 1, 4 do 
          if stage[4][i] == 0 then
            stage[4][i] = - next_number_ -- hackery, using negative number to fill out possible positions
          end
        end
      end
    end
  elseif dy == 0 then          -- move left or right
    if dx > 0 then
      for y = 1, 4 do
        for x = 3, 1, -1 do
          if can_add(stage[y][x + dx], stage[y][x]) then 
            stage[y][x + dx] = stage[y][x + dx] + stage[y][x]
            stage[y][x] = 0 
            moved = (not simulate) and true
          end
        end
        if stage[y][1] == 0 then table.insert(empty_side, y) end
      end
      if moved then
        stage[ empty_side[urandom(#empty_side) + 1] ][1] = next_number_
      else
        -- if it's prediction stage, it will still create empty slots on the side, but not flag as moved
        -- and empty_side will still be populated 
        for i = 1, 4 do 
          if stage[i][1] == 0 then
            stage[i][1] = - next_number_ -- hackery, using negative number to fill out possible positions
          end
        end
      end
    elseif dx < 0 then
      for y = 1, 4 do
        for x = 2, 4 do
          if can_add(stage[y][x + dx], stage[y][x]) then 
            stage[y][x + dx] = stage[y][x + dx] + stage[y][x]
            stage[y][x] = 0 
            moved = (not simulate) and true
          end
        end
        if stage[y][4] == 0 then table.insert(empty_side, y) end
      end
      if moved then
        stage[ empty_side[urandom(#empty_side) + 1] ][4] = next_number_
      else
        -- if it's prediction stage, it will still create empty slots on the side, but not flag as moved
        -- and empty_side will still be populated 
        for i = 1, 4 do 
          if stage[i][4] == 0 then
            stage[i][4] = - next_number_ -- hackery, using negative number to fill out possible positions
          end
        end
      end
    end
  end
  
  if moved then
    find_highest()
    set_next_number()
    update_prediction()
  end
end

local function clone_stage(orig)
  local res = { {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0} } 
  for y = 1, 4 do
    for x = 1, 4 do
      res[y][x] = orig[y][x]
    end
  end
  return res
end

update_prediction = function()
  nstage_up_ = clone_stage(stage_)
  move_tiles(nstage_up_, 0, -1, true)
  
  nstage_down_ = clone_stage(stage_)
  move_tiles(nstage_down_, 0, 1, true)
  
  nstage_left_ = clone_stage(stage_)
  move_tiles(nstage_left_, -1, 0, true)
  
  nstage_right_ = clone_stage(stage_)
  move_tiles(nstage_right_, 1, 0, true)
end

local function init_game()
  stage_ = { {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0} } 
  highest_number_ = 0
  generate_new_deck()
  set_next_number()
  
  local num_init_cards = 9
  for i = 0, num_init_cards - 1 do
    local y0 = math.floor(i / 4)
    local x0 = i % 4
    stage_[y0+1][x0+1] = next_number_
    set_next_number()
  end
  
  --shuffle position
  for y = 1, 4 do
    for x = 1, 4 do
      local temp = stage_[y][x]
      local y1, x1 = urandom(4)+1, urandom(4)+1
      stage_[y][x] = stage_[y1][x1]
      stage_[y1][x1] = temp
    end
  end
  
  update_prediction()
end

----

function love.load()
  math.randomseed(os.time())
  init_game()
end

function love.update(dt)
  -- do nothing?
end

local function show_number_at(num, x, y, origx, origy, smallfont)
  origx = origx or 250
  origy = origy or 250
  smallfont = smallfont or false
  
  if num == 0 then return end
  if math.abs(num) == 1 then 
    love.graphics.setColor(0, 128, 255, (num > 0) and 255 or 128)
  elseif math.abs(num) == 2 then
    love.graphics.setColor(255, 64, 64, (num > 0) and 255 or 128)
  else
    love.graphics.setColor(255, 255, 255, (num > 0) and 255 or 128)
  end
  
  if num > 1000 then
    love.graphics.setFont(smallfont and font15_ or font25_)
  elseif num > 100 then
    love.graphics.setFont(smallfont and font20_ or font34_)
  else
    love.graphics.setFont(smallfont and font30_ or font50_)
  end
  
  local x0 = origx + (x-1) * (smallfont and 55 or 80)
  local y0 = origy + (y-1) * (smallfont and 55 or 80) 
  
  -- hack for 6+ hints
  if num < 0 and math.abs(num) >= 6 then
    love.graphics.setFont(font30_)
    love.graphics.print('6+', x0, y0)
  else  
    love.graphics.print(tostring(math.abs(num)), x0, y0)  
  end
end

local function check_identical(sa, sb)
  for y = 1, 4 do
    for x = 1, 4 do
      if sa[y][x] ~= sb[y][x] then
        return false
      end
    end
  end
  return true
end

local function show_stage(stage, origx, origy, smallfont)
  origx = origx or 250
  origy = origy or 250
  love.graphics.setColor(160, 160, 160, 255)
  local sidelength = smallfont and 200 or 300
  love.graphics.line(origx,origy, 
                     origx+sidelength,origy, 
                     origx+sidelength,origy+sidelength, 
                     origx,origy+sidelength, 
                     origx,origy)
                     
  if smallfont then -- bad flag name, but basically it means it's showing a prediction
    if check_identical(stage, stage_) then
      love.graphics.setColor(255, 128, 0, 255)
      love.graphics.line(origx,origy, origx+sidelength,origy+sidelength)
      love.graphics.line(origx+sidelength,origy, origx,origy+sidelength)
    end
  end
  
  for y = 1, 4 do
    for x = 1, 4 do
      show_number_at(stage[y][x], x, y, origx, origy, smallfont)
    end
  end
end

local function test_show_numbers()
  show_number_at(1, 0, 0)
  show_number_at(2, 1, 0)
  show_number_at(3, 2, 0)
  show_number_at(6, 3, 0)
  show_number_at(12, 0, 1)
  show_number_at(24, 1, 1)
  show_number_at(48, 2, 1)
  show_number_at(96, 3, 1)
  show_number_at(192, 0, 2)
  show_number_at(384, 1, 2)
  show_number_at(768, 2, 2)
  show_number_at(1536, 3, 2)
end

function love.draw()
  -- test_show_numbers()
  show_stage(stage_)
  
  show_stage(nstage_up_, 300, 30, true)
  show_stage(nstage_down_, 300, 570, true)
  show_stage(nstage_left_, 20, 300, true)
  show_stage(nstage_right_, 570, 300, true)
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(font45_)
  love.graphics.print('Next: ', 525, 170)
  
  if next_number_ <= 3 then
    show_number_at(next_number_, 6, 0)
  else
    love.graphics.print('6+', 650, 170)
  end
end

function love.keypressed(k)
  if k == 'r' then
    init_game()
  elseif k == 'up' then
    move_tiles(stage_, 0, -1)
  elseif k == 'down' then
    move_tiles(stage_, 0, 1)
  elseif k == 'left' then
    move_tiles(stage_, -1, 0) 
  elseif k == 'right' then
    move_tiles(stage_, 1, 0)
  end
end