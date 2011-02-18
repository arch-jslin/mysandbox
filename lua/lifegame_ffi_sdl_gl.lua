
package.path = [[c:\local_gitrepo\luajit-opencl]]..package.path

-- Pretty ugly for now, since LuaJIT2 FFI doesn't have a C-preprocessor, yet.
-- I don't do setmetatable(_G, {__index = ffi.C}) since I am not comfortable
-- with global namespace pollution.

local ffi = require "ffi"
local SDL = ffi.load([[c:\libs\cpp\SDL\SDL]])
local GL = require "gl"
ffi.cdef( io.open([[c:\libs\cpp\SDL\ffi_SDL.h]], 'r'):read('*a'))
-- Important: You'll have to generate that ffi_SDL.h yourself, using gcc -E:
-- echo '#include <SDL.h>" > stub.c    
-- gcc -I/path/to/SDL -E stub.c | grep -v '^#' > ffi_SDL.h 

-- Script usage:
-- luajit lifegame_ffi_sdl_gl.lua <render_method 1~4> <cell_size> <width> <height> [no_model_jit]
-- e.g luajit lifegame_ffi_sdl_gl.lua 2 2 1024 1024 no_model_jit

-- render methods are GL_POINTS, GL VERTEX_ARRAY, VBO, PBO, respectively
-- cell_size, width and height will decide the actual screen_size.
--   => screen_size = logical_size * cell_size
--   You can't optionally skip preceding options because I am too lazy to handle that.

-- no_model_jit: in order to verify if model (in the sense of model/view abstraction) 
--   performance, under the dominant factor of rendering threshold, will actually 
--   matter or not, you can manually add 'no_model_jit' as a last option. It will 
--   prevent the function "grid_iteration" and all subsequent calls from being 
--   JIT-compiled, recursively. That will cause this function and functions called 
--   by it to run completely in the interpreter. As a last note, LuaJIT's interpreter 
--   is already faster than original Lua interpreter by about 2x-4x.

-- DON'T RUN THIS WITH OLDER VERIONS OF LUAJIT OR PlAIN LUA INTERPRETER,
-- THE FFI CODE SEGMENTS ARE ALREADY ALL OVER THE PLACE, IT'S HOPELESS.
-- THIS IS SOLELY FOR THE PURPOSE OF BENCHMARKING.

-- This sample make use of https://github.com/malkia/luajit-opencl package
-- You'll need it to run the script. This script demonstrate how to use
-- LuaJIT2 FFI to integrate some simple SDL & GL function out-of-the-box.
-- (well, almost.)

