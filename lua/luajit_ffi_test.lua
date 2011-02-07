
-- Original code from lua-l and gamedevgeek
-- As seen here: http://permalink.gmane.org/gmane.comp.lang.lua.general/74086

local ffi=require "ffi"
ffi.cdef( io.open('c:\\libs\\cpp\\SDL\\ffi_SDL.h', 'r'):read('*a'))

SDL=ffi.load('c:\\libs\\cpp\\SDL\\SDL')

SCREEN_WIDTH,SCREEN_HEIGHT=640,480

-- wrapper functions
function SDL_LoadBMP(file)
  return SDL.SDL_LoadBMP_RW(SDL.SDL_RWFromFile(file, "rb"), 1)
end
--
function SDL_BlitSurface(src, srcrect, dst, dstrect)
  return SDL.SDL_UpperBlit(src, srcrect, dst, dstrect)
end
--

-- Initialize SDL
local SDL_INIT_VIDEO=0x20
SDL.SDL_Init(SDL_INIT_VIDEO)

-- set the title bar
SDL.SDL_WM_SetCaption("SDL Test","SDL Test")

-- create window
local screen = SDL.SDL_SetVideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0)

-- load bitmap to temp surface
local temp = SDL_LoadBMP('sdl_logo.bmp') -- get it from

-- convert bitmap to display format
local bg = SDL.SDL_DisplayFormat(temp)

-- free the temp surface
SDL.SDL_FreeSurface(temp);

local event=ffi.new("SDL_Event")

local gameover = false;
local SDL_Rect = ffi.typeof "SDL_Rect"
local rect = SDL_Rect(100, 100, 10, 10);

-- message pump
while not gameover do
  -- look for an event
  if SDL.SDL_PollEvent(event)==1 then
    -- an event was found
    local etype=event.type
    if etype==SDL.SDL_QUIT then
      -- close button clicked
      gameover=true
      break
    end

    if etype==SDL.SDL_KEYDOWN then
      -- handle the keyboard
      sym=event.key.keysym.sym
      if sym==SDL.SDLK_q or sym==SDL.SDLK_ESCAPE then
        gameover=true
        break
      end
    end
  end
  SDL.SDL_FillRect(screen, rect, 0xffff8855)
  --SDL_BlitSurface(bg, nil, screen, nil)
  SDL.SDL_UpdateRect(screen, 0,0,0,0)
end
