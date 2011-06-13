local orbit = require "orbit"
local view  = require "myapp_view"
local myapp = orbit.new()

local function substitute_links(t)
  for i = 1, #t do
    if t[i].link then
      t[i][2] = '<a href="'..t[i].link..'" target="_blank">'..t[i][2]..'</a>'
    elseif string.sub(t[i][2], 1, 7) == 'http://' then
      t[i][2] = '<a href="'..t[i][2]..'" target="_blank">'..t[i][2]..'</a>'
    end
  end
end

local function add_href(t)
  for i = 1, #t do
    substitute_links(t[i].info)
  end
end

function myapp.index(web)
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
  add_href(members)
  return view.render_page(    
    { title = "Test"}, 
    { view.render_member( members, "Test" ) } 
  )
end

myapp:dispatch_get(myapp.index, "/")

return myapp.run