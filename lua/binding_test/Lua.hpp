
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <tr1/tuple>

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "luajit.h"
}

namespace lua {

class StackUtils {
public:
    StackUtils(lua_State* Lp):L(Lp) {}

    inline void push_(double const& v) { lua_pushnumber(L, v); }
    inline void push_(int const& v)    { lua_pushinteger(L, v); }
    inline void push_(char const*& v)  { lua_pushstring(L, v); }
    template<int N>
    inline void push_(char const (&v)[N]) {lua_pushlstring(L, v, N); }
    template<typename T>
    inline void push_(T const& v); //not implemented, so you know you can't push this.

    template<typename T>
    inline T fetch_(int n);

    inline void push_args_(){}

    template<typename Head, typename... Tail>
    inline void push_args_(Head const& h, Tail const&... t)
    {
        push_(h);
        push_args_(t...);
    }

    template<int N, int I, typename Head, typename... Tail, typename ReturnObject>
    inline void get_results_(ReturnObject& res)
    {
        using namespace std::tr1;
        get<I>(res) = fetch_<Head>(L, -N);
        get_results_<N-1, I+1, Tail...>(res);
    }

    template<int N, int I, typename ReturnObject>
    inline void get_results_(ReturnObject& res){}

    template<typename... Rets, typename... Args>
    std::tr1::tuple<Rets...>
    call_R(char const* funcname, Args const&... args)
    {
        using namespace std::tr1;

        lua_getglobal(L, funcname); //tell lua to push the function into stack
        int const nargs = sizeof...(args), nrets = sizeof...(Rets);
        luaL_checkstack(L, nargs, "Too many arguments.");

        push_args_(args...);

        if( lua_pcall(L, nargs, nrets, 0) )
            error("error calling '%s': %s", funcname, lua_tostring(L, -1));

        tuple<Rets...> results;
        get_results_<sizeof...(Rets), 0, Rets...>(results);
        return results;
    }

    template<typename... Args>
    void call(char const* funcname, Args const&... args)
    {
        lua_getglobal(L, funcname); //tell lua to push the function into stack
        int const nargs = sizeof...(args);
        luaL_checkstack(L, nargs, "Too many arguments.");

        push_args_(args...);

        if( lua_pcall(L, nargs, 0, 0) )
            error("error calling '%s': %s", funcname, lua_tostring(L, -1));
    }

    bool run_script(char const* filename) {
        if( luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0) ) {
            //bad call will return non-zero
            error("cannot load file: \n  %s", lua_tostring(L, -1) );
            return true;
        }
        return false;
    }

    bool eval(char const* script) {
        if( luaL_loadstring(L, script) || lua_pcall(L, 0, LUA_MULTRET, 0) ) {
            error("eval failed: \n  %s", lua_tostring(L, -1) );
            return true;
        }
        return false;
    }

    void error(char const* fmt, ...) { // C-style vararg
        va_list argp;
        va_start(argp, fmt);
        vfprintf(stderr, fmt, argp);
        va_end(argp);
        printf("\n");
        lua_close(L);
        exit(EXIT_FAILURE);
    }

protected:

    lua_State* L;

};

template<> inline double      StackUtils::fetch_(int n) { return luaL_checknumber(L, n); }
template<> inline    int      StackUtils::fetch_(int n) { return luaL_checkint(L, n); }
template<> inline char const* StackUtils::fetch_(int n) { return luaL_checkstring(L, n); }

// -------------------------------------------------------------------------------

class Lua : public StackUtils {
public:
    Lua(lua_State* L):StackUtils(L) {}

    template<typename T>
    void define(luaL_reg const* func_list, lua_CFunction destroy) {
        luaL_register(L, T::classname, func_list);
    }

    template<typename T>
    inline T* fetchUD_(int n) {
        return static_cast<T*>( lua_touserdata(L, n) );
    }

    template<typename T>
    inline void pushUD_(T* v) {
        lua_pushlightuserdata(L, v);
    }

    inline void release_obj_record(void*) {};

};

class Lua2 : public StackUtils {
public:
    Lua2(lua_State* L):StackUtils(L) {}

    template<typename T>
    inline void define(luaL_reg const* func_list, lua_CFunction destroy) {
        lua_newtable(L);                    // type-checking table
        lua_replace(L, LUA_ENVIRONINDEX);   // set as env table
        luaL_register(L, T::classname, func_list);
    }

