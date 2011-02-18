#ifndef _LIFEGAME_MODEL_
#define _LIFEGAME_MODEL_


template<typename T, size_t W, size_t H>
int neighbor_count(T const (&old)[H][W], int const& y, int const& x)
{
    int count = (old[y-1][x-1] + old[y-1][x] + old[y-1][x+1]) +
                (old[y][x-1]   +               old[y][x+1])   +
                (old[y+1][x-1] + old[y+1][x] + old[y+1][x+1]);
    return count;
}

//int rule1[9] = {0, 0, 1, 1, 0, 0, 0, 0, 0};
//int rule2[9] = {0, 0, 0, 1, 0, 0, 0, 0, 0};
int ruleset(int const& now, int const& n)
{
    //return now > 0 ? rule1[n] : rule2[n];
    return (((now << 2) + 8) >> n) & 1;
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
            //new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x) );
            new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x) );
}

#endif //_LIFEGAME_MODEL_
