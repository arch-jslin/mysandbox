
local SCREEN_WIDTH, SCREEN_HEIGHT = display.contentWidth, display.contentHeight
local Helper = require 'helpers'
local Cube =   require 'cube'
local random = require 'helpers'.random
local Map = {}

function Map:new(scene, orig_x, y_orient)
  local o = setmetatable({}, {__index = self})
  o:init(scene, orig_x, y_orient)
  return o
end

function Map:init(scene, orig_x, y_orient)
  self.scene = scene
  self.y_orient = y_orient
  self.orig_x = orig_x or 64
  self.max_speed = 450
  self.speed = 80
  self.heat = 0.001
  self.garbage_left = 0
  self.chain = 0
  self.power = 0
  self.last_t_ = system.getTimer() 
  self.cubes = {}
  self.cubes.height = 11
  self.cubes.width  = 6
  for y = 1, self.cubes.height do 
    self.cubes[y] = {}
  end
  self.cubes.for2d = Helper.foreach2d
  self.cubes.for2d_with_idx = Helper.foreach2d_with_index
  
  self:setup_cubes(4)
  
  self.speedup_timer = timer.performWithDelay(5000, self:speedup_event(), -1)
  self.cooling_timer = timer.performWithDelay(100, self:cooling_event(), -1) 
end

-- THERE ARE HELPERS BUT NEED FIX -- 

local function do_check_chain_h(row, x)
  local right = x + 1
  while row[right] and 
        row[right]:is_waiting() and 
        not row[right]:is_garbage() and
        row[right].id == row[x].id do right = right + 1 end
  local len = right - x
  local left = x - 1
  while row[left] and 
        row[left]:is_waiting() and 
        not row[left]:is_garbage() and
        row[left].id == row[x].id do left = left - 1 end
  len = len + (x - left) - 1         -- minus 1 because we've counted starting point twice.
  return (len >= 3), left+1, right-1 -- return whole range
end

local function do_check_chain_v(map, x, y)
  local up = y + 1
  while map[up][x] and 
        map[up][x]:is_waiting() and 
        not map[up][x]:is_garbage() and
        map[up][x].id == map[y][x].id do up = up + 1 end
  local len = up - y
  local down = y - 1
  while map[down] and 
        map[down][x] and 
        map[down][x]:is_waiting() and 
        not map[down][x]:is_garbage() and
        map[down][x].id == map[y][x].id do down = down - 1 end
  len = len + (y - down) - 1         -- minus 1 because we've counted starting point twice.
  return (len >= 3), down+1, up-1    -- return whole range
end

local function mark_for_delete_h(map, y, leftbound, rightbound)
  local count = 0
  for i = leftbound, rightbound do
    if not map[y][i]:is_fading() then -- we might count redundantly here, so don't fade the fading.
      map[y][i]:fade(600)
      count = count + 1
    end
  end
  return count
end

local function mark_for_delete_v(map, x, bottombound, topbound)
  local count = 0
  for i = bottombound, topbound do
    if not map[i][x]:is_fading() then -- we might count redundantly here, so don't fade the fading.
      map[i][x]:fade(600)
      count = count + 1
    end
  end
  return count
end

-- ABOVE ARE HELPERS BUT NEED FIX --

