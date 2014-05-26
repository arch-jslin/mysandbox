
-- basic timer --
local timers_ = {}

local function set(f, dur, loop)
  loop = loop or 1
  table.insert(timers_, { invoke = f, time = 0, dur = dur, loop = loop } )
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

local function update(dt)
  local delete_timers = {}
  
  -- run the timer
  for _, v in ipairs(timers_) do
    v.time = v.time + dt  
    if v.time > v.dur then
      v.time = 0
      if v.loop > 0 then 
        v.loop = v.loop - 1
      end
      v.invoke()
    end
    if v.loop == 0 then
      table.insert(delete_timers, v)
    end
  end
  
  -- remove the elapsed timer
  for _, v in ipairs(delete_timers) do 
    unordered_remove(timers_, v)
  end
end

return { set = set, update = update } 
