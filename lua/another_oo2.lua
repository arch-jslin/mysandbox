-- Another OO comparison 1 -----------------------------------
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

-- Closure approach

--------------------
-- 'mariner module':
--------------------
mariner = {}

-- Global private variables:
--[[
local idcounter = 0
local defaultmaxhp = 200
local defaultshield = 10

-- Global private methods
local function printhi ()
   print ("HI")
end

-- Access to global private variables
function mariner.setdefaultmaxhp (value)
   defaultmaxhp = value
end

-- Global public variables:
mariner.defaultarmorclass = 0
--]]
function mariner.new ()
   local self = {}

   -- Private variables:
   --local maxhp = defaultmaxhp
   local hp = 10
   local mp = 10
   --[[local armor
   local armorclass = mariner.defaultarmorclass
   local shield = defaultshield

   -- Public variables:
   self.id = idcounter
   idcounter = idcounter + 1

   -- Private methods:
   local function updatearmor ()
      armor = armorclass*5 + shield*13
   end

   -- Public methods:
   function self.heal (deltahp)
      hp = math.min (maxhp, hp + deltahp)
   end
   function self.sethp (newhp)
      hp = math.min (maxhp, newhp)
   end
   function self.gethp ()
      return hp
   end
   function self.setarmorclass (value)
      armorclass = value
      updatearmor ()
   end
   function self.setshield (value)
      shield = value
      updatearmor ()
   end
   function self.dumpstate ()
      return string.format ("maxhp = %d\nhp = %d\narmor = %d\narmorclass = %d\nshield = %d\n",
			    maxhp, hp, armor, armorclass, shield)
   end--]]
  function self.damage(n)
    hp = hp - n
  end
  function self.cast(n)
    mp = mp - n
  end
  function self.fireball(enemy)
    enemy.damage(5)
    self.cast(5)
  end
  function self.heal()
    self.damage(-5)
    self.cast(5)
  end

   -- Apply some private methods
   --updatearmor ()

   return self
end

-----------------------------
-- 'infested_mariner' module:
-----------------------------

-- Polymorphism sample

infested_mariner = {}

function infested_mariner.bless (self)
   -- No need for 'local self = self' stuff :)

   -- New private variables:
   local explosion_damage = 700

   -- New methods:
   function self.set_explosion_damage (value)
      explosion_damage = value
   end
   function self.explode ()
      print ("EXPLODE for "..explosion_damage.." damage!!\n")
   end

   -- Some inheritance:
   local mariner_dumpstate = self.dumpstate -- Save parent function (not polluting global 'self' space)
   function self.dumpstate ()
      return mariner_dumpstate ()..string.format ("explosion_damage = %d\n", explosion_damage)
   end

   return self
end

function infested_mariner.new ()
   return infested_mariner.bless (mariner.new ())
end

