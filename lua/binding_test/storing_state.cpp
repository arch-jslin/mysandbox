
#include "binding_test.hpp"

int global_r = 0;

int check_mysterious_number(lua_State* L)
{
    lua_rawgeti(L, LUA_REGISTRYINDEX, global_r); //this should already leave a number on stack
    double magical = lua_tonumber(L, 1);
    printf("magical num is %lf\n", magical);
    luaL_unref(L, LUA_REGISTRYINDEX, global_r);
    return 1;
}

int storing_state_test()
{
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    lua_pushnumber(L, 10); //store some magical data
    global_r = luaL_ref(L, LUA_REGISTRYINDEX); //this pop things!!!! must push first

    lua_pushcfunction(L, &check_mysterious_number);
    lua_setglobal(L, "check_number");

    if( luaL_dostring(L, "a = check_number(); print(a)") ) {
        printf("Failed.\n");
        return 1;
    }

    //I've decided to drop the env table practice and upvalue practices
    //env function will be removed in 5.2
    //upvalue is pretty crappy. If I need a function with encapsulated values
    //  and they are all implementable from C++ side, why bother with the slow
    //  upvalue/stack communications? function objects can do better job than this.

    lua_close(L);
    return 0;
}