    template<typename T>
    inline T* fetchUD_(int n) {
        T* ud = static_cast<T*>( lua_touserdata(L, n) );
        if( ud == NULL || !checktype(ud) )
            luaL_typerror(L, n, T::classname);
        return ud;
    }

    template<typename T>
    inline void pushUD_(T* v) {
        lua_pushlightuserdata(L, v);
        lua_pushvalue(L, -1);            // duplicate ud address onto stack
        lua_pushstring(L, T::classname);
        lua_rawset(L, LUA_ENVIRONINDEX); // envtable[address] = typename
    }

    inline void release_obj_record(void* ud) {
        lua_pushlightuserdata(L, ud);      // push address
        lua_pushnil(L);
        lua_settable(L, LUA_ENVIRONINDEX); // envtable[address] = nil
    }

private:
    template<typename T>
    bool checktype(T* ud) {
        lua_pushlightuserdata(L, ud);    // push address
        lua_rawget(L, LUA_ENVIRONINDEX); // fetch envtable[ud address]
        char const* stored_tname = fetch_<char const*>(-1);
        bool res = stored_tname && strcmp(stored_tname, T::classname) == 0;
        lua_pop(L, 1);
        return res;
    }
};

class Lua3 : public StackUtils {
public:
    Lua3(lua_State* L):StackUtils(L) {}

    template<typename T>
    void define(luaL_reg const* func_list, lua_CFunction destroy) {
        lua_newtable(L);                    // unique-checking table
        lua_pushstring(L, "v");
        lua_setfield(L, -2, "__mode");      // t.__mode = "v" (weak-'v'alue)
        lua_pushvalue(L, -1);               // dupe the table itself
        lua_setmetatable(L, -2);            // assign itself as its metatable
        lua_replace(L, LUA_ENVIRONINDEX);   // and again, let it be envtable
        luaL_register(L, T::classname, func_list);
        luaL_newmetatable(L, T::classname); // create mt for this type of objects
        lua_pushvalue(L, -2);               // dupe libtable by luaL_register there
        lua_setfield(L, -2, "__index");     // mt.__index = libtable
        lua_pushcfunction(L, destroy);
        lua_setfield(L, -2, "__gc");        // mt.__gc = d'tor
        if( T::basename ) {
            luaL_getmetatable(L, T::basename);
            lua_setfield(L, -2, "__base"); // mt.__base = base's mt
        }
        lua_pop(L, 1);                      // pop mt
        if( T::basename ) {
            lua_getfield(L, LUA_GLOBALSINDEX, T::basename);
            lua_setfield(L, -2, "__index"); // libtable.__index = base's libtable
            lua_pushvalue(L, -1);           // dupe libtable
            lua_setmetatable(L, -2);        // assign itself as its metatable
        }
    }

//    template<typename T>
//    inline T* fetchUD_(int n) {
//        void** box = (void**) luaL_checkudata(L, n, T::classname);
//        if( box == NULL )
//            luaL_typerror(L, n, T::classname);
//        return static_cast<T*>(*box);    //unbox it, it's still a pointer.
//    }
    template<typename T>
    inline T* fetchUD_(int n) {
        lua_getfield(L, LUA_REGISTRYINDEX, T::classname); // get libtable by name
        lua_getmetatable(L, n);          // get metatable for this box
        while( lua_istable(L, -1) ) {       // while it's still a metatable
            if( lua_rawequal(L, -1, -2) ) { // if met
                lua_pop(L, 2);              // get rid of those 2 on the stack
                return static_cast<T*>( *((void**)lua_touserdata(L, n)) ); // return unboxed pointer
            }
            lua_getfield(L, -1, "__base");  // get mt.__base on top of the stack
            lua_replace(L, -2);             // mt = mt.__base
        }
        luaL_typerror(L, n, T::classname);
        return NULL;
    }

    template<typename T>
    inline void pushUD_(T* v) {
        lua_pushlightuserdata(L, v);     // push ud address
        lua_rawget(L, LUA_ENVIRONINDEX); // get box in envtable
        if( lua_isnil(L, -1) ) {         // if the box is not recorded
            void** box = (void**)lua_newuserdata(L, sizeof(void*)); //boxed pointer
            *box = v;                    // store udata address in the box
            luaL_getmetatable(L, T::classname); // get mt by name
            lua_setmetatable(L, -2);     // setmetatable(box, mt)
            lua_pushlightuserdata(L, v); // push ud address
            lua_pushvalue(L, -2);        // push box
            lua_rawset(L, LUA_ENVIRONINDEX); //envtable[ud address] = box
        }
    }

