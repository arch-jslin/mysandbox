#ifndef _LIFEGAME_GAME_
#define _LIFEGAME_GAME_

#include <tr1/functional>
#include <ctime>

struct SDL_Surface;

struct Game {
    Game(int const& argc, char* argv[]);
    ~Game();
    bool run();
    void update(time_t const& time);
    void render(std::tr1::function<void()> render_);

    void setupSDL();
    void setupGL();
    void createVBO();
    void createTexture();
    void createPBO();

    const int RENDER_OPT;
    size_t csize, model_w, model_h;
    size_t WIDTH, HEIGHT;
    time_t t;
    int iter;
    unsigned int vboID1, pboID1, texID1;
    int count;

    struct SVertex{ float x, y, z; };
    char** grids[2];        //these will be allocated, have to free them in d'tor
    SVertex* vertices;      //these will be allocated, have to free them in d'tor
    unsigned char* bitmap;  //these will be allocated, have to free them in d'tor

    SDL_Surface* screen;

    void render1();  //using GL_POINTS
    void render2();  //using GL's VERTEX ARRAY
    void render3();  //using VBO
    void render4();  //using PBO
};

#endif //_LIFEGAME_GAME_
