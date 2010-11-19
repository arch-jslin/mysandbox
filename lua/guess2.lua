-- KISS impl of guessing numbers ---------------------------
-- try to refine coroutine application ---------------------

local rand, floor, abs = math.random, math.floor, math.abs
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

local ask_for_hint = function(g)
  local hint = nil
  repeat
    io.write("Is your answer "..g.."? (too (b)ig/too (s)mall/(y)es): ")
    hint = io.read()
  until hint == "b" or hint == "s" or hint == "y"
	return hint
end

local ask_for_guess = function(lb, ub)
  local guess = nil
  repeat
    io.write("Your guess ("..lb.."~"..ub.."): ")
    guess = tonumber(io.read())
  until guess and guess >= lb and guess < ub
  return guess
end

local ask_for_preemption = function()
  local res = nil
  repeat
    io.write("Will you play first (y/n): ")
    res = io.read()
  until res == "y" or res == "n"
  return res
end

local AIPhase = function(lowerb, upperb)
  local guess, hint = nil, nil
  repeat 
	  if hint == nil then -- first round
      guess = lowerb + random(upperb - lowerb) -- initial guess
    elseif hint == "s" then
	    lowerb = guess + 1
	    guess = floor((upperb + lowerb)/2)
    elseif hint == "b" then 
      upperb = guess - 1
	    guess = floor((upperb + lowerb)/2)
  	elseif hint == "y" then
  	  print("Got'cha!")
	    return false
  	end
    hint = coroutine.yield(guess) 
  until upperb <= lowerb
  print("Your answer must be "..lowerb.."!")
  return false -- means "computer wins"
end

local UserPhase = function(ai_ans, lowerb, upperb, init_ai_guess)
  local ai_guess, hint = nil, nil
  repeat
    if not ai_guess and init_ai_guess then  -- first round, last hand
      hint = ask_for_hint(init_ai_guess)    -- new hint
    end
    local user_guess = ask_for_guess(lowerb, upperb) -- user guess
    if user_guess > ai_ans then
      print("Your guess is too big.")
    elseif user_guess < ai_ans then
      print("Your guess is too small.")
    end
    if user_guess ~= ai_ans then 
      ai_guess = coroutine.yield(hint) -- hint of the last round
      hint = ask_for_hint(ai_guess)    -- new hint
    end
  until user_guess == ai_ans
  print("Congratz. You got it.")
  return false -- means "player wins"
end

local logic = function(firsthand, lasthand)
  local res1, res2 = nil, nil
  while true do
    res1 = firsthand(res2)
    if res1 == false then return false end -- false means "end game"
    res2 = lasthand(res1)
    if res2 == false then return false end
    print("-----")
  end
  return true
end

local main = function(lowerb, upperb)
  lowerb, upperb = lowerb or 0, upperb or 100
  if lowerb > upperb then 
    lowerb, upperb = upperb, lowerb
  end
  math.randomseed(os.time()) -- renew seed for every process.
  local ai_ans   = lowerb + random(upperb - lowerb)
  local ai_phase = coroutine.wrap(function(init) return AIPhase(lowerb, upperb) end)
  local user_phase=coroutine.wrap(function(init) return UserPhase(ai_ans, lowerb, upperb-1, init) end) 
  
  local go_first = ask_for_preemption()
  if go_first == "y" then 
    logic(user_phase, ai_phase)
  elseif go_first == "n" then 
    logic(ai_phase, user_phase)
  else print("Leaving...")
  end
end

main(tonumber(arg[1]), tonumber(arg[2]))

