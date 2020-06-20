#include <cstdio>
#include <cstdlib>
#include <SDL.h>
#include <SDL_opengl.h>
#include <gl/gl.h>
#include "game.hpp"
#include "model.hpp"

//Why this isn't in the header?
typedef void (__attribute__((__stdcall__)) * PFNWGLSWAPINTERVALEXTPROC) (int option);

#ifdef _WIN32
PFNGLGENBUFFERSARBPROC pglGenBuffersARB = 0;                     // VBO Name Generation Procedure
PFNGLBINDBUFFERARBPROC pglBindBufferARB = 0;                     // VBO Bind Procedure
PFNGLBUFFERDATAARBPROC pglBufferDataARB = 0;                     // VBO Data Loading Procedure
PFNGLBUFFERSUBDATAARBPROC pglBufferSubDataARB = 0;               // VBO Sub Data Loading Procedure
PFNGLDELETEBUFFERSARBPROC pglDeleteBuffersARB = 0;               // VBO Deletion Procedure
PFNGLGETBUFFERPARAMETERIVARBPROC pglGetBufferParameterivARB = 0; // return various parameters of VBO
PFNGLMAPBUFFERARBPROC pglMapBufferARB = 0;                       // map VBO procedure
PFNGLUNMAPBUFFERARBPROC pglUnmapBufferARB = 0;                   // unmap VBO procedure
PFNWGLSWAPINTERVALEXTPROC wglSwapIntervalEXT = 0;                // vsync control for OpenGL
#define glGenBuffersARB           pglGenBuffersARB
#define glBindBufferARB           pglBindBufferARB
#define glBufferDataARB           pglBufferDataARB
#define glBufferSubDataARB        pglBufferSubDataARB
#define glDeleteBuffersARB        pglDeleteBuffersARB
#define glGetBufferParameterivARB pglGetBufferParameterivARB
#define glMapBufferARB            pglMapBufferARB
#define glUnmapBufferARB          pglUnmapBufferARB
#endif //_WIN32

void setupARBAPI()
{
    // get pointers to GL functions
    glGenBuffersARB = (PFNGLGENBUFFERSARBPROC)wglGetProcAddress("glGenBuffersARB");
    glBindBufferARB = (PFNGLBINDBUFFERARBPROC)wglGetProcAddress("glBindBufferARB");
    glBufferDataARB = (PFNGLBUFFERDATAARBPROC)wglGetProcAddress("glBufferDataARB");
    glBufferSubDataARB = (PFNGLBUFFERSUBDATAARBPROC)wglGetProcAddress("glBufferSubDataARB");
    glDeleteBuffersARB = (PFNGLDELETEBUFFERSARBPROC)wglGetProcAddress("glDeleteBuffersARB");
    glGetBufferParameterivARB = (PFNGLGETBUFFERPARAMETERIVARBPROC)wglGetProcAddress("glGetBufferParameterivARB");
    glMapBufferARB = (PFNGLMAPBUFFERARBPROC)wglGetProcAddress("glMapBufferARB");
    glUnmapBufferARB = (PFNGLUNMAPBUFFERARBPROC)wglGetProcAddress("glUnmapBufferARB");
    wglSwapIntervalEXT = (PFNWGLSWAPINTERVALEXTPROC)wglGetProcAddress("wglSwapIntervalEXT"); // for opengl vsync
    wglSwapIntervalEXT(0); //turn it off.
}

Game::Game(int const& argc, char* argv[])
  :RENDER_OPT( argc > 1 ? atoi(argv[1]) : 2 ),
   csize(2), model_w(120), model_h(90), WIDTH(csize * model_w), HEIGHT(csize * model_h),
   t(clock()), iter(1), vboID1(0), pboID1(0), texID1(0), count(0), vertices(0), bitmap(0), screen(0), glcontext(0)
{
    srand(time(0)); // randomize at game initialization
    if ( argc > 2 ) csize = static_cast<size_t>(atoi(argv[2]));
    if ( argc > 3 ) model_w = static_cast<size_t>(atoi(argv[3]));
    if ( argc > 4 ) model_h = static_cast<size_t>(atoi(argv[4]));

    WIDTH = model_w * csize;
    HEIGHT= model_h * csize;

    if( RENDER_OPT > 4 || RENDER_OPT < 1 ) {
        printf("This rendering method is not supported. Please choose from 1~4.\n");
        exit(0);
    }
    if( WIDTH > 4096 || HEIGHT > 4096 || WIDTH < 1 || HEIGHT < 1 ) {
        printf("Dimensions too big, which will probably fail to initalize.\n");
        printf("Try lower the csize(cell_size) or the width/height settings.\n");
        exit(0);
    }

    if( RENDER_OPT == 2 || RENDER_OPT == 3 )
        vertices = new SVertex[ model_w * model_h ];
    if( RENDER_OPT == 4 )
        bitmap = new unsigned char[ model_w * model_h * 4 ];

    setupSDL();
    setupGL();

    grids[0] = new char*[model_h+2]; //plus 2 for padding
    grids[1] = new char*[model_h+2];
    for( size_t y = 0; y < model_h+2; ++y ) {
        grids[0][y] = new char[model_w+2];
        grids[1][y] = new char[model_w+2];
    }

    for( size_t i = 0; i < model_w * model_h / 9; ++i )
        grids[0][rand()%model_h + 1][rand()%model_w + 1] = 1;

    //setup OpenGL VBO API, need a query from wglGetProcAddress
    setupARBAPI();
    if( RENDER_OPT == 3 )
        createVBO();     //create VBO ONLY AFTER you correctly setup ARB API
    if( RENDER_OPT == 4 ) {
        createTexture();  //create Texture for render4 usage (search for render4)
        createPBO();      //create PBO
    }
}

