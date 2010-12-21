
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

int t_tuple (lua_State* L) {
    int op = luaL_optint(L, 1, 0);
    if( op == 0 ) {
        int i = 1;
        for(; !lua_isnone(L, lua_upvalueindex(i)); ++i )
            lua_pushvalue(L, lua_upvalueindex(i)); //dupe upvalue to the stack
        return i - 1;
    } else {
        luaL_argcheck(L, op > 0, 1, "index must be positive");
        if( lua_isnone(L, lua_upvalueindex(op)) )
            return 0;
        lua_pushvalue(L, lua_upvalueindex(op));
        return 1;
    }
}

int tuple(lua_State* L) {
    lua_pushcclosure(L, &t_tuple, lua_gettop(L));
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
    }

    //I decided to drop the env table practice
    //as env function will be removed in 5.2

    lua_pushcfunction(L, &tuple);
    lua_setglobal(L, "tuple");

    if( luaL_dostring(L, "b = tuple(1, '2', {}); print(b())") ) {
        printf("Failed.\n");
    }

    lua_close(L);
    return 0;
}
