----------------
local ffi = require "ffi"
ffi.cdef( io.open('c:\\libs\\cpp\\SDL\\ffi_SDL.h', 'r'):read('*a'))
local SDL = ffi.load('c:\\libs\\cpp\\SDL\\SDL')
package.path = "c:\\local_gitrepo\\luajit-opencl"..package.path
local GL = require "gl"
local GLU= require "glu"
----------------

local game = {}

game.WIDTH        = 800
game.HEIGHT       = 600
game.INIT_OPTION  = 0x0000FFFF -- SDL_INIT_EVERYTHING
game.VIDEO_OPTION = -- 0x01 + 0x40000000
                    bit.bor(bit.bor(0x01, SDL.SDL_GL_DOUBLEBUFFER), 0x02)
                    -- SDL_HWSURFACE | SDL_GL_DOUBLEBUFFER | SDL_OPENGL

function game:init()
  SDL.SDL_Init(self.INIT_OPTION)
  SDL.SDL_WM_SetCaption("SDL + OpenGL Game of Life", "SDL")
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_RED_SIZE,        8);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_GREEN_SIZE,      8);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_BLUE_SIZE,       8);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_ALPHA_SIZE,      8);

  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_DEPTH_SIZE,      16);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_BUFFER_SIZE,     32);

  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_ACCUM_RED_SIZE,  8);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_ACCUM_GREEN_SIZE,8);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_ACCUM_BLUE_SIZE, 8);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_ACCUM_ALPHA_SIZE,8);

  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_MULTISAMPLEBUFFERS,  1);
  SDL.SDL_GL_SetAttribute(SDL.SDL_GL_MULTISAMPLESAMPLES,  2);  
  
  self.screen = SDL.SDL_SetVideoMode(self.WIDTH, self.HEIGHT, 32, self.VIDEO_OPTION)
  
  GL.glClearColor(0, 0, 0, 0);
  GL.glViewport(0, 0, self.WIDTH, self.HEIGHT);
  GL.glMatrixMode(GL.GL_PROJECTION);
  GL.glLoadIdentity();
  GL.glOrtho(0, self.WIDTH, self.HEIGHT, 0, 1, -1);
  GL.glMatrixMode(GL.GL_MODELVIEW);
  GL.glEnable(GL.GL_TEXTURE_2D);
  GL.glLoadIdentity();
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
  GL.glClear( bit.bor(GL.GL_COLOR_BUFFER_BIT, GL.GL_DEPTH_BUFFER_BIT) );
  GL.glLoadIdentity();

  GL.glBegin(GL.GL_QUADS);
    GL.glColor3f(1, 0, 0); GL.glVertex3f(0, 0, 0);
    GL.glColor3f(1, 1, 0); GL.glVertex3f(100, 0, 0);
    GL.glColor3f(1, 0, 1); GL.glVertex3f(100, 100, 0);
    GL.glColor3f(1, 1, 1); GL.glVertex3f(0, 100, 0);
  GL.glEnd();
  SDL.SDL_GL_SwapBuffers();
end

function game:destroy()
  SDL.SDL_FreeSurface(self.screen)
  SDL.SDL_Quit()
end

local function main()
  game:init()
  while game:run() do
    game:render()
  end
  game:destroy()
end

main()