Game::~Game()
{
    SDL_GL_DeleteContext(glcontext);
    SDL_Quit();
    for( size_t y = 0; y < model_h + 2; ++y ) {
        delete [] grids[0][y];
        delete [] grids[1][y];
    }
    delete [] grids[0];
    delete [] grids[1];
    if( RENDER_OPT == 2 || RENDER_OPT == 3 ) {
        glDeleteBuffersARB(1, &vboID1);
        delete [] vertices;
    }
    if( RENDER_OPT == 4) {
        glDeleteTextures(1, &texID1);
        glDeleteBuffersARB(1, &pboID1);
        delete [] bitmap;
    }
}

bool Game::run()
{
    SDL_Event e;
    if ( SDL_PollEvent(&e) == 1 ) {
        int etype = e.type;
        if (etype == SDL_QUIT) {
            return false;
        }
        else if (etype == SDL_KEYDOWN) {
            SDL_Keycode sym = e.key.keysym.sym;
            if (sym == SDLK_q || sym == SDLK_ESCAPE) {
                return false;
            }
        }
    }
    return true;
}

void Game::update(time_t const& time)
{
    //printf("Millisecs between updates: %ld\n", (time - t));
    ++count;
    if (time - t > 1000) {
        t = time;
        printf("Frames completed per second: %d\n", count);
        count = 0;
    }
    iter = (iter+1) % 256;
    int index = iter % 2;
    grid_iteration(grids[index], grids[index^1], model_w, model_h);
}

void Game::render(std::tr1::function<void()> render_)
{
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glLoadIdentity();
    glPointSize(csize-1);
    render_();
    SDL_GL_SwapWindow(screen);
}

//-----------------------------------------------------

void Game::setupSDL()
{
    SDL_Init(SDL_INIT_EVERYTHING);

    screen = SDL_CreateWindow("SDL2 + OpenGL Game of Life",
                              SDL_WINDOWPOS_UNDEFINED,
                              SDL_WINDOWPOS_UNDEFINED,
                              WIDTH, HEIGHT,
                              SDL_WINDOW_RESIZABLE | SDL_WINDOW_OPENGL);
    glcontext = SDL_GL_CreateContext(screen);

    SDL_GL_SetAttribute(SDL_GL_RED_SIZE,        8);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE,      8);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,       8);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE,      8);

    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE,      16);
    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE,     32);

    SDL_GL_SetAttribute(SDL_GL_ACCUM_RED_SIZE,  8);
    SDL_GL_SetAttribute(SDL_GL_ACCUM_GREEN_SIZE,8);
    SDL_GL_SetAttribute(SDL_GL_ACCUM_BLUE_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_ACCUM_ALPHA_SIZE,8);

    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS,  1);
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES,  2);
}

void Game::setupGL()
{
    glClearColor(0, 0, 0, 0);
    glViewport(0, 0, WIDTH, HEIGHT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, WIDTH, HEIGHT, 0, 1, -1);
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_TEXTURE_2D);
    glLoadIdentity();
}

void Game::createVBO()
{
    glGenBuffersARB(1, &vboID1);
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, vboID1);
    glBufferDataARB(GL_ARRAY_BUFFER_ARB, sizeof(SVertex)*model_w*model_h, vertices, GL_STATIC_DRAW_ARB);
    int buffersize = 0;
    glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_SIZE_ARB, &buffersize);
    if ( static_cast<size_t>(buffersize) != sizeof(SVertex)*model_w*model_h ) {
        glDeleteBuffersARB(1, &vboID1);
        vboID1 = 0;
        printf("[createVBO()] Data size is mismatch with input array.\n");
    }
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
}