function Map:setup_cubes(level)
  repeat 
    local bad = false
    for y = 1, level do
      for x = 1, self.cubes.width do
        if self.cubes[y][x] then 
          self.cubes[y][x]:remove_body() 
          self.cubes[y][x] = nil
        end 
        local c = Cube:new(random(4)+1, x, y, self.orig_x, self.y_orient) 
        self.cubes[y][x] = c         
        c:wait()
        c:has_grounded()
        self.scene:insert(c.body)
      end
    end
    
    for y = 1, level do
      for x = 1, self.cubes.width do       
        local c = self.cubes[y][x]
        local res = do_check_chain_v(self.cubes, c.x, c.y)
        res = res or do_check_chain_h(self.cubes[c.y], c.x)
        if res then bad = true; break end
      end
      if bad then break end
    end
  until not bad
  
  for y = 1, level do
    for x = 1, self.cubes.width do
      local c = self.cubes[y][x]
      local self_cubes = self.cubes -- avoid "self" clashes.
      local map = self
      c.event_handler.touch = function(self, event)         
        if map:is_overheat() then return end
        if event.phase == "began" then
          map:generate_heat(0.18)
          if not self.owner:is_dropping() and not self.owner:is_waiting() then return false end 
          self.owner:remove_body()
          self_cubes[self.owner.y][self.owner.x] = nil
          return true
        end
      end
      c.body:addEventListener("touch", c.event_handler)
    end
  end
end

function Map:set_enemy(enemy)
  self.enemy = enemy
end

function Map:speedup_event()
  if not self.speedup_event_ then
    self.speedup_event_ = function(event) 
      if self.speed < self.max_speed then 
        self.speed = self.speed + 10
      end
    end
  end
  return self.speedup_event_
end

function Map:push_garbage(n)
  self.garbage_left = self.garbage_left + n 
end

function Map:cooling_event()
  if not self.cooling_event_ then
    self.cooling_event_ = function(event)
    
      if self.haste_ then 
        self:generate_heat(0.03)
        return 
      end
    
      if self.heat - 0.06 > 0 then 
        self.heat = self.heat - 0.06 
      else
        self.heat = 0.001 -- Scaling can't be absolute zero. Weird.
      end        
    end
  end
  return self.cooling_event_
end

function Map:is_below_empty(c)
  return c.y > 1 and not self.cubes[c.y-1][c.x]
end

function Map:is_all_waiting()
  for y = 1, self.cubes.height - 1 do 
    for x = 1, self.cubes.width do 
      local c = self.cubes[y][x]
      if c ~= nil then
        if c:is_dropping() then return false end
      end
    end 
  end
  return true
end

function Map:is_garbage_dropping()
  return self.garbage_dropping
end

function Map:is_overheat()
  return self.heat >= 1
end

function Map:generate_heat(value)
  if self.heat + value < 1 then 
    self.heat = self.heat + value
  else
    self.heat = 2 -- Overheat trigger
    self.haste_ = false
  end
end

function Map:create_new_garbages()
  for x = 1, self.cubes.width do
    if not self.cubes[self.cubes.height - 1][x] and self.garbage_left > 0 then
      local c = Cube:new(random(4)+1, x, self.cubes.height, self.orig_x, self.y_orient, true)
      self.garbage_left = self.garbage_left - 1
      self.cubes[self.cubes.height][x] = c
      
      local self_cubes = self.cubes -- avoid "self" clashes.
      local map = self
      c.event_handler.touch = function(self, event)        
        if map:is_overheat() then return end
        if event.phase == "began" then
          map:generate_heat(0.18)
          if not self.owner:is_dropping() and not self.owner:is_waiting() then return false end 
          self.owner:remove_body()
          self_cubes[self.owner.y][self.owner.x] = nil
          return true
        end
      end
      
      c.garbage_handler.touch = function(self, event)
        if map:is_overheat() then return end
        if event.phase == "began" then
          map:generate_heat(0.18)
          if not self.owner:is_dropping() and not self.owner:is_waiting() then return false end 
          self.owner:restore()
          return true
        end
      end
      
      c:has_grounded()
      c.body:addEventListener("touch", c.event_handler)
      c.garbage_body:addEventListener("touch", c.garbage_handler)
      self.scene:insert(c.body)
      self.scene:insert(c.garbage_body)
    end
  end
end

