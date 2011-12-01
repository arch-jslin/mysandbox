
#include <cstdio>
#include <cstdlib>
#include <string>
#include <tr1/memory>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__)
#define APIEXPORT __declspec(dllexport)
#else
#define APIEXPORT
#endif

#include "Lua.hpp"
#include "lua_glue.h"

using namespace lua;

// ------------- dummy class ---------------

class Someotherclass {
private:
    std::string somedata_;
public:
    Someotherclass():somedata_("blah") {
        printf("[%p:%s] Someotherclass()\n", this, somedata_.c_str());
    }
    ~Someotherclass() {
        printf("[%p:%s] ~Someotherclass()\n", this, somedata_.c_str());
    }
    std::string getData() { return somedata_; }
    void setData(char const* in) { somedata_ = in; }
};

class SimpleBase {
protected:
    Someotherclass* some_;
    int id_;
public:
    SimpleBase(int id):id_(id) {
        some_ = new Someotherclass;
        printf("[%p:%i] SimpleBase()\n", this, id_);
    }
    ~SimpleBase() {
        //delete some_;
        printf("[%p:%i] ~SimpleBase()\n", this, id_);
    }
    void setName(std::string const& s) {}
    std::string getName() { return some_->getData(); }
    void change_somedata(Someotherclass* other) {
        delete some_; //very awkward, but, anyway.
        some_ = other;
    }

    static char const* classname;
    static char const* basename;
};

char const* SimpleBase::classname = "SimpleBase";
char const* SimpleBase::basename  = 0;

class Simple : public SimpleBase {
public:
    Simple(int id);
    ~Simple();
    int getID();
    void setID(int);

    static char const* classname;
    static char const* basename;
};

typedef std::tr1::shared_ptr<void> pvoid;
typedef std::tr1::shared_ptr<Simple> pSimplePtr;

template <typename T>
struct Box {
    std::tr1::shared_ptr<T> p;
};

typedef Box<Simple> BoxSimple;

char const* Simple::classname = "Simple";
char const* Simple::basename  = "SimpleBase";

Simple::Simple(int id) : SimpleBase(id) {
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

// ------ LuaJIT FFI direct binding --------
// --- dummy interface to C and LuaJIT FFI can call directly ---

extern "C" {
    APIEXPORT BoxSimple* get_Simple(int id) {
        BoxSimple* p = new BoxSimple;
        p->p = pSimplePtr(new Simple(id));
        printf("use_count: %ld\n", p->p.use_count());
        return p;
    }

    APIEXPORT void Simple__reset(BoxSimple* p) {
        printf("data: %d\n", p->p->getID());
        printf("name: %s\n", p->p->getName().c_str());
        printf("use_count: %ld\n", p->p.use_count());
        p->p.reset();
        delete p;
        printf("-------------------\n");
    }

    APIEXPORT Someotherclass* new_Someotherclass() {
        return new Someotherclass;
    }

    APIEXPORT char const* Someotherclass_getData(Someotherclass* this_) {
        return this_->getData().c_str();
    }

    APIEXPORT void Someotherclass_setData(Someotherclass* this_, char const* str) {
        this_->setData(str);
    }

    APIEXPORT void Someotherclass__gc(Someotherclass* this_) {
        delete this_;
    }

    APIEXPORT char const* Simple_getName(Simple *this_) {
        return this_->getName().c_str();
    }

    APIEXPORT void Simple__gc(Simple *this_) {
        delete this_;
    }

    APIEXPORT int Simple_getID(Simple *this_) {
        return this_->getID();
    }

    APIEXPORT void Simple_setID(Simple* this_, int id) {
        this_->setID(id);
    }

    APIEXPORT void Simple_change_somedata(Simple* this_, Someotherclass* data) {
        this_->change_somedata(data);
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

// ------------------- lua_glue_test ------------------------

template<> const char * Glue<SimpleBase>::usr_name() { return SimpleBase::classname; }
template<> const char * Glue<Simple>    ::usr_name() { return Simple::classname; }

static int lua_simplebase_getID(lua_State * L) {
    SimpleBase * self = Glue<SimpleBase>::checkto(L, 1);
    lua_pushstring(L, self->getName().c_str());
    return 1;
}

template<> void Glue<SimpleBase> :: usr_mt(lua_State * L) {
    lua_pushcfunction(L, lua_simplebase_getID); lua_setfield(L, -2, "getName");
}

template<> Simple * Glue<Simple>::usr_new(lua_State * L) {
    return new Simple(luaL_checknumber(L, 1));
}

static int lua_simple_getID(lua_State * L) {
    Simple * self = Glue<Simple>::checkto(L, 1);
    lua::push(L, self->getID());
    return 1;
}

static int lua_simple_setID(lua_State * L) {
    Simple * self = Glue<Simple>::checkto(L, 1);
    self->setID( lua::to<int>(L, 2) );
    return 0;
}

template<> void Glue<Simple> :: usr_mt(lua_State * L) {
    lua_pushcfunction(L, lua_simple_getID); lua_setfield(L, -2, "getID");
    lua_pushcfunction(L, lua_simple_setID); lua_setfield(L, -2, "setID");
}

template<> void Glue<Simple>::usr_gc(lua_State * L, Simple* u) {
    delete u;
}

template<> const char * Glue<Simple>::usr_supername() { return Glue<SimpleBase>::usr_name(); }

int test_lua_glue(lua_State* L)
{
    char const* str = lua::to<char const*>(L, -1);
    printf("running file: %s\n", str);
    lua_pop(L, 1); //get rid of the file name string from the stack

    static const luaL_reg empty[] = {
        {NULL, NULL}
    };

    luaL_register(L, "SimpleBase", empty);
    Glue<SimpleBase>::define(L);
    Glue<SimpleBase>::register_ctor(L);
    luaL_register(L, "Simple", empty);
	Glue<Simple>::define(L);
	Glue<Simple>::register_ctor(L);
    Lua lua(L);
    lua.run_script( str ); //get script name from lua stack
    return 1;
}

// ----------------------------------------------------------------

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

void test_simple_cpp_obj5() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushcfunction(L, &test_lua_glue);
    lua_pushstring(L, "simple_cpp_obj4.lua");
    lua_call(L, 1, 1);
    lua_close(L);
}

int main()
{
    test_jit_ffi();
    printf("--------------------------------------\n");
//    test_simple_cpp_obj();
//    printf("--------------------------------------\n");
//    test_simple_cpp_obj2();
//    printf("--------------------------------------\n");
//    test_simple_cpp_obj3();
//    printf("--------------------------------------\n");
//    test_simple_cpp_obj4();
//    printf("--------------------------------------\n");
//    test_simple_cpp_obj5();
    return 0;
}
