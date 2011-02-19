
#include <cstdlib>
#include "game.hpp"

int main ( int argc, char* argv[] )
{
    Game game(argc, argv);
    std::tr1::function<void()> render_ = std::tr1::bind(&Game::render2, &game); // draw Vertex Array
    if (argc > 1 && atoi(argv[1]) == 1)
        render_ = std::tr1::bind(&Game::render1, &game); // draw GL_POINTS
    else if (argc > 1 && atoi(argv[1]) == 3)
        render_ = std::tr1::bind(&Game::render3, &game); // draw using VBO
    else if (argc > 1 && atoi(argv[1]) == 4)
        render_ = std::tr1::bind(&Game::render4, &game); // draw using PBO

    while( game.run() ) {
        game.update(clock());
        game.render(render_);
    }
    return 0;
}
