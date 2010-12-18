#include "binding_test.hpp"
#include <tr1/tuple>

using std::tr1::tuple;
using std::tr1::get;

bool load_lua_script(lua_State* L, char const* filename)
{
    if( luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0) ) {
        //bad call will return non-zero
        error(L, "cannot load file: \n  %s", lua_tostring(L, -1) );
        return true;
    }
    return false;
}

inline void lua_push_(lua_State* L, double const& v) { lua_pushnumber(L, v); }
inline void lua_push_(lua_State* L, int const& v)    { lua_pushinteger(L, v); }
inline void lua_push_(lua_State* L, char const*& v)  { lua_pushstring(L, v); }
template<int N>
inline void lua_push_(lua_State* L, char const (&v)[N]) {lua_pushlstring(L, v, N); }
template<typename T>
inline void lua_push_(lua_State* L, T const& v); //not implemented, so you know you can't push this.

template<typename T>
inline T lua_to_(lua_State* L, int n);
template<> inline double      lua_to_(lua_State* L, int n) { return lua_tonumber(L, n); }
template<> inline    int      lua_to_(lua_State* L, int n) { return lua_tointeger(L, n); }
template<> inline char const* lua_to_(lua_State* L, int n) { return lua_tostring(L, n); }

inline void push_args_to_stack_(lua_State* L){}

template<typename Head, typename... Tail>
inline void push_args_to_stack_(lua_State* L, Head const& h, Tail const&... t)
{
    lua_push_(L, h);
    push_args_to_stack_(L, t...);
}

template<int N, int I, typename Head, typename... Tail, typename ReturnObject>
inline void get_results_(lua_State* L, ReturnObject& res)
{
    get<I>(res) = lua_to_<Head>(L, -N);
    get_results_<N-1, I+1, Tail...>(L, res);
}

template<int N, int I, typename ReturnObject>
inline void get_results_(lua_State* L, ReturnObject& res){}

template<typename... Rets, typename... Args>
tuple<Rets...>
call_lua_function(lua_State* L, char const* funcname, Args const&... args)
{
    lua_getglobal(L, funcname); //tell lua to push the function into stack
    int const nargs = sizeof...(args), nrets = sizeof...(Rets);
    luaL_checkstack(L, nargs, "Too many arguments.");

    push_args_to_stack_(L, args...);

    if( lua_pcall(L, nargs, nrets, 0) )
        error(L, "error calling '%s': %s", funcname, lua_tostring(L, -1));

    tuple<Rets...> results;
    get_results_<sizeof...(Rets), 0, Rets...>(L, results);
    return results;
}

int binding2()
{
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    if( load_lua_script(L, "binding2.lua") )
        return 1;

    tuple<int> r = call_lua_function<int>(L, "method1", 3, 4);

    printf("%d\n", get<0>(r));

    tuple<int, double, char const*> r2 =
        call_lua_function<int, double, char const*>(L, "identity", 1, 2.0, "3");

    printf("%d, %lf, %s\n", get<0>(r2), get<1>(r2), get<2>(r2));

    lua_settop(L, 0);
    lua_close(L);
    return 0;
}
