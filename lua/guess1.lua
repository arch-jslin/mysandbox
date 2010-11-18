-- KISS impl of guessing numbers ---------------------------

local rand, floor, abs = math.random, math.floor, math.abs
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

local ask_for_hint = function(g)
  io.write("Is your answer "..g.."? (too (b)ig/too (s)mall/(y)es): ")
	return io.read()
end

local ask_for_your_guess = function(lb, ub)
  io.write("Your guess ("..lb.."~"..ub.."): ")
  return io.read()
end

local AIPhase = function(lowerb, upperb)
  local guess = lowerb + random(upperb - lowerb)
  repeat 
    local hint = nil
	  repeat
	    hint = ask_for_hint(guess)
	  until hint == "b" or hint == "s" or hint == "y"
	  if hint == "b" then
	    upperb = guess - 1
	    guess = floor((upperb + lowerb)/2)
	    coroutine.yield(guess)
	  elseif hint == "s" then
	    lowerb = guess + 1
	    guess = floor((upperb + lowerb)/2)
	    coroutine.yield(guess)
  	else -- got it
  	  print("Got'cha!")
	    return false
  	end
  until upperb <= lowerb
  print("Your answer must be "..lowerb.."!")
  return false -- means "computer wins"
end

local main = function(lowerb, upperb)
  lowerb, upperb = lowerb or 0, upperb or 100
  if lowerb > upperb then 
    lowerb, upperb = upperb, lowerb
  end
  math.randomseed(os.time()) -- renew seed for every process.
  local ai_phase = coroutine.wrap(function() return AIPhase(lowerb, upperb) end)
  local ai_ans   = lowerb + random(upperb - lowerb)
  
  repeat 
    local guess, res = nil, true
    repeat 
      guess = tonumber(ask_for_your_guess(lowerb, upperb-1))
    until guess and guess >= lowerb and guess < upperb
    if guess > ai_ans then
      print("Your guess is too big.")
      res = ai_phase()
    elseif guess < ai_ans then
      print("Your guess is too small.")
      res = ai_phase()
    else -- you got it
      print("You got it.")
      break
    end
  until not res
end

main(tonumber(arg[1]), tonumber(arg[2]))
