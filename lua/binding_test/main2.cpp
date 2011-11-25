
#include <cstdio>
#include <cstdlib>
#include <string>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__)
#define APIEXPORT __declspec(dllexport)
#else
#define APIEXPORT
#endif

#include "Lua.hpp"

using namespace lua;

// ------------- dummy class ---------------

class SimpleBase {
public:
    void setName(std::string const& s) {}
    std::string getName() { return "hello"; }

    static char const* classname;
    static char const* basename;
};

char const* SimpleBase::classname = "SimpleBase";
char const* SimpleBase::basename  = 0;

class Simple {
    int id_;
public:
    Simple(int id);
    ~Simple();
    int getID();
    void setID(int);

    static char const* classname;
    static char const* basename;
};

char const* Simple::classname = "Simple";
char const* Simple::basename  = "SimpleBase";

// ------ LuaJIT FFI direct binding --------

Simple::Simple(int id) : id_(id) {
    printf("[%p:%i] Simple()\n", this, id_);
}

Simple::~Simple() {
    printf("[%p:%i] ~Simple()\n", this, id_);
}

int Simple::getID() {
    return id_;
}

void Simple::setID(int id) {
    id_ = id;
}

// --- dummy interface to C and LuaJIT FFI can call directly ---

extern "C" {
    APIEXPORT void Simple__gc(Simple *this_) {
        delete this_;
    }

    APIEXPORT int Simple_getID(Simple *this_) {
        return this_->getID();
    }

    APIEXPORT void Simple_setID(Simple* this_, int id) {
        this_->setID(id);
    }

    APIEXPORT Simple *new_Simple(int id) {
        return new Simple(id);
    }
}

// --- Game Programming Gems 4.2-1 ---------------------

template<typename Binder>
int l_SimpleBase_getName(lua_State* L) {
    Binder lua(L);
    SimpleBase* sb = lua.template fetchUD_<SimpleBase>(1);
    char const* str = sb->getName().c_str();
    lua.push_(str);
    return 1;
}

template<typename Binder>
int l_Simple_create(lua_State* L) {
    Binder lua(L);
    Simple* s = new Simple(lua.template fetch_<int>(1));
    lua.pushUD_(s);
    return 1;
}

template<typename Binder>
int l_Simple_getID(lua_State* L) {
    Binder lua(L);
    Simple* s = lua.template fetchUD_<Simple>(1);
    lua.push_(s->getID());
    return 1;
}

template<typename Binder>
int l_Simple_setID(lua_State* L) {
    Binder lua(L);
    Simple* s = lua.template fetchUD_<Simple>(1);
    s->setID(lua.template fetch_<int>(2));
    return 0;
}

template<typename Binder>
int l_Simple_destroy(lua_State* L) {
    Binder lua(L);
    Simple* s = lua.template fetchUD_<Simple>(1);
    lua.release_obj_record(s);
    delete s;
    return 0;
}

template<typename Binder>
int l_Simple_destroy2(lua_State* L) {
    Binder lua(L);
    Simple* s = static_cast<Simple*>( *((void**)lua_touserdata(L, 1)) );
    lua.release_obj_record(s);
    delete s;
    return 0;
}

// ------------ Main -------------

void test_jit_ffi() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    Lua lua(L);
    lua.run_script("simple_jit_ffi.lua");
    lua_close(L);
}

template<typename Binder>
int start_lua_sequence(lua_State* L)
{
    static const luaL_reg simple_base_api[] = {
        {"getName", &l_SimpleBase_getName<Binder>},
        {NULL, NULL}
    };
    static const luaL_reg simple_api[] = {
        {"create",  &l_Simple_create<Binder>},
        {"destroy", &l_Simple_destroy<Binder>},
        {"getID",   &l_Simple_getID<Binder>},
        {"setID",   &l_Simple_setID<Binder>},
        {NULL, NULL}
    };

    char const* str = luaL_checkstring(L, -1);
    printf("running file: %s\n", str);

    Binder lua(L);
    lua.template define<SimpleBase>(simple_base_api, 0);
    lua.template define<Simple>(simple_api, &l_Simple_destroy2<Binder>);
    lua.run_script( str ); //get script name from lua stack
    return 1;
}

void test_simple_cpp_obj() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, &start_lua_sequence<Lua>);
    lua_pushstring(L, "simple_cpp_obj.lua");
    lua_call(L, 1, 1);
    lua_close(L);
}

void test_simple_cpp_obj2() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, &start_lua_sequence<Lua2>);
    lua_pushstring(L, "simple_cpp_obj.lua");
    lua_call(L, 1, 1);
    lua_close(L);
}

void test_simple_cpp_obj3() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, &start_lua_sequence<Lua3>);
    lua_pushstring(L, "simple_cpp_obj2.lua");
    lua_call(L, 1, 1);
    lua_close(L);
}

void test_simple_cpp_obj4() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, &start_lua_sequence<Lua4>);
    lua_pushstring(L, "simple_cpp_obj3.lua");
    lua_call(L, 1, 1);
    lua_close(L);
}

int main()
{
    test_jit_ffi();
    printf("--------------------------------------\n");
    test_simple_cpp_obj();
    printf("--------------------------------------\n");
    test_simple_cpp_obj2();
    printf("--------------------------------------\n");
    test_simple_cpp_obj3();
    printf("--------------------------------------\n");
    test_simple_cpp_obj4();
    return 0;
}
