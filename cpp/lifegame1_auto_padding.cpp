#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <ctime>
#include "lifegame_sdl/model.hpp"

template<typename T, size_t W, size_t H>
void grid_print(T const (&grid)[H][W])
{
    if( !grid || !H || !W ) return;
    for( size_t y = 1; y < H-1; ++y ) {
        for( size_t x = 1; x < W-1; ++x )
            printf("%d ", grid[y][x]);
        printf("\n");
    }
}

int grids[2][22][22] = {{{0}}};

void bench_test(int n = 0)
{
    for( int i = 0; i < 80; ++i )
        grids[0][rand()%22][rand()%22] = 1;  // random seeding

    grid_print(grids[0]);
    time_t t = clock();
    for( int i = 0; i < n; ++i ) {
        int index = i%2;
        grid_iteration(grids[index], grids[index^1]);
    }

    //Note: Using two grids interchangably will eliminate the need of flush and copy
    //      But it actually is a little slower when using GCC -O3! Since two references
    //      to the arrays are not constant any more. It possibly cannot optimize away this.
    //      However, I think it's fair when comparing with LuaJIT on this point.
    //      Just as I imagined, GCC -O2 now produce code that equals to -O3.
    //      Was(100000 iterations): O2 => ~0.8 secs or so; O3 => ~0.22 secs
    //      Now(same iterations)  : O2 => ~0.35 secs or so; O3 => ~0.35 secs

    printf("Time Elapsed: %lf\n", static_cast<double>(clock() - t) / CLOCKS_PER_SEC);
    grid_print(grids[1]);
}

int main(int argc, char* argv[])
{
    std::srand(time(0));
    bench_test(100000);
    system("pause");
    return 0;
}
