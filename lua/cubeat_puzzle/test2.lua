
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local Test      = require 'pl.test'
local MapUtils  = require 'maputils'
local PuzzleGen = require 'puzzle_gen'

Test.timer( "", 1, function(res) MapUtils.display( PuzzleGen:generate((tonumber(arg[1]) or 4), 6, 10) ) end)

print("answer_called_times: "..PuzzleGen.answer_called_times)
print("back_track_times: "..PuzzleGen.back_track_times)
print("regen_times: "..PuzzleGen.regen_times)
print("time_used_by_shuffle: "..PuzzleGen.time_used_by_shuffle)
print("time_used_by_find_chain: "..PuzzleGen.time_used_by_find_chain)
