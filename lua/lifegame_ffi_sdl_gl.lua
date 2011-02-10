----------------
local ffi = require "ffi"
ffi.cdef( io.open('c:\\libs\\cpp\\SDL\\ffi_SDL.h', 'r'):read('*a'))
local SDL = ffi.load('c:\\libs\\cpp\\SDL\\SDL')
package.path = "c:\\local_gitrepo\\luajit-opencl"..package.path
local GL = require "gl"
----------------
local SDL_Rect = ffi.typeof("SDL_Rect")
----------------

local game = {}

game.WIDTH        = 800
game.HEIGHT       = 600
game.INIT_OPTION  = 0x0000FFFF -- SDL_INIT_EVERYTHING
game.VIDEO_OPTION = 0x01 + 0x40000000
                    -- 0x01 + ??? + 0x02
                    -- SDL_HWSURFACE | SDL_GL_DOUBLEBUFFER | SDL_OPENGL

function game:init()
  SDL.SDL_Init(self.INIT_OPTION)
  SDL.SDL_WM_SetCaption("SDL + OpenGL Game of Life", "SDL")
  self.screen = SDL.SDL_SetVideoMode(self.WIDTH, self.HEIGHT, 32, self.VIDEO_OPTION)
end

function game:run()
  local event = ffi.new("SDL_Event")
  if SDL.SDL_PollEvent(event) == 1 then
    local etype = event.type
    if etype == SDL.SDL_QUIT then
      return false
    elseif etype == SDL.SDL_KEYDOWN then
      sym = event.key.keysym.sym
      if sym == SDL.SDLK_q or sym == SDL.SDLK_ESCAPE then
        return false
      end
    end
  end
  return true
end

function game:render()
  local rect  = SDL_Rect(100, 100, 10, 10);
  SDL.SDL_FillRect(self.screen, rect, 0xffff8855)
  SDL.SDL_UpdateRect(self.screen, 0, 0, 0, 0)
end

local function main()
  game:init()
  while game:run() do
    game:render()
  end
end

main()