#include <cstdio>
#include <cstring>
#include <lua.hpp>

int run_simple_interpreter()
{
    char buf[256] = {0};
    int error = 0;
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    while(fgets(buf, sizeof(buf), stdin) != NULL) {
        error = luaL_loadbuffer(L, buf, strlen(buf), "line") ||
                lua_pcall(L, 0, 0, 0);
        if( error ) {
            fprintf(stderr, "%s", lua_tostring(L, -1));
            lua_pop(L, 1);
        }
    }

    lua_close(L);
    return 0;
}
