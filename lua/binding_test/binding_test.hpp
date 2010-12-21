#ifndef BINDING_TEST_HPP_INCLUDED
#define BINDING_TEST_HPP_INCLUDED

#include <cstdio>
#include <cstdlib>
#include <cstdarg>
#include <lua.hpp>

int binding1();               /* example code from: http://lua-users.org/wiki/SimpleLuaApiExample */
int run_simple_interpreter(); /* example code from PiL 24.1 */
int stack();                  /* example code from PiL 24.2 */
int binding2();               /* example code from PiL 25 ~ 27 */
int storing_state_test();

extern void error(lua_State* L, char const* fmt, ...);
extern void stack_dump(lua_State* L);

#endif // BINDING_TEST_HPP_INCLUDED
