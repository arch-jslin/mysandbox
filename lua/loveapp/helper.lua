
local helper = {}

helper.len_sq = function(o1, o2)
  local dx = o1.x_ - o2.x_
  local dy = o1.y_ - o2.y_
  return dx*dx + dy*dy
end

return helper