ffi.cdef[[
typedef struct {GLfloat x,y,z;} SVertex;
typedef int (__attribute__((__stdcall__)) *PROC)();
typedef const char *LPCCH,*PCSTR,*LPCSTR;
typedef void (__attribute__((__stdcall__)) * PFNGLGENBUFFERSARBPROC) (GLsizei n, GLuint *buffers);
typedef void (__attribute__((__stdcall__)) * PFNGLBINDBUFFERARBPROC) (GLenum target, GLuint buffer);
typedef void (__attribute__((__stdcall__)) * PFNGLBUFFERDATAARBPROC) (GLenum target, GLsizeiptrARB size, const GLvoid *data, GLenum usage);
typedef void (__attribute__((__stdcall__)) * PFNGLBUFFERSUBDATAARBPROC) (GLenum target, GLintptrARB offset, GLsizeiptrARB size, const GLvoid *data);
typedef void (__attribute__((__stdcall__)) * PFNGLDELETEBUFFERSARBPROC) (GLsizei n, const GLuint *buffers);
typedef void (__attribute__((__stdcall__)) * PFNGLGETBUFFERPARAMETERIVARBPROC) (GLenum target, GLenum pname, GLint *params);
typedef GLvoid* (__attribute__((__stdcall__)) * PFNGLMAPBUFFERARBPROC) (GLenum target, GLenum access);
typedef GLboolean (__attribute__((__stdcall__)) * PFNGLUNMAPBUFFERARBPROC) (GLenum target);
typedef void (__attribute__((__stdcall__)) * PFNWGLSWAPINTERVALEXTPROC) (int option);
PROC __attribute__((__stdcall__)) wglGetProcAddress(LPCSTR);
]]
local GLext = {}
local function setupARBAPI()
  local t = {}
  t.glGenBuffersARB = ffi.cast("PFNGLGENBUFFERSARBPROC", GL.wglGetProcAddress("glGenBuffersARB")) -- VBO Name Generation Procedure
  t.glBindBufferARB = ffi.cast("PFNGLBINDBUFFERARBPROC", GL.wglGetProcAddress("glBindBufferARB")) -- VBO Bind Procedure
  t.glBufferDataARB = ffi.cast("PFNGLBUFFERDATAARBPROC", GL.wglGetProcAddress("glBufferDataARB")) -- VBO Data Loading Procedure
  t.glBufferSubDataARB = ffi.cast("PFNGLBUFFERSUBDATAARBPROC", GL.wglGetProcAddress("glBufferSubDataARB")) -- VBO Sub Data Loading Procedure
  t.glDeleteBuffersARB = ffi.cast("PFNGLDELETEBUFFERSARBPROC", GL.wglGetProcAddress("glDeleteBuffersARB")) -- VBO Deletion Procedure
  t.glGetBufferParameterivARB = ffi.cast("PFNGLGETBUFFERPARAMETERIVARBPROC", GL.wglGetProcAddress("glGetBufferParameterivARB")) -- return various parameters of VBO
  t.glMapBufferARB = ffi.cast("PFNGLMAPBUFFERARBPROC", GL.wglGetProcAddress("glMapBufferARB")) -- map VBO procedure
  t.glUnmapBufferARB = ffi.cast("PFNGLUNMAPBUFFERARBPROC", GL.wglGetProcAddress("glUnmapBufferARB")) -- unmap the VBO procedure
  t.wglSwapIntervalEXT = ffi.cast("PFNWGLSWAPINTERVALEXTPROC", GL.wglGetProcAddress("wglSwapIntervalEXT")) -- for opengl vsync
  t.wglSwapIntervalEXT(0)
  return t
end

---- Lua helper functions ------------

local randomseed, rand, floor, abs = math.randomseed, math.random, math.floor, math.abs
local band, rsh, lsh = bit.band, bit.rshift, bit.lshift
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

local function new_grid(w, h) -- this will setup zero-based lua table for testing purposes.
  local grid = {}             -- zero-based is ok with LuaJIT interpreter, but not plain Lua interpreter
  assert(w ~= 0 and h ~= 0)
  for y = 0, h+1 do
    grid[y] = {}
    for x = 0, w+1 do
      grid[y][x] = 0
    end
  end
  return grid
end

local function new_grid_ffi(w, h) 
  local grid = ffi.new("char[?]["..(w+2).."]", h+2) -- added automatic padding
  return grid
end

local function grid_print(grid, w, h)
  w, h = w or 15, h or 15
  if not grid then return end
  for y = 1, h do
    for x = 1, w do 
      io.write(string.format("%d ", grid[y][x]))
    end
    print()
  end
end

---- Game of Life abstract model --------------------

local function neighbor_count(old, y, x, h, w)
  local count = ( old[y-1][x-1] + old[y-1][x] + old[y-1][x+1] ) +
                ( old[ y ][x-1] +               old[ y ][x+1] ) +
                ( old[y+1][x-1] + old[y+1][x] + old[y+1][x+1] )
  return count
end

--local rule1 = ffi.new("char[9]", {0, 0, 1, 1, 0, 0, 0, 0, 0});
--local rule2 = ffi.new("char[9]", {0, 0, 0, 1, 0, 0, 0, 0, 0}); 
--what if we need different rule sets? how to do that with bitwise trick??
local function ruleset(now, count)
  return band(rsh(lsh(now, 2) + 8, count), 1)
end

