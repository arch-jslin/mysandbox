
local function main()
  local director = require "director"
  local mainGroup = display.newGroup()
	mainGroup:insert(director.directorView)
	director:changeScene("menu")
	return true
end

main()
