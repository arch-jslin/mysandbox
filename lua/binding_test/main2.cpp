
#include <cstdio>
#include <cstdlib>

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luajit.h"
}

// ------------- dummy class ---------------

class Simple {
    int id_;
public:
    Simple(int id);
    ~Simple();
    int id();
};

Simple::Simple(int id) : id_(id) {
    printf("[%p:%i] Simple()\n", this, id_);
}

Simple::~Simple() {
    printf("[%p:%i] ~Simple()\n", this, id_);
}

int Simple::id() {
    return id_;
}

// --- dummy interface to C and LuaJIT FFI can call directly ---

extern "C" {
    __declspec(dllexport) Simple *Simple_Simple(int id) {
        return new Simple(id);
    }

    __declspec(dllexport) void Simple__gc(Simple *this_) {
        delete this_;
    }

    __declspec(dllexport) int Simple_id(Simple *this_) {
        return this_->id();
    }
}

// ---------- Utilities ------------

void error(lua_State* L, char const* fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    printf("\n");
    lua_close(L);
    exit(EXIT_FAILURE);
}

bool load_lua_script(lua_State* L, char const* filename)
{
    if( luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0) ) {
        //bad call will return non-zero
        error(L, "cannot load file: \n  %s", lua_tostring(L, -1) );
        return true;
    }
    return false;
}

// ------------ Main -------------

int main()
{
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    load_lua_script(L, "simple_jit_ffi.lua");

    lua_close(L);
    return 0;
}
