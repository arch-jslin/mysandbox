local orbit = require "orbit"
local view  = require "myapp_view"
local myapp = orbit.new()

function myapp.index(web)
  local songlist = {
    "Sgt. Pepper's Lonely Hearts Club Band",
    "With a Little Help from My Friends",
    "Lucy in the Sky with Diamonds",
    "Getting Better",
    "Fixing a Hole",
    "She's Leaving Home",
    "Being for the Benefit of Mr. Kite!",
    "Within You Without You",
    "When I'm Sixty-Four",
    "Lovely Rita",
    "Good Morning Good Morning",
    "Sgt. Pepper's Lonely Hearts Club Band (Reprise)",
    "A Day in the Life"
  }
  
  local members = {
    { name = 'AAA', 
      info = { 
        {'email', 'AAA@mail.hahaha.org'},
        {'公司', 'This is a bullshit company'},
        {'msn', 'AAA_msn@mail.hahaha.org'},
        {'blog', 'http://hahaha.org'}
      } 
    },
    { name = 'BBB', 
      info = { 
        {'email', 'BBB@hehehe.org'},
        {'公司', 'This is a fucking-stupid company'},
        {'FB', 'http://www.facebook.com/user/hehehe'},
        {'site', 'http://hehehe.org'}
      } 
    },
  }
  
  return view.render_index(songlist, members)
end

myapp:dispatch_get(myapp.index, "/")

return myapp.run