function Map:create_new_cubes()
  for x = 1, self.cubes.width do
    if not self.cubes[self.cubes.height - 1][x] then
      local c = Cube:new(random(4)+1, x, self.cubes.height, self.orig_x, self.y_orient)
      self.cubes[self.cubes.height][x] = c
      
      local self_cubes = self.cubes -- avoid "self" clashes.
      local map = self
      c.event_handler.touch = function(self, event)         
        if map:is_overheat() then return end
        if event.phase == "began" then
          map:generate_heat(0.18)
          if not self.owner:is_dropping() and not self.owner:is_waiting() then return false end 
          self.owner:remove_body()
          self_cubes[self.owner.y][self.owner.x] = nil
          return true
        end
      end
      
      c.body:addEventListener("touch", c.event_handler)
      self.scene:insert(c.body)
    end
  end
end

function Map:drop_the_cube(c)
  c:set_pos(c.x, c.y - 1)
  c:drop()
  self.cubes[c.y][c.x] = c     -- this is actually quite dangerous. we can only do this
  self.cubes[c.y+1][c.x] = nil -- when we are sure "below_is_empty."
end

-- let's keep this simple and stupid for now. it's a lot easier to understand the flow.
function Map:next_state(now_t, last_t)
  self.cubes:for2d(function(c)        
    if c:is_waiting() then
      if self:is_below_empty(c) then 
        self:drop_the_cube(c)
      end
    elseif c:is_dropping() then 
      c:drop_a_frame(now_t, last_t, self.haste_ and self.max_speed or self.speed) 
      if c:arrived_at_logical_position() then
        if self:is_below_empty(c) then
          self:drop_the_cube(c)
        else
          c:has_grounded()
          c:wait()
          c:update_real_pos() 
        end
      end 
    elseif c:is_dead() then
      self.cubes[c.y][c.x] = nil
    end    
  end)
end

-- CODE BELOW NEED FIX --

function Map:process_chaining()
  local chained, count = false, 0
  self.cubes:for2d(function(c)
    if not c:is_garbage() and c.need_check then 
      local res, lowerbound, upperbound = do_check_chain_v(self.cubes, c.x, c.y)
      if res then
        count = count + mark_for_delete_v(self.cubes, c.x, lowerbound, upperbound)
        chained = true
      end
      res, lowerbound, upperbound = do_check_chain_h(self.cubes[c.y], c.x)
      if res then 
        count = count + mark_for_delete_h(self.cubes, c.y, lowerbound, upperbound)
        chained = true
      end
      c.need_check = false
    end
  end)
  return chained, count
end

-- CODE ABOVE NEED FIX --

function Map:accumulate_chain(count)
  self.chain = self.chain + 1
  if self.attack_timer then 
    timer.cancel( self.attack_timer )
  end
  
  if self.chain == 1 then
    if count > 3 then 
      self.power = (count-1) 
    end 
  else
    self.power = self.power + math.floor((count-1)*self.chain/2 + (self.chain-1))
  end

  self.attack_timer = timer.performWithDelay(500, function(event)
    self.enemy:push_garbage(self.power)
    self.power = 0
    self.chain = 0
  end)    
end

function Map:haste(flag)
  self.haste_ = flag
end

function Map:cycle(t)
  self:next_state(t, self.last_t)

  if self:is_all_waiting() and not self:is_garbage_dropping() then 
    if self.garbage_left > 0 then
      self.garbage_dropping = true
    else 
      self:create_new_cubes()
    end
  elseif self:is_garbage_dropping() then
    self:create_new_garbages()
    if self.garbage_left <= 0 then
      self.garbage_dropping = false
    end
  end
    
  local chained, count = self:process_chaining()
  if chained then self:accumulate_chain(count) end
  
  self.last_t = t
end

function Map:cleanup()
  print("cleaning up...")
  timer.cancel( self.speedup_timer )
  timer.cancel( self.cooling_timer )
  if self.attack_timer then timer.cancel( self.attack_timer ) end
  self.cubes:for2d(function(c)
    c:remove_body()
  end)
  collectgarbage("collect") -- just in case. might not be needed.
  print("garbage collected.")
end

return Map
