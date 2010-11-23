#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <ctime>

template<typename T, size_t W, size_t H>
void grid_print(T const (&grid)[H][W])
{
    if( !grid || !H || !W ) return;
    for( size_t y = 0; y < H; ++y ) {
        for( size_t x = 0; x < W; ++x )
            printf("%d ", grid[y][x]);
        printf("\n");
    }
}

int dir[8][2] = {{-1,-1}, {-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}, {1,1}};
template<typename T, size_t W, size_t H>
int neighbor_count(T const (&old_grid)[H][W], int y, int x)
{
    int count = 0;
    for( int i = 0; i < 8; ++i ) {
        int ny = y + dir[i][0];
        int nx = x + dir[i][1];
        if( ny < 0 ) ny = H-1;
        else if( static_cast<size_t>(ny) >= H ) ny = 0;
        if( nx < 0 ) nx = W-1;
        else if( static_cast<size_t>(nx) >= W ) nx = 0;
        if( old_grid[ny][nx] > 0 )
            count = count + 1;
    }
    return count;
}

int rule1[9] = {0, 0, 1, 1, 0, 0, 0, 0, 0};
int rule2[9] = {0, 0, 0, 1, 0, 0, 0, 0, 0};
int ruleset(int now, int n)
{
    return now > 0 ? rule1[n] : rule2[n];
}

template<typename T, size_t W, size_t H>
void grid_iteration(T (&old_grid)[H][W], T (&new_grid)[H][W])
{
    for( size_t y = 0; y < H; ++y )
        for( size_t x = 0; x < W; ++x )
            new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x) );

    for( size_t y = 0; y < H; ++y )
        for( size_t x = 0; x < W; ++x ) {
            old_grid[y][x] = new_grid[y][x]; // grid data copy
            new_grid[y][x] = 0;              // clean new grid data
        }
}

int nowg[15][15] = {{0}};
int newg[15][15] = {{0}};

void bench_test(int n = 0)
{
    for( int i = 0; i < 45; ++i )
        nowg[rand()%15][rand()%15] = 1;  // random seeding

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
    bench_test(20000);
    system("pause");
    return 0;
}
