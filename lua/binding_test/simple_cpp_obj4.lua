
local s = Simple.Simple(7)
print(s:getID())

local t = os.clock()
for i = 1, 25000000 do 
  s:setID(14) 
end
print( (os.clock() - t) .. " and you should times 20." )

print(s:getID().." "..s:getName())

local s2= Simple.Simple(8)
print(s2:getID())
s2:setID(16)
print(s2:getID().." "..s2:getName())

