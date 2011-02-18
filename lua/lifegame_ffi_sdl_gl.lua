package.path = [[c:\local_gitrepo\luajit-opencl]]..package.path
----------------
local ffi = require "ffi"
local SDL = ffi.load([[c:\libs\cpp\SDL\SDL]])
local GL = require "gl"
ffi.cdef( io.open([[c:\libs\cpp\SDL\ffi_SDL.h]], 'r'):read('*a'))
ffi.cdef[[
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
PROC __attribute__((__stdcall__)) wglGetProcAddress(LPCSTR);
]]
local GLext = {}
local function setupVBOAPI()
  local t = {}
  t.glGenBuffersARB = ffi.cast("PFNGLGENBUFFERSARBPROC", GL.wglGetProcAddress("glGenBuffersARB")) -- VBO Name Generation Procedure
  t.glBindBufferARB = ffi.cast("PFNGLBINDBUFFERARBPROC", GL.wglGetProcAddress("glBindBufferARB")) -- VBO Bind Procedure
  t.glBufferDataARB = ffi.cast("PFNGLBUFFERDATAARBPROC", GL.wglGetProcAddress("glBufferDataARB")) -- VBO Data Loading Procedure
  t.glBufferSubDataARB = ffi.cast("PFNGLBUFFERSUBDATAARBPROC", GL.wglGetProcAddress("glBufferSubDataARB")) -- VBO Sub Data Loading Procedure
  t.glDeleteBuffersARB = ffi.cast("PFNGLDELETEBUFFERSARBPROC", GL.wglGetProcAddress("glDeleteBuffersARB")) -- VBO Deletion Procedure
  t.glGetBufferParameterivARB = ffi.cast("PFNGLGETBUFFERPARAMETERIVARBPROC", GL.wglGetProcAddress("glGetBufferParameterivARB")) -- return various parameters of VBO
  t.glMapBufferARB = ffi.cast("PFNGLMAPBUFFERARBPROC", GL.wglGetProcAddress("glMapBufferARB")) -- map VBO procedure
  t.glUnmapBufferARB = ffi.cast("PFNGLUNMAPBUFFERARBPROC", GL.wglGetProcAddress("glUnmapBufferARB")) -- unmap the VBO procedure
  return t
end
----------------
local randomseed, rand, floor, abs = math.randomseed, math.random, math.floor, math.abs
local band, rsh, lsh = bit.band, bit.rshift, bit.lshift
local random = function(n) 
  n = n or 1; 
  return floor(rand()*abs(n)) 
end

local function new_grid(w, h) 
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

local function neighbor_count(old, y, x, h, w)
  local count = ( old[y-1][x-1] + old[y-1][x] + old[y-1][x+1] ) +
                ( old[ y ][x-1] +               old[ y ][x+1] ) +
                ( old[y+1][x-1] + old[y+1][x] + old[y+1][x+1] )
  return count
end

local rule1 = ffi.new("char[9]", {0, 0, 1, 1, 0, 0, 0, 0, 0});
local rule2 = ffi.new("char[9]", {0, 0, 0, 1, 0, 0, 0, 0, 0}); 
local function ruleset(now, count)
  --return now > 0 and rule1[count] or rule2[count]
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

local function grid_iteration(old, new, w, h, iter)
  w, h = w or 15, h or 15
  wrap_padding(old, w, h)
  for y = 1, h do
    for x = 1, w do
      local res = ruleset( old[y][x], neighbor_count(old, y, x) )
      new[y][x] = res --it's either zero or iter
      --io.write(string.format("%d ",res))
    end
    --io.write("\n")
  end
  --ffi.copy(old, new, (w+2)*(h+2))
  --ffi.fill(new, (w+2)*(h+2)) 
end

----------------

local game = {}

game.WIDTH        = tonumber(arg[2]) or 1200
game.HEIGHT       = tonumber(arg[3]) or 900
game.INIT_OPTION  = 0x0000FFFF -- SDL_INIT_EVERYTHING
game.VIDEO_OPTION = -- 0x01 + 0x40000000
                    bit.bor(bit.bor(0x01, SDL.SDL_GL_DOUBLEBUFFER), 0x02)
                    -- SDL_HWSURFACE | SDL_GL_DOUBLEBUFFER | SDL_OPENGL
game.t            = os.clock()
game.csize        = tonumber(arg[1]) or 2
game.model_w      = game.WIDTH / game.csize
game.model_h      = game.HEIGHT/ game.csize
game.iter         = 0

ffi.cdef[[
typedef struct {GLfloat x,y,z;} SVertex;
typedef struct {GLfloat r,g,b;} SColor; 
]]

game.vboID1       = ffi.new("unsigned int[1]", 0)
game.pboID1       = ffi.new("unsigned int[1]", 0)
game.texID1       = ffi.new("unsigned int[1]", 0)
game.vertices = ffi.new("SVertex[?]", game.model_w * game.model_h, {{0,0,0}} );
game.bitmap   = ffi.new("unsigned char[?]", game.WIDTH * game.HEIGHT * 4, {0} );

