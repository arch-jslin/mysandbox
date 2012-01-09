#include <cstdio>
#include <boost/tr1/functional.hpp>
#include "lua_utils.hpp"
#include "Coro.h"

#include <ctime>

using namespace std::tr1::placeholders;

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

void call_lua_directly(lua_State* L, int n)
{
    Lua::call(L, "func2", n);
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
    printf("LuaJIT FFI callback 10M times: %ld\n", clock() - t);

    t = clock();
    std::tr1::function<void(int)> func1 = bind(blah, _1);
    for( int i = 0; i < 10000000; ++i ) {
        func1(100);
    }
    printf("C++ call a wrapper callback 10M times: %ld\n", clock() - t);

    t = clock();
    std::tr1::function<void(int)> func2 = bind(call_lua_directly, L, _1);
    for( int i = 0; i < 10000000; ++i ) {
        func2(100);
    }
    printf("C++ call Lua through a wrapper callback 10M times: %ld\n", clock() - t);

    t = clock();
    Coro_startCoro_(mainCoro, firstCoro, (void *)L, start_lua);
    for( int i = 0; i < 10000000; ++i ) {
        Coro_switchTo_(mainCoro, firstCoro);
    }
    printf("Coroutine switch and only let LuaJIT FFI call C 10M times: %ld", clock() - t);

    return 0;
}
