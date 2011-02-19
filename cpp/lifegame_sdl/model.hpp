#ifndef _LIFEGAME_MODEL_
#define _LIFEGAME_MODEL_


template<typename T>
inline int neighbor_count(T old, size_t const& y, size_t const& x)
{
    int count = (old[y-1][x-1] + old[y-1][x] + old[y-1][x+1]) +
                (old[y][x-1]   +               old[y][x+1])   +
                (old[y+1][x-1] + old[y+1][x] + old[y+1][x+1]);
    return count;
}

//int rule1[9] = {0, 0, 1, 1, 0, 0, 0, 0, 0};
//int rule2[9] = {0, 0, 0, 1, 0, 0, 0, 0, 0};
inline int ruleset(int const& now, int const& n)
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
        old[ 0 ][x] = old[H-2][x];
    }
    for( size_t y = 2; y < H-2; ++y ) {
        old[y][W-1] = old[y][ 1 ];
        old[y][ 0 ] = old[y][W-2];
    }
    //and corner wrapping
    old[1][W-1] = old[H-1][ 1 ] = old[H-1][W-1] = old[ 1 ][ 1 ];
    old[1][ 0 ] = old[H-1][ 0 ] = old[H-1][W-2] = old[ 1 ][W-2];
    old[0][ 1 ] = old[ 0 ][W-1] = old[H-2][W-1] = old[H-2][ 1 ];
    old[0][ 0 ] = old[ 0] [W-2] = old[H-2][ 0 ] = old[H-2][W-2];
}

void wrap_padding(char** old, size_t const& W, size_t const& H)
{
    //side wrapping
    for ( size_t x = 2; x <= W-1; ++x ) {
        old[H+1][x] = old[1][x];
        old[ 0 ][x] = old[H][x];
    }
    for ( size_t y = 2; y <= H-1; ++y ) {
        old[y][W+1] = old[y][1];
        old[y][ 0 ] = old[y][W];
    }
    //and corner wrapping
    old[1][W+1] = old[H+1][1] = old[H+1][W+1] = old[1][1];
    old[1][0]   = old[H+1][0] = old[H+1][W]   = old[1][W];
    old[0][1]   = old[0][W+1] = old[H][W+1]   = old[H][1];
    old[0][0]   = old[0][W]   = old[H][0]     = old[H][W];
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

void grid_iteration(char** old_grid, char** new_grid, size_t const& W, size_t const& H)
{
    wrap_padding(old_grid, W, H);
    for( size_t y = 1; y <= H; ++y )
        for( size_t x = 1; x <= W; ++x )
            //new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x) );
            new_grid[y][x] = ruleset( old_grid[y][x], neighbor_count(old_grid, y, x) );
}

#endif //_LIFEGAME_MODEL_