void Game::createTexture()
{
    glShadeModel(GL_FLAT);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1); // 1-byte pixel alignment
    glPixelStorei(GL_PACK_ALIGNMENT, 1);   // 1-byte pixel alignment
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_LIGHTING);
    glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);

    glGenTextures(1, &texID1);
    glBindTexture(GL_TEXTURE_2D, texID1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, model_w, model_h, 0, GL_RGBA, GL_UNSIGNED_BYTE, bitmap);
    glBindTexture(GL_TEXTURE_2D, 0);
}

void Game::createPBO()
{
    glGenBuffersARB(1, &pboID1);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, pboID1);
    glBufferDataARB(GL_PIXEL_UNPACK_BUFFER_ARB, model_w * model_h * 4, 0, GL_STREAM_DRAW_ARB);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, 0);
}

void Game::render1()  //using GL_POINTS
{
    int new_index = (iter % 2)^1;
    glBegin(GL_POINTS);

    for ( size_t y = 0; y < model_h; ++y )
        for ( size_t x = 0; x < model_w; ++x )
            if ( grids[ new_index ][y+1][x+1] > 0 ) {
                glColor3f(1, 1, 1);
                glVertex3f(x*csize, y*csize, 0);
            }

    glEnd();
}

void Game::render2()  //using GL's VERTEX ARRAY
{
    size_t length = 0;
    int new_index = (iter % 2)^1;
    for ( size_t y = 0; y < model_h; ++y )
        for ( size_t x = 0; x < model_w; ++x )
            if ( grids[ new_index ][y+1][x+1] > 0 ) {
                vertices[length].x = x*csize;
                vertices[length].y = y*csize;
                vertices[length].z = 0;
                ++length;
            }

  // enable vertex arrays
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_POINTS, 0, length); // don't have to draw vertices that are not assigned ( > length )
    glDisableClientState(GL_VERTEX_ARRAY);
}

void Game::render3()  //using VBO
{
    glBindBufferARB(GL_ARRAY_BUFFER, vboID1); // bind the VBO
    size_t length = 0;
    Game::SVertex* dst = static_cast<Game::SVertex*>(glMapBufferARB(GL_ARRAY_BUFFER, GL_WRITE_ONLY));
    if ( dst ) {
        int index = (iter % 2)^1;
        for ( size_t y = 0; y < model_h; ++y )
            for ( size_t x = 0; x < model_w; ++x )
                if ( grids[ index ][y+1][x+1] > 0 ) {
                    dst->x = x*csize;
                    dst->y = y*csize;
                    dst->z = 0;
                    ++dst, ++length;
                }
        glUnmapBufferARB(GL_ARRAY_BUFFER);
    }
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, 0);
    glDrawArrays(GL_POINTS, 0, length);
    glDisableClientState(GL_VERTEX_ARRAY); // don't have to draw vertices that are not assigned ( > length )
    glBindBufferARB(GL_ARRAY_BUFFER, 0);   // release the VBO
}

void Game::render4()
{
    // copy texture image
    glBindTexture(GL_TEXTURE_2D, texID1);
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, pboID1);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, model_w, model_h, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)0);
    // update texture image
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, pboID1);
    // we don't need to use glBufferDataARB to flush data here. the colors from last iteration are still used.
    unsigned int* dst = static_cast<unsigned int*>(glMapBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, GL_WRITE_ONLY));

    if( dst ) {
        int index = iter % 2;
        for ( size_t y = 0; y < model_h; ++y ) {
            for ( size_t x = 0; x < model_w; ++x ) {
                if( grids[ index^1 ][y+1][x+1] > 0 ) {
                    if( grids[ index ][y+1][x+1] == 0 )
                        *dst = 0xff000000 + ((x*256/model_w) << 16) + ((y*256/model_h) << 8) + (iter/2+128);
                }
                else *dst = 0;
                ++dst;
            }
        }
        glUnmapBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB);
    }
    glBindBufferARB(GL_PIXEL_UNPACK_BUFFER_ARB, 0);
    // draw a plane with texture
    glBindTexture(GL_TEXTURE_2D, texID1);
    glColor4f(1, 1, 1, 1);
    glBegin(GL_QUADS);
        glNormal3f(0, 0, 1);
        glTexCoord2f(0, 0);   glVertex3f(0, 0, 0);
        glTexCoord2f(1, 0);   glVertex3f(WIDTH, 0, 0);
        glTexCoord2f(1, 1);   glVertex3f(WIDTH, HEIGHT, 0);
        glTexCoord2f(0, 1);   glVertex3f(0, HEIGHT, 0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
}
