-- Another OO comparison 1 -----------------------------------
-- http://lua-users.org/wiki/ObjectOrientationClosureApproach

-- Table approach

--------------------
-- 'mariner module':
--------------------
mariner = {}
--[[
-- Global private variables:
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
--]]
-- Global public variables:
--[[
mariner.defaultarmorclass = 0

local function mariner_updatearmor (self)
   self.armor = self.armorclass*5 + self.shield*13
end
local function mariner_heal (self, deltahp)
   self.hp = math.min (self.maxhp, self.hp + deltahp)
end
local function mariner_sethp (self, newhp)
   self.hp = math.min (self.maxhp, newhp)
end
local function mariner_setarmorclass (self, value)
   self.armorclanss = value
   self:updatearmor ()
end
local function mariner_setshield (self, value)
   self.shield = value
   self:updatearmor ()
end
local function mariner_dumpstate (self)
   return string.format ("maxhp = %d\nhp = %d\narmor = %d\narmorclass = %d\nshield = %d\n",
			 self.maxhp, self.hp, self.armor, self.armorclass, self.shield)
end--]]
local function damage(self, n)
  self.hp = self.hp - n
end
local function cast(self, n)
  self.mp = self.mp - n
end
local function fireball(self, enemy)
  enemy:damage(5)
  self:cast(5)
end
local function heal(self)
  self:damage(-5)
  self:cast(5)
end


function mariner.new ()
   local self = {
      --[[id = idcounter,
      maxhp = defaultmaxhp,
      armorclass = mariner.defaultarmorclass,
      shield = defaultshield,
      updatearmor = mariner_updatearmor,
      heal = mariner_heal,
      sethp = mariner_sethp,
      setarmorclass = mariner_setarmorclass,
      setshield = mariner_setshield,
      dumpstate = mariner_dumpstate, --]]
      damage = damage,
      cast = cast,
      fireball = fireball,
      heal = heal
   }
   self.hp = 10 --self.maxhp
   self.mp = 10

   --idcounter = idcounter + 1

   --self:updatearmor ()

   return self
end

-----------------------------
-- 'infested_mariner' module:
-----------------------------

-- Polymorphism sample

infested_mariner = {}

local function infested_mariner_set_explosion_damage (self, value)
   self.explosion_damage = value
end
local function infested_mariner_explode (self)
   print ("EXPLODE for "..self.explosion_damage.." damage!!\n")
end
local function infested_mariner_dumpstate (self)
   return self:mariner_dumpstate ()..string.format ("explosion_damage = %d\n", self.explosion_damage)
end

function infested_mariner.bless (self)
   self.explosion_damage = 700
   self.set_explosion_damage = infested_mariner_set_explosion_damage
   self.explode = infested_mariner_explode

   -- Uggly stuff:
   self.mariner_dumpstate = self.dumpstate
   self.dumpstate = infested_mariner_dumpstate

   return self
end

function infested_mariner.new ()
   return infested_mariner.bless (mariner.new ())
end

