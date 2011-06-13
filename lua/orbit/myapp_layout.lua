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
    if i == 1 then
      res[i] = td{class = "item", r[i]}
    else
      res[i] = td(r[i])
    end
  end
  return res
end

function layout.htable(structure, id, row_style)
  local res = {}
  local count = 0
  for _, v in ipairs(structure) do
    if row_style == "odd_even" then
      table.insert(res, tr{
        class = count % 2 == 0 and "odd" or "even", v})    
    else table.insert(res, tr(v)) end
    count = count + 1
  end
  return H'table'{ id = id, res }
end

function layout.htable2d(t, id, row_style)
  for i = 1, #t do
    t[i] = layout.columnify( t[i] )
  end
  return layout.htable(t, id, row_style)
end

orbit.htmlify(layout, '.+')

return layout