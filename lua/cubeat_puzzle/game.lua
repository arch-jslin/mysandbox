
local SCREEN_WIDTH, SCREEN_HEIGHT = display.contentWidth, display.contentHeight
local Helper = require 'helpers'
local Game = {}

function Game:new()
  local o = setmetatable({}, {__index = self})
  o:init()
  return o
end

function Game:init() 
  self.cubes = {}
  self.cubes.height = 11
  self.cubes.width  = 6
  for y = 1, self.cubes.height do 
    self.cubes[y] = {}
  end
  self.cubes.for2d = Helper.foreach2d
  self.cubes.for2d_with_idx = Helper.foreach2d_with_index
end

function Game:is_below_empty(c)
  return c.y > 1 and not self.cubes[c.y-1][c.x]
end

function Game:drop_the_cube(c)
  c:set_pos(c.x, c.y - 1)
  c:drop()
  self.cubes[c.y][c.x] = c     -- this is actually quite dangerous. we can only do this
  self.cubes[c.y+1][c.x] = nil -- when we are sure "below_is_empty."
end

-- let's keep this simple and stupid for now. it's a lot easier to understand the flow.
function Game:next_state(now_t, last_t)
  self.cubes:for2d(function(c)        
    if c:is_waiting() then
      if self:is_below_empty(c) then 
        self:drop_the_cube(c)
      end
    elseif c:is_dropping() then
      c:drop_a_frame(now_t, last_t)
      if c:arrived_at_logical_position() then
        if self:is_below_empty(c) then
          self:drop_the_cube(c)
        else
          c:wait()
          c:update_real_pos() 
        end
      end
    end     
  end)
end

local function do_check_chain_h(row, x)
  local right = x + 1
  while row[right] and 
        row[right]:is_waiting() and 
        row[right].id == row[x].id do right = right + 1 end
  local len = right - x
  local left = x - 1
  while row[left] and 
        row[left]:is_waiting() and 
        row[left].id == row[x].id do left = left - 1 end
  len = len + (x - left) - 1         -- minus 1 because we've counted starting point twice.
  return (len >= 3), left+1, right-1 -- return whole range
end

local function do_check_chain_v(map, x, y)
  local up = y + 1
  while map[up][x] and 
        map[up][x]:is_waiting() and 
        map[up][x].id == map[y][x].id do up = up + 1 end
  local len = up - y
  local down = y - 1
  while map[down] and 
        map[down][x] and 
        map[down][x]:is_waiting() and 
        map[down][x].id == map[y][x].id do down = down - 1 end
  len = len + (y - down) - 1         -- minus 1 because we've counted starting point twice.
  return (len >= 3), down+1, up-1    -- return whole range
end

local function mark_for_delete_h(map, y, leftbound, rightbound)
  for i = leftbound, rightbound do
    map[y][i].need_delete = true
  end
end

local function mark_for_delete_v(map, x, bottombound, topbound)
  for i = bottombound, topbound do
    map[i][x].need_delete = true
  end
end

function Game:process_chaining()
  local chained, count = false, 0
  self.cubes:for2d(function(c)
    if c.need_check then 
      local res, lowerbound, upperbound = do_check_chain_v(self.cubes, c.x, c.y)
      if res then
        mark_for_delete_v(self.cubes, c.x, lowerbound, upperbound)
        chained = true
      end
      res, lowerbound, upperbound = do_check_chain_h(self.cubes[c.y], c.x)
      if res then 
        mark_for_delete_h(self.cubes, c.y, lowerbound, upperbound)
        chained = true
      end
      c.need_check = false
    end
  end)
  self.cubes:for2d(function(c)
    if c.need_delete then
      c:remove_body()
      self.cubes[c.y][c.x] = nil
      count = count + 1
    end
  end)
  return chained, count
end

-- CODE ABOVE NEED FIX --

function Game:cycle_event()
  if not self.cycle_event_ then
    self.last_t = system.getTimer() -- not os.clock() here
    self.cycle_event_ = function(event)
      self:next_state(event.time, self.last_t)
      self:process_chaining()
      self.last_t = event.time
    end
  end
  return self.cycle_event_
end

function Game:cleanup()
  print("cleaning up...")
  self.cubes:for2d(function(c)
    c:remove_body()
  end)
  collectgarbage("collect") -- just in case. might not be needed.
  print("garbage collected.")
end

return Game
