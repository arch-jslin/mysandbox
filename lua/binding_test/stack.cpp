#include "binding_test.hpp"

int stack(lua_State* L)
{
    lua_pushboolean(L, 1);
    lua_pushnumber(L, 10);
    lua_pushnil(L);
    lua_pushstring(L, "hello");

    stack_dump(L);
    lua_pushvalue(L, -3); stack_dump(L); //get element and push top
    lua_replace(L, 3);    stack_dump(L); //pop top and replace at
    lua_settop(L, 6);     stack_dump(L); //expand the stack
    lua_remove(L, -2);    stack_dump(L); //erase element
    lua_insert(L, -3);    stack_dump(L); //pop top and insert at
    lua_settop(L, 1);     stack_dump(L); //shrink the stack

    return 0;
}