function game:init()

  randomseed(os.time())

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
  
  self.old = new_grid(self.model_w, self.model_h)
  self.new = new_grid(self.model_w, self.model_h)
  self.grids = {}
  self.grids[0], self.grids[1] = self.old, self.new
  
  for i = 1, self.model_w*self.model_h / 9 do 
    --self.old[random(self.model_h)+1][random(self.model_w)+1] = 1 
    self.grids[0][random(self.model_h)+1][random(self.model_w)+1] = 1 
  end
  
  --setup OpenGL VBO API, need a query from wglGetProcAddress
  GLext = setupVBOAPI()
  
  --create VBO
  GLext.glGenBuffersARB(1, self.vboID1)
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, self.vboID1[0])
  GLext.glBufferDataARB(GL.GL_ARRAY_BUFFER, ffi.sizeof(self.vertices), self.vertices, GL.GL_STATIC_DRAW)
  local buffersize = ffi.new("int[1]", 0)
  GLext.glGetBufferParameterivARB(GL.GL_ARRAY_BUFFER, GL.GL_BUFFER_SIZE, buffersize)
  assert( buffersize[0] == ffi.sizeof(self.vertices) )
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, 0)
  
  --create Texture and PBO
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
  GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_RGBA8, self.WIDTH, self.HEIGHT, 0, GL.GL_BGRA, GL.GL_UNSIGNED_BYTE, self.bitmap);
  GL.glBindTexture(GL.GL_TEXTURE_2D, 0) 
  GLext.glGenBuffersARB(1, self.pboID1)
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, self.pboID1[0]);
  GLext.glBufferDataARB(GL.GL_PIXEL_UNPACK_BUFFER, ffi.sizeof(self.bitmap), ffi.cast("void*", ffi.new("int", 0)), GL.GL_STREAM_DRAW);
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, 0);
  print("...")
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
  print(t - self.t)
  --if t - self.t > 0.100 then
    --grid_iteration(self.old, self.new, self.model_w, self.model_h, self.iter)
    self.iter = self.iter + 1
    self.iter = self.iter % 256
    local new_index = self.iter % 2
    local old_index = bit.bxor(new_index, 1)
    grid_iteration(self.grids[old_index], self.grids[new_index], self.model_w, self.model_h, self.iter)
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

local function render1(self, csizep)
  GL.glBegin(GL.GL_POINTS);
  for y = 0, self.model_h-1 do
    for x = 0, self.model_w-1 do
      if self.old[y+1][x+1] > 0 then
        GL.glColor3f(1, 1, 1); GL.glVertex3f(x*csizep, y*csizep, 0);
      end
    end
  end
  GL.glEnd();
end

local function render2(self, csizep)
  local length = 0
  local new_index = self.iter%2
  local old_index = bit.bxor(new_index, 1)
  for y = 0, self.model_h-1 do
    for x = 0, self.model_w-1 do
      --if self.old[y+1][x+1] > 0 then
      if self.grids[ old_index ][y+1][x+1] > 0 then
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

local function render3(self, csizep)
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, self.vboID1[0])  -- bind the VBO
  local length = 0
  local dst = ffi.cast("SVertex*", GLext.glMapBufferARB(GL.GL_ARRAY_BUFFER, GL.GL_WRITE_ONLY))
  if tonumber(ffi.cast("int", dst)) ~= 0 then 
    local new_index = self.iter%2
    local old_index = bit.bxor(new_index, 1)
    for y = 0, self.model_h-1 do
      for x = 0, self.model_w-1 do
        --if self.old[y+1][x+1] > 0 then
        if self.grids[ old_index ][y+1][x+1] > 0 then
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
  GL.glDisableClientState(GL.GL_VERTEX_ARRAY)
  GLext.glBindBufferARB(GL.GL_ARRAY_BUFFER, 0)      -- release the VBO
end

local function render4(self, csizep)
  -- copy texture image
  GL.glBindTexture(GL.GL_TEXTURE_2D, self.texID1[0])
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, self.pboID1[0])
  GL.glTexSubImage2D(GL.GL_TEXTURE_2D, 0, 0, 0, self.WIDTH, self.HEIGHT, GL.GL_BGRA, GL.GL_UNSIGNED_BYTE, ffi.cast("void*", ffi.new("int", 0)) )
  -- update texture image
  GLext.glBindBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, self.pboID1[0])
  GLext.glBufferDataARB(GL.GL_PIXEL_UNPACK_BUFFER, ffi.sizeof(self.bitmap), ffi.cast("void*", ffi.new("int", 0)), GL.GL_STREAM_DRAW)
  local dst = ffi.cast("unsigned int*", GLext.glMapBufferARB(GL.GL_PIXEL_UNPACK_BUFFER, GL.GL_WRITE_ONLY) )
  
  if tonumber(ffi.cast("int", dst)) ~= 0 then 
    local new_index = self.iter%2
    local old_index = bit.bxor(new_index, 1)
    ffi.fill(dst, ffi.sizeof(self.bitmap)) -- make it all black
    for y = 0, self.model_h-1 do
      for x = 0, self.model_w-1 do
        --if self.old[y+1][x+1] > 0 then
        if self.grids[ old_index ][y+1][x+1] > 0 then
          --GL.glDrawPixels(self.WIDTH, self.HEIGHT, GL.GL_BGRA, GL.GL_UNSIGNED_BYTE, dst)
          dst[(y*csizep)*self.WIDTH + x*csizep] = 0xffffffff --(white dot)
        end
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

function game:destroy()
  SDL.SDL_FreeSurface(self.screen)
  SDL.SDL_Quit()
  GLext.glDeleteBuffersARB(1, vboID1)
end

local function main()
  game:init()
  local event = ffi.new("SDL_Event")
  while game:run(event) do
    game:update(os.clock())
    --game:render(render1) -- draw GL_POINTS
    --game:render(render2) -- draw using Vertex Array
    game:render(render3)   -- draw using VBO
    --game:render(render4) -- draw using PBO
  end
  game:destroy()
end

main()