#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <ctime>

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

template<typename T, size_t W, size_t H>
int neighbor_count(T const (&old)[H][W], int y, int x)
{
    int count = (old[y-1][x-1] + old[y-1][x] + old[y-1][x+1]) +
                (old[y][x-1]   +               old[y][x+1])   +
                (old[y+1][x-1] + old[y+1][x] + old[y+1][x+1]);
    return count;
}

int rule1[9] = {0, 0, 1, 1, 0, 0, 0, 0, 0};
int rule2[9] = {0, 0, 0, 1, 0, 0, 0, 0, 0};
int ruleset(int now, int n)
{
    return now > 0 ? rule1[n] : rule2[n];
}

template<typename T, size_t W, size_t H>
void wrap_padding(T (&old)[H][W])
{
    //side wrapping
    for( size_t x = 2; x < W-2; ++x ) {
        old[H-1][x] = old[ 1 ][x];
        old[ 0 ][x] = old[H-1][x];
    }
    for( size_t y = 2; y < H-2; ++y ) {
        old[y][W-1] = old[y][ 1 ];
        old[y][ 0 ] = old[y][W-1];
    }
    //and corner wrapping
    old[1][W-1] = old[H-1][ 1 ] = old[H-1][W-1] = old[ 1 ][ 1 ];
    old[1][ 0 ] = old[H-1][ 0 ] = old[H-1][W-2] = old[ 1 ][W-2];
    old[0][ 1 ] = old[ 0 ][W-1] = old[H-2][W-1] = old[H-2][ 1 ];
    old[0][ 0 ] = old[ 0] [W-2] = old[H-2][ 0 ] = old[H-2][W-2];
}

template<typename T, size_t W, size_t H>
void grid_iteration(T (&old_grid)[H][W], T (&new_grid)[H][W])
{
    wrap_padding(old_grid);
    for( size_t y = 1; y < H-1; ++y )
        for( size_t x = 1; x < W-1; ++x )
            new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x) );

    for( size_t y = 0; y < H; ++y )
        for( size_t x = 0; x < W; ++x ) {
            old_grid[y][x] = new_grid[y][x]; // grid data copy
            new_grid[y][x] = 0;              // clean new grid data
        }
}

int nowg[22][22] = {{0}};
int newg[22][22] = {{0}};

void bench_test(int n = 0)
{
    for( int i = 0; i < 80; ++i )
        nowg[rand()%22][rand()%22] = 1;  // random seeding

    grid_print(nowg);
    time_t t = clock();
    for( int i = 0; i < n; ++i )
        grid_iteration(nowg, newg);
    printf("Time Elapsed: %lf\n", static_cast<double>(clock() - t) / CLOCKS_PER_SEC);
    grid_print(nowg);
}

int main()
{
    std::srand(time(0));
    bench_test(100000);
    system("pause");
    return 0;
}
