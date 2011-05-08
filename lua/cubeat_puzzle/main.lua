
local MapUtils  = require 'maputils'
local PuzzleGen = require 'puzzle_gen'

local WIDTH, HEIGHT = display.contentWidth, display.contentHeight

local cube = display.newImage( "rc/cr.png" )
cube:scale(3, 3)
cube.x, cube.y = WIDTH/2, HEIGHT/2

local myText = display.newText( "Hello, World!", 0, 0, native.systemFont, 40 )
myText.x = display.contentWidth / 2
myText.y = display.contentWidth / 4
myText:setTextColor( 255,110,110 )

local t = os.clock()
MapUtils.display( PuzzleGen:generate(18) )
print("Time spent calculating puzzle: "..(os.clock()-t) )

print("answer_called_times: "..PuzzleGen.answer_called_times)
print("back_track_times: "..PuzzleGen.back_track_times)
print("regen_times: "..PuzzleGen.regen_times)
print("time_used_by_shuffle: "..PuzzleGen.time_used_by_shuffle)
print("time_used_by_find_chain: "..PuzzleGen.time_used_by_find_chain)