local function wrap_padding(old, w, h)
  w, h = w or 15, h or 15
  -- side wrapping.
  for x = 2, w-1 do 
    old[h+1][x] = old[1][x]
    old[ 0 ][x] = old[h][x]
  end
  for y = 2, h-1 do 
    old[y][w+1] = old[y][1]
    old[y][ 0 ] = old[y][w]
  end
  -- .. and corner wrapping, obviously I am too stupid.
  old[1][w+1], old[h+1][1], old[h+1][w+1] = old[1][1], old[1][1], old[1][1]
  old[1][0],   old[h+1][0], old[h+1][w]   = old[1][w], old[1][w], old[1][w]
  old[0][1],   old[0][w+1], old[h][w+1]   = old[h][1], old[h][1], old[h][1]
  old[0][0],   old[0][w],   old[h][0]     = old[h][w], old[h][w], old[h][w]
end

local function grid_iteration(old, new, w, h, opt)

  if opt then jit.off(true, true) end 

  w, h = w or 15, h or 15
  wrap_padding(old, w, h)
  for y = 1, h do
    for x = 1, w do
      local res = ruleset( old[y][x], neighbor_count(old, y, x) )
      new[y][x] = res
    end
  end
  -- new and old can be used interchangably, no need to copy here
end

---- The game object ---------------------------------

local game = {}

function game:init()
  randomseed(os.time()) -- randomize at game initialization
  self.RENDER_OPT   = tonumber(arg[1]) or 2 -- use Vertex Array as default
  self.csize        = tonumber(arg[2]) or 2
  self.model_w      = tonumber(arg[3]) or 120 
  self.model_h      = tonumber(arg[4]) or 90 
  self.NO_MODEL_JIT = arg[5] == 'no_model_jit' and true or false  
  self.WIDTH        = self.model_w * self.csize
  self.HEIGHT       = self.model_h * self.csize
  self.t            = os.clock()
  self.iter         = 0
  
  self.vboID1       = ffi.new("unsigned int[1]", 0)
  self.pboID1       = ffi.new("unsigned int[1]", 0)
  self.texID1       = ffi.new("unsigned int[1]", 0)
  self.vertices     = ffi.new("SVertex[?]", self.model_w * self.model_h, {{0,0,0}} );
  self.bitmap       = ffi.new("unsigned char[?]", self.model_w * self.model_h * 4, {0} );  
  
  self:setupSDL();
  self:setupGL();
  
  if self.NO_MODEL_JIT then
    self.old = new_grid(self.model_w, self.model_h)
    self.new = new_grid(self.model_w, self.model_h)
  else 
    self.old = new_grid_ffi(self.model_w, self.model_h)
    self.new = new_grid_ffi(self.model_w, self.model_h)
  end  
  
  self.grids = {}
  self.grids[0], self.grids[1] = self.old, self.new
  
  for i = 1, self.model_w*self.model_h / 9 do 
    self.grids[0][random(self.model_h)+1][random(self.model_w)+1] = 1 
  end
  
  --setup OpenGL VBO API, need a query from wglGetProcAddress
  GLext = setupARBAPI()
  self:createVBO()      --create VBO ONLY AFTER you correctly setup ARB API
  self:createTexture()  --create Texture for render4 usage (search for render4)
  self:createPBO()      --create PBO
end

function game:run(event)
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

function game:update(t)
  print("Secs between updates: "..(t - self.t))
  --if t - self.t > 1.000 then
    --grid_iteration(self.old, self.new, self.model_w, self.model_h, self.iter)
    self.iter = self.iter % 256 + 1
    local new_index = self.iter % 2
    local old_index = bit.bxor(new_index, 1)
    grid_iteration(self.grids[old_index], self.grids[new_index], self.model_w, self.model_h, self.NO_MODEL_JIT)
    self.t = t
  --end
end

function game:render(render_)
  GL.glClear( bit.bor(GL.GL_COLOR_BUFFER_BIT, GL.GL_DEPTH_BUFFER_BIT) );
  GL.glLoadIdentity();
  local csizep = self.csize
  local csize  = csizep-1
  GL.glPointSize(csize);

  render_(self, csizep)

  SDL.SDL_GL_SwapBuffers();
end

function game:destroy()
  SDL.SDL_FreeSurface(self.screen)
  SDL.SDL_Quit()
  GLext.glDeleteBuffersARB(1, vboID1)
end

