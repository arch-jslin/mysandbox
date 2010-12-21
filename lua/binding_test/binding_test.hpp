#ifndef BINDING_TEST_HPP_INCLUDED
#define BINDING_TEST_HPP_INCLUDED

#include <cstdio>
#include <cstdlib>
#include <cstdarg>
#include <lua.hpp>

int binding1(lua_State*);               /* example code from: http://lua-users.org/wiki/SimpleLuaApiExample */
int run_simple_interpreter(lua_State*); /* example code from PiL 24.1 */
int stack(lua_State*);                  /* example code from PiL 24.2 */
int binding2(lua_State*);               /* example code from PiL 25 ~ 27 */
int storing_state_test(lua_State*);
int easy_binding_test(lua_State*);

extern void error(lua_State* L, char const* fmt, ...);
extern void stack_dump(lua_State* L);

#endif // BINDING_TEST_HPP_INCLUDED
