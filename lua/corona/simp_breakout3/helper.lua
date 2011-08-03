local function hitTest(obj1, obj2)
  if obj1 == nil or obj2 == nil then
    return false
  end
  local left = obj1.contentBounds.xMin < obj2.contentBounds.xMin and obj1.contentBounds.xMax > obj2.contentBounds.xMin
  local right = obj1.contentBounds.xMin > obj2.contentBounds.xMin and obj1.contentBounds.xMin < obj2.contentBounds.xMax
  local up = obj1.contentBounds.yMin < obj2.contentBounds.yMin and obj1.contentBounds.yMax > obj2.contentBounds.yMin
  local down = obj1.contentBounds.yMin > obj2.contentBounds.yMin and obj1.contentBounds.yMin < obj2.contentBounds.yMax
  
  if (left or right) and (up or down) then
    if obj1.x + obj1.width/3 > obj2.contentBounds.xMin and obj1.x - obj1.width/3 < obj2.contentBounds.xMax then
      return 1
    else
      return 2
    end
  else 
    return false
  end
end

return {
  hitTest = hitTest
}
