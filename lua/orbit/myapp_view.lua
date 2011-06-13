local orbit = require "orbit"
local layout= require "myapp_layout"
local view = {}

function view.render_page(header_opt, inner_html)
  return html{
    head{ 
      title( header_opt.title ),
      meta { ["http-equiv"] = "Content-Type",
        content = "text/html; charset=utf-8" },
      style{ 
        type  = 'text/css',
        media = 'screen',
        require 'style_css'
      }
    },
    body{ inner_html }
  }
end

function view.render_member(t, title)
  local res = { { td(title) } }
  for _,v in ipairs(t) do
    table.insert(res, td(v.name)) 
    table.insert(res, td( layout.htable2d(v.info, "info") ))
  end
  return div{ id = "attenders", layout.htable(res, "containing_table", "odd_even") }
end

orbit.htmlify(view, 'render_.+', 'add_href')

return view