local render1, render2, render3, render4 -- pre-declare. to hide ugly code below
local function main()                    -- main is called at the end of script
  game:init()
  local render_ = function() game:render(render2) end -- draw Vertex Array
  if game.RENDER_OPT == 1 then
    render_ = function() game:render(render1) end -- draw GL_POINTS
  elseif game.RENDER_OPT == 3 then
    render_ = function() game:render(render3) end -- draw using VBO
  elseif game.RENDER_OPT == 4 then
    render_ = function() game:render(render4) end -- draw using PBO (have colors)
  end
    
  local event = ffi.new("SDL_Event")
  while game:run(event) do
    game:update(os.clock())
    render_()
  end
  game:destroy()
end

---- YOU HAVE BEEN WARNED: 
---- SDL & GL setup function, GL-heavy rendering functions (pretty ugly)

function game:setupSDL()
  self.INIT_OPTION  = 0x0000FFFF -- SDL_INIT_EVERYTHING
  self.VIDEO_OPTION = bit.bor(bit.bor(0x01, SDL.SDL_GL_DOUBLEBUFFER), 0x02)
                      -- SDL_HWSURFACE | SDL_GL_DOUBLEBUFFER | SDL_OPENGL
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
end

function game:setupGL()
  GL.glClearColor(0, 0, 0, 0);
  GL.glViewport(0, 0, self.WIDTH, self.HEIGHT);
  GL.glMatrixMode(GL.GL_PROJECTION);
  GL.glLoadIdentity();
  GL.glOrtho(0, self.WIDTH, self.HEIGHT, 0, 1, -1);
  GL.glMatrixMode(GL.GL_MODELVIEW);
  GL.glEnable(GL.GL_TEXTURE_2D);
  GL.glLoadIdentity();
end

function game:createVBO()
  GLext.glGenBuffersARB(1, self.vboID1)
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, self.vboID1[0])
  GLext.glBufferDataARB(GL.GL_ARRAY_BUFFER, ffi.sizeof(self.vertices), self.vertices, GL.GL_STATIC_DRAW)
  local buffersize = ffi.new("int[1]", 0)
  GLext.glGetBufferParameterivARB(GL.GL_ARRAY_BUFFER, GL.GL_BUFFER_SIZE, buffersize)
  assert( buffersize[0] == ffi.sizeof(self.vertices) )
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, 0)
end

function game:createTexture()
  GL.glShadeModel(GL.GL_FLAT);
  GL.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1);      -- 1-byte pixel alignment
  GL.glPixelStorei(GL.GL_PACK_ALIGNMENT, 1);        -- 1-byte pixel alignment
  GL.glEnable(GL.GL_TEXTURE_2D);
  GL.glDisable(GL.GL_LIGHTING);
  GL.glColorMaterial(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT_AND_DIFFUSE);
  GL.glEnable(GL.GL_COLOR_MATERIAL);
  
  GL.glGenTextures(1, self.texID1);
  GL.glBindTexture(GL.GL_TEXTURE_2D, self.texID1[0]);
  GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST);
  GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST);
  GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP);
  GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP);
  GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_RGBA8, self.model_w, self.model_h, 0, GL.GL_BGRA, GL.GL_UNSIGNED_BYTE, self.bitmap);
  GL.glBindTexture(GL.GL_TEXTURE_2D, 0)
end

function game:createPBO()
  GLext.glGenBuffersARB(1, self.pboID1)
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, self.pboID1[0]);
  GLext.glBufferDataARB(GL.GL_PIXEL_UNPACK_BUFFER, ffi.sizeof(self.bitmap), ffi.cast("void*", ffi.new("int", 0)), GL.GL_STREAM_DRAW);
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, 0); 
end

render1 = function (self, csizep)
  local new_index = self.iter%2
  GL.glBegin(GL.GL_POINTS);
  for y = 0, self.model_h-1 do
    for x = 0, self.model_w-1 do
      if self.grids[ new_index ][y+1][x+1] > 0 then
        GL.glColor3f(1, 1, 1); GL.glVertex3f(x*csizep, y*csizep, 0);
      end
    end
  end
  GL.glEnd();
end

