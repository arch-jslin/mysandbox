-- KISS impl of guessing numbers ---------------------------

local rand, floor, abs = math.random, math.floor, math.abs
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

local AIPhase = function(lowerb, upperb)
  local guess = lowerb + random(upperb - lowerb)
  local ask_for_hint = function(g)
    io.write("Is your answer "..g.."? (too (b)ig/too (s)mall/(y)es): ")
	return io.read()
  end
  repeat 
    local hint = ask_for_hint(guess)
	while hint ~= "b" and hint ~= "s" and hint ~= "y" do
	  hint = ask_for_hint(guess)
	end
	if hint == "b" then
	  upperb = guess
	  guess = floor((upperb + lowerb)/2)
	  coroutine.yield()
	elseif hint == "s" then
	  lowerb = guess
	  guess = floor((upperb + lowerb)/2)
	  coroutine.yield()
	else -- got it
	  print("Got'cha!")
	  return true
	end
  until upperb - lowerb <= 1
  print("Then your answer must be "..lowerb.."!")
  return true -- means "win"
end

local main = function(lowerb, upperb)
  lowerb, upperb = lowerb or 0, upperb or 100
  if lowerb > upperb then 
    lowerb, upperb = upperb, lowerb
  end
  math.randomseed(os.time()) -- renew seed for every process.
  ai_phase = coroutine.wrap(function() return AIPhase(lowerb, upperb) end)
  
  while not ai_phase() do end
end

main(tonumber(arg[1]), tonumber(arg[2]))
