
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = require 'maputils'
local List = require 'pl.List'
local Test = require 'pl.test'
local tablex = require 'tablex2'
local Helper = require 'helpers'
local random, Stack = Helper.random, Helper.stack

math.randomseed(os.time())

local testmap =
{{0,0,0,0,0},
 {0,0,0,0,0},
 {0,0,2,0,0},
 {0,0,1,0,0},
 {0,0,3,2,0},
 {0,0,3,4,2},
 {0,4,4,5,4},
 {0,1,3,1,1}}
testmap.height = 8
testmap.width  = 5

local ansmap1 = 
{{0,0,0,0,0},
 {0,0,2,0,0},
 {0,0,1,0,0},
 {0,0,3,2,0},
 {0,0,3,4,0},
 {0,4,4,5,2},
 {0,1,3,1,4},
 {0,0,0,0,1}}
ansmap1.height = 8
ansmap1.width  = 5
 
local ansmap2 = 
{{0,0,0,0,0},
 {0,0,2,0,0},
 {0,0,1,0,2},
 {0,0,3,2,4},
 {0,0,3,4,1},
 {0,4,4,5,0},
 {0,1,3,1,0},
 {0,0,0,0,0}}
ansmap2.height = 8
ansmap2.width  = 5

local ansmap3 = 
{{0,0,0,0,0},
 {0,0,0,0,0},
 {0,0,0,0,0},
 {1,0,0,0,0},
 {2,0,0,0,0},
 {2,0,0,0,0},
 {3,3,3,0,0},
 {2,1,1,0,0}}
ansmap3.height = 8
ansmap3.width  = 5

local chain15 = 
{{0,2,0,0,0,0},
 {0,4,2,1,1,0},
 {4,3,3,2,3,0},
 {2,4,3,3,2,0},
 {1,2,2,3,2,0},
 {1,1,4,2,3,0},
 {2,1,3,4,3,0},
 {1,2,2,1,3,1},
 {4,1,4,4,2,3},
 {1,1,3,4,1,1}}
chain15.height = 10
chain15.width  = 6 

testmap = List.reverse(testmap)
ansmap1 = List.reverse(ansmap1)
ansmap2 = List.reverse(ansmap2)
ansmap3 = List.reverse(ansmap3)
chain15 = List.reverse(chain15)
 
Test.asserteq(MapUtils.pushup_horizontally(testmap, 2, 1, 3), true)
Test.asserteq(testmap, ansmap1)
Test.asserteq(MapUtils.pushup_vertically(testmap, 5, 1, 3), true)
Test.asserteq(testmap, ansmap2)
Test.asserteq(MapUtils.gen_map_from_exprs(5, 8, {30111, 03211, 30312}), ansmap3)
Test.asserteq(MapUtils.gen_map_from_exprs(5, 8, {30011, 03011, 30012}), ansmap3)
Test.asserteq(MapUtils.check_puzzle_correctness(ansmap3), true)
Test.asserteq(MapUtils.check_puzzle_correctness(chain15), true)

local intersects_of, starters, counter = MapUtils.create_intersect_sheet(6, 10) -- it's actually only 6*9

Test.asserteq(counter, 189)
Test.asserteq(#starters, 9) -- don't use vertical combinations as starters

local a = {1,2,3,4,5}
tablex.rotate(a,2)

Test.asserteq(a, {4,5,1,2,3})

local s = Stack()
s:push(1) s:push(2) s:push(3)
Test.asserteq(s.size, 3)
s:pop() s:pop()
Test.asserteq(s.size, 1)
 
Test.timer("", 10, function() 
  local counter = 0
  for v in Helper.perm_all2{1,2,3,4,5,6,7,8,9} do
    counter = counter + 1
    --for _,v2 in ipairs(v) do io.write(string.format("%3d",v2)) end
    --print()
  end
  print(counter)
end)