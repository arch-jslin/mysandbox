#include <cstdio>
#include <boost/tr1/functional.hpp>
#include "lua_utils.hpp"
#include "Coro.h"

#include <ctime>

std::tr1::function<void(int)> THE_CALLBACK = 0;
Coro *mainCoro, *firstCoro;

extern "C" {
    typedef struct {
        int type;
    } Event;

    __declspec(dllexport) void set_callback(void (*cb)(int)) {
        THE_CALLBACK = cb;
    }

    __declspec(dllexport) int poll() {
        Coro_switchTo_(firstCoro, mainCoro);
        return 100;
    }
}

void start_lua(void* context)
{
    lua_State* L = static_cast<lua_State*>(context);
    Lua::call(L, "start_loop");
}

void blah(volatile int a)
{
    a = a + 1298346712;
}

int main()
{
    mainCoro = Coro_new();
	Coro_initializeMainCoro(mainCoro);
	firstCoro = Coro_new();

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    Lua::run_script(L, "test.lua");

    std::time_t t = clock();
    for( int i = 0; i < 10000000; ++i ) {
        THE_CALLBACK(100);
    }
    printf("LuaJIT FFI Callback 10M times: %ld\n", clock() - t);

    t = clock();

    for( int i = 0; i < 10000000; ++i ) {
        blah(100);
    }
    printf("C direct call 10M times: %ld\n", clock() - t);

    t = clock();
    for( int i = 0; i < 10000000; ++i ) {
        Lua::call(L, "func2", 100);
    }
    printf("C call Lua through Lua/C API directly 10M times: %ld\n", clock() - t);

    t = clock();
    Coro_startCoro_(mainCoro, firstCoro, (void *)L, start_lua);
    for( int i = 0; i < 10000000; ++i ) {
        Coro_switchTo_(mainCoro, firstCoro);
    }
    printf("Coroutine switch and only let LuaJIT FFI call C 10M times: %ld", clock() - t);

    return 0;
}
