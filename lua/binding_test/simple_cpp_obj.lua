
local s = Simple.create(6)
print(Simple.getID(s))

-- print(Simple.getID(1))  -- test for type-check

local t = os.clock()
for i = 1, 50000000 do 
  Simple.setID(s, 12) 
end
print( (os.clock() - t) .. " and you should times 10." )

print(Simple.getID(s))

Simple.destroy(s)
