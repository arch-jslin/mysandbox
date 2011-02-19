
#include <cstdlib>
#include "game.hpp"

int main ( int argc, char* argv[] )
{
    Game game(argc, argv);
    std::tr1::function<void()> render_ = std::tr1::bind(render2, std::tr1::ref(game)); // draw Vertex Array
    if (argc > 1 && atoi(argv[1]) == 1)
        render_ = std::tr1::bind(render1, std::tr1::ref(game)); // draw GL_POINTS
    else if (argc > 1 && atoi(argv[1]) == 3)
        render_ = std::tr1::bind(render3, std::tr1::ref(game)); // draw using VBO
    else if (argc > 1 && atoi(argv[1]) == 4)
        render_ = std::tr1::bind(render4, std::tr1::ref(game)); // draw using PBO

    while( game.run() ) {
        game.update(clock());
        game.render(render_);
    }
    return 0;
}
