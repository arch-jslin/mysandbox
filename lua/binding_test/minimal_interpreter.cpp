
#include "binding_test.hpp"
#include <cstring>

int run_simple_interpreter(lua_State* L)
{
    char buf[256] = {0};
    int error = 0;

    while(fgets(buf, sizeof(buf), stdin) != NULL) {
        error = luaL_loadbuffer(L, buf, strlen(buf), "line") ||
                lua_pcall(L, 0, 0, 0);
        if( error ) {
            fprintf(stderr, "%s", lua_tostring(L, -1));
            lua_pop(L, 1);
        }
    }
    return 0;
}
