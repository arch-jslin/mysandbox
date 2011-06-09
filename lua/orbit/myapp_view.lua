local orbit = require "orbit"
local layout= require "myapp_layout"
local view = {}

function view.render_page(inner_html)
  return html{
    head( title "Song List" ),
    body( inner_html )
  }
end

function view.render_member(t)
  local res = { {td"Name", td"Info"} }
  for _,v in ipairs(t) do
    table.insert(res, { td(v.name), td(layout.htable2d(v.info)) } )
  end
  return layout.htable(res)
end

function view.render_index(list, members)
  local res = {}
  local songlist_view = {}
  for _, entry in ipairs(list) do 
    table.insert(songlist_view, li(entry))
  end
  table.insert(res, ul(songlist_view))
  table.insert(res, form {
    layout.htable {
      { layout.input("First Name: ", "first") },
      { layout.input("Last Name: ", "last") },
      { layout.submit "Submit!", layout.submit "Cancel" }
    }
  })
  
  table.insert(res, view.render_member(members))
  
  return view.render_page(res)
end

orbit.htmlify(view, 'render_.+')

return view