
#include "binding_test.hpp"

int main()
{
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    //binding1(L);
    //run_simple_interpreter(L);
    //stack(L);
    binding2(L);
    //storing_state_test(L);

    lua_close(L);
    system("pause");
    return 0;
}

void error(lua_State* L, char const* fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    printf("\n");
    //lua_close(L);
    //exit(EXIT_FAILURE);
}

void stack_dump(lua_State* L)
{
    int top = lua_gettop(L);
    for(int i = 1; i <= top; ++i) {
        int t = lua_type(L, i);
        printf("%-5d%s\t", i, lua_typename(L, t));
        switch(t) {
            case LUA_TSTRING:
                printf("'%s'", lua_tostring(L, i));
                break;
            case LUA_TNUMBER:
                printf("%g", lua_tonumber(L, i));
                break;
            case LUA_TBOOLEAN:
                printf(lua_toboolean(L, i) ? "true" : "false");
                break;
            default:
                printf("%s", lua_typename(L, t));
                break;
        }
        printf("\n");
    }
    printf("\n");
}