render2 = function (self, csizep)
  local length = 0
  local new_index = self.iter%2
  for y = 0, self.model_h-1 do
    for x = 0, self.model_w-1 do
      --if self.old[y+1][x+1] > 0 then
      if self.grids[ new_index ][y+1][x+1] > 0 then
        self.vertices[length].x = x*csizep -- don't cause massive GC here, no temporaries!!!
        self.vertices[length].y = y*csizep 
        self.vertices[length].z = 0
        length = length + 1
      end
    end
  end
  
  -- enable vertex arrays
  GL.glEnableClientState(GL.GL_VERTEX_ARRAY)
  GL.glVertexPointer(3, GL.GL_FLOAT, 0, self.vertices)
  GL.glDrawArrays(GL.GL_POINTS, 0, length) -- don't have to draw vertices that are not assigned ( > length )
  GL.glDisableClientState(GL.GL_VERTEX_ARRAY)
end

render3 = function (self, csizep)
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, self.vboID1[0])  -- bind the VBO
  local length = 0
  local dst = ffi.cast("SVertex*", GLext.glMapBufferARB(GL.GL_ARRAY_BUFFER, GL.GL_WRITE_ONLY))
  if tonumber(ffi.cast("int", dst)) ~= 0 then 
    local new_index = self.iter % 2
    for y = 0, self.model_h-1 do
      for x = 0, self.model_w-1 do
        if self.grids[ new_index ][y+1][x+1] > 0 then
          dst[length].x = x*csizep
          dst[length].y = y*csizep -- don't cause massive GC here, no temporaries!!!
          dst[length].z = 0
          length = length + 1
        end
      end
    end
    GLext.glUnmapBufferARB(GL.GL_ARRAY_BUFFER)
  end  
  GL.glEnableClientState(GL.GL_VERTEX_ARRAY)
  GL.glVertexPointer(3, GL.GL_FLOAT, 0, ffi.cast("void*", ffi.new("int",0)))
  GL.glDrawArrays(GL.GL_POINTS, 0, length)
  GL.glDisableClientState(GL.GL_VERTEX_ARRAY)  -- don't have to draw vertices that are not assigned ( > length )
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, 0) -- release the VBO
end

render4 = function (self, csizep)
  -- copy texture image
  GL.glBindTexture(GL.GL_TEXTURE_2D, self.texID1[0])
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, self.pboID1[0])
  GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, self.model_w, self.model_h, GL.GL_BGRA, GL.GL_UNSIGNED_BYTE, ffi.cast("void*", ffi.new("int", 0)) )
  -- update texture image
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, self.pboID1[0])
  -- we don't need to use GLext.glBufferDataARB to flush data here. the colors from last iteration are still used.
  local dst = ffi.cast("unsigned int*", GLext.glMapBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, GL.GL_WRITE_ONLY) )
  
  if tonumber(ffi.cast("int", dst)) ~= 0 then 
    local new_index = self.iter % 2
    local old_index = bit.bxor(new_index, 1)
    for y = 0, self.model_h-1 do
      for x = 0, self.model_w-1 do
        if self.grids[ new_index ][y+1][x+1] > 0 then
          if self.grids[ old_index ][y+1][x+1] == 0 then
            dst[y*self.model_w + x] = 0xff + lsh(x/self.model_w*256, 16) + lsh(y/self.model_h*256, 8) + (self.iter)
          end
        else dst[y*self.model_w + x] = 0 end
      end
    end
    GLext.glUnmapBufferARB(GL.GL_PIXEL_UNPACK_BUFFER)
  end  
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, 0)
  
  -- draw a plane with texture
  GL.glBindTexture(GL.GL_TEXTURE_2D, self.texID1[0]);
  GL.glColor4f(1, 1, 1, 1);
  GL.glBegin(GL.GL_QUADS);
    GL.glNormal3f(0, 0, 1);
    GL.glTexCoord2f(0, 0);   GL.glVertex3f(0, 0, 0);
    GL.glTexCoord2f(1, 0);   GL.glVertex3f(self.WIDTH, 0, 0);
    GL.glTexCoord2f(1, 1);   GL.glVertex3f(self.WIDTH, self.HEIGHT, 0);
    GL.glTexCoord2f(0, 1);   GL.glVertex3f(0, self.HEIGHT, 0);
  GL.glEnd();
  GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
end

---- END OF SUPER UGLY PART
---- CALL MAIN

main() 



