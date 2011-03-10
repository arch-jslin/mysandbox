
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = dofile 'maputils.lua'
local List = require 'pl.List'
local Test = require 'pl.test'

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
 
testmap = List.reverse(testmap)
ansmap1 = List.reverse(ansmap1)
ansmap2 = List.reverse(ansmap2)
 
Test.asserteq(MapUtils.pushup_horizontally(testmap, 2, 1, 3), true)
Test.asserteq(testmap, ansmap1)
Test.asserteq(MapUtils.pushup_vertically(testmap, 5, 1, 3), true)
Test.asserteq(testmap, ansmap2)

MapUtils.display( MapUtils.genmap_from_exprs({height = 8, width = 5, 30011, 03011, 30012}) )