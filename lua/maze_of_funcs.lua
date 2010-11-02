-- Pretty fun concept provided by Lua book.
-- Make text based games could not be easier.

function room1()
  print "You see a way [s]outh."
  local move = io.read()
  if move == "s" then return room2()
  else 
    print "invalid move."
    return room1()
  end
end

function room2()
  print "You see the room goes [n]orth and [s]outh."
  local move = io.read()
  if move == "n" then return room1()
  elseif move == "s" then return room3() 
  else
    print "invalid move."
    return room2()
  end
end

function room3()
  print "You see the room goes [n]orth."
  local move = io.read()
  if move == "n" then return room2()
  else
    print "invalid move."
    return room3()
  end
end

room1()