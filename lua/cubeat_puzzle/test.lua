
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = require 'maputils'
local List = require 'pl.List'
local Test = require 'pl.test'
local tablex = require 'tablex2'
local Helper = require 'helpers'
local random, Stack = Helper.random, Helper.stack
local C3H, C4H, C5H, C3V, C4V = unpack(require 'chain')

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
 
Test.asserteq(MapUtils.pushup_horizontally(testmap, 2, 1, 3, 0), true)
Test.asserteq(testmap, ansmap1)
Test.asserteq(MapUtils.pushup_vertically(testmap, 5, 1, 3, 0), true)
Test.asserteq(testmap, ansmap2)
Test.asserteq(MapUtils.gen_map_from_exprsx(5, 8, {C3H(111), C3V(211), C3H(312)}), ansmap3)
Test.asserteq(MapUtils.gen_map_from_exprsx(5, 8, {C3H(011), C3V(011), C3H(012)}), ansmap3)
Test.asserteq(MapUtils.check_puzzle_correctness(ansmap3, 3), true)
Test.asserteq(MapUtils.check_puzzle_correctness(chain15, 15), true)

local allcomb, starters, counter = MapUtils.create_all_combinations(6, 10) -- it's actually only 6*9

Test.asserteq(#allcomb[50].intersects, 30)
Test.asserteq(#allcomb[133].intersects, 10)
Test.asserteq(counter, 147)
Test.asserteq(#starters, 9)  -- don't use vertical combinations as starters

local a = {1,2,3,4,5}
tablex.rotate(a,2)

Test.asserteq(a, {4,5,1,2,3})

local s = Stack()
s:push(1) s:push(2) s:push(3)
Test.asserteq(s.size, 3)
s:pop() s:pop()
Test.asserteq(s.size, 1)

