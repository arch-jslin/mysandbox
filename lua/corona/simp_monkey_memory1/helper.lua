local function hitTest(obj1, obj2)
  if obj1.contentBounds == nil or obj2.contentBounds == nil then
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

local function remove(o)
  if o.contentBounds then
    o:removeSelf()
  end
end

local function image(file)
  local o = display.newImage(file)
  o.tap_do = function(f)
    o:addEventListener('tap', function(e)
      f(o, e)
    end)
  end
  return o
end

local function text(s)
  local t = display.newText( s, 0, 0, native.systemFont, 54 )
  t:setTextColor( 255,255,255 )
  return t
end

local function random(n)
  return math.random()*n
end

local function frame_do(f)
  Runtime:addEventListener('enterFrame', f)
end

local function touch_do(f)
  Runtime:addEventListener('touch', f)
end

local function timer_do(t, f, loop)
  t = (t or 1) * 1000
  return timer.performWithDelay(t, f, loop)
end

return {
  hitTest = hitTest,
  image   = image,
  text    = text,
  random  = random,
  remove  = remove,
  frame_do= frame_do,
  touch_do= touch_do,
  timer_do= timer_do
}