    inline void release_obj_record(void* ud) {
        lua_pushlightuserdata(L, ud);      // push address
        lua_pushnil(L);
        lua_settable(L, LUA_ENVIRONINDEX); // envtable[address] = nil
    }
};

class Lua4 : public StackUtils {
public:
    Lua4(lua_State* L):StackUtils(L) {}

    template<typename T>
    void define(luaL_reg const* func_list, lua_CFunction destroy) {
        lua_newtable(L);                    // unique-checking table
        lua_pushstring(L, "v");
        lua_setfield(L, -2, "__mode");      // t.__mode = "v" (weak-'v'alue)
        lua_pushvalue(L, -1);               // dupe the table itself
        lua_setmetatable(L, -2);            // assign itself as its metatable
        lua_replace(L, LUA_ENVIRONINDEX);   // and again, let it be envtable
        luaL_register(L, T::classname, func_list);
        luaL_newmetatable(L, T::classname); // create mt for this type of objects
        lua_pushvalue(L, -2);               // dupe libtable by luaL_register there
        lua_setfield(L, -2, "__index");     // mt.__index = libtable
        lua_pushcfunction(L, destroy);
        lua_setfield(L, -2, "__gc");        // mt.__gc = d'tor
        if( T::basename ) {
            luaL_getmetatable(L, T::basename);
            lua_setfield(L, -2, "__base"); // mt.__base = base's mt
        }
        lua_pop(L, 1);                      // pop mt
        if( T::basename ) {
            lua_getfield(L, LUA_GLOBALSINDEX, T::basename);
            lua_setfield(L, -2, "__index"); // libtable.__index = base's libtable
            lua_pushvalue(L, -1);           // dupe libtable
            lua_setmetatable(L, -2);        // assign itself as its metatable
        }
    }

    template<typename T>
    inline T* fetchUD_(int n) {
        lua_getfield(L, LUA_REGISTRYINDEX, T::classname); // get libtable by name
        lua_getmetatable(L, n);             // get metatable for this tobj
        while( lua_istable(L, -1) ) {       // while it's still a metatable
            if( lua_rawequal(L, -1, -2) ) { // if met
                lua_pop(L, 2);              // get rid of those 2 on the stack
                lua_getfield(L, n, "__pointer"); // get box to the top of stack
                return static_cast<T*>( *((void**)lua_touserdata(L, -1)) ); // return unboxed pointer
            }
            lua_getfield(L, -1, "__base");  // get mt.__base on top of the stack
            lua_replace(L, -2);             // mt = mt.__base
        }
        luaL_typerror(L, n, T::classname);
        return NULL;
    }

    template<typename T>
    inline void pushUD_(T* v) {
        lua_pushlightuserdata(L, v);     // push ud address
        lua_rawget(L, LUA_ENVIRONINDEX); // get tobj in envtable
        if( lua_isnil(L, -1) ) {         // if the tobj is not recorded
            void** box = (void**)lua_newuserdata(L, sizeof(void*)); //boxed pointer
            *box = v;                    // store udata address in the box
            luaL_getmetatable(L, T::classname); // get mt by name
            lua_setmetatable(L, -2);     // setmetatable(box, mt)

            lua_newtable(L);             // new table to be the surface obj
            lua_pushvalue(L, -2);         // dupe box
            lua_setfield(L, -2, "__pointer"); // tobj.__pointer = box
            luaL_getmetatable(L, T::classname); // get mt by name again
            lua_setmetatable(L, -2);     // setmetatable(tobj, mt)

            lua_pushlightuserdata(L, v); // push ud address
            lua_pushvalue(L, -2);        // dupe tobj
            lua_rawset(L, LUA_ENVIRONINDEX); //envtable[ud address] = tobj
        }
    }

    inline void release_obj_record(void* ud) {
        lua_pushlightuserdata(L, ud);      // push address
        lua_pushnil(L);
        lua_settable(L, LUA_ENVIRONINDEX); // envtable[address] = nil
    }
};

} //Lua
