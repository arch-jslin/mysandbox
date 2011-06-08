local orbit = require "orbit"
---------------------
local view = {}

function view.inputtext(caption, name)
  return td(caption), td( input{type='text', name=name} )
end

function view.submit(caption)
  return td( input{type='submit', value=caption} )
end

function view.htable(structure)
  local res = {}
  for _, v in ipairs(structure) do
    table.insert(res, tr(v))
  end
  return H'table'(res)
end

orbit.htmlify(view, '.+')
---------------------

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
  return myapp.render_index(songlist)
end

myapp:dispatch_get(myapp.index, "/")

function myapp.render_page(inner_html)
  return html{
    head( title "Song List" ),
    body( inner_html )
  }
end

function myapp.render_index(list)
  local res = {}
  local songlist_view = {}
  for _, entry in ipairs(list) do 
    table.insert(songlist_view, li(entry))
  end
  table.insert(res, ul(songlist_view))
  table.insert(res, form {
    view.htable {
      { view.inputtext("First Name: ", "first") },
      { view.inputtext("Last Name: ", "last") },
      { view.submit "Submit!", view.submit "Cancel" }
    }
  })
  return myapp.render_page(res)
end

orbit.htmlify(myapp, 'render_.+')

return myapp.run