local orbit = require "orbit"
local layout = {}

function layout.input(caption, name)
  return td(caption), td( input{type='text', name=name} )
end

function layout.submit(caption)
  return td( input{type='submit', value=caption} )
end

function layout.columnify(r)
  local res = {}
  for i = 1, #r do
    res[i] = td(r[i])
  end
  return res
end

function layout.htable(structure)
  local res = {}
  for _, v in ipairs(structure) do
    table.insert(res, tr(v))
  end
  return H'table'(res)
end

function layout.htable2d(t)
  for i = 1, #t do
    t[i] = layout.columnify( t[i] )
  end
  return layout.htable(t)
end

orbit.htmlify(layout, '.+')

return layout