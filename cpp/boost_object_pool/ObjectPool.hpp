#ifndef _CUBEAT_UTILS_OBJECTPOOL_
#define _CUBEAT_UTILS_OBJECTPOOL_

// Note: By the usage of this, we actually stucked with boost's implementation.
#include <boost/smart_ptr/make_shared.hpp>
#include <boost/thread/mutex.hpp>

// Note: we are using our own implementation of boost.pool, in a sense,
//       so don't make the include path fool you. changed to utils.pool.
//       However, for convenience of porting, the namespace in the file remained boost::.
#include "utils/pool/object_pool.hpp"
#include "utils/pool/singleton_pool.hpp"
#include "utils/pool/pool_alloc.hpp"

#define LOKI_CLASS_LEVEL_THREADING
#include "loki/Singleton.h"

typedef std::tr1::shared_ptr<void> pvoid;

namespace psc{ namespace utils{

template <typename T, typename UserAllocator = boost::default_user_allocator_new_delete>
class object_pool_mt {
public:
    typedef typename boost::object_pool<T, UserAllocator>::element_type element_type;

    inline void destroy_mt(element_type* const chunk){
        chunk->~T();
        free_mt(chunk);
    }

    inline bool is_from(element_type* const chunk) const {
        return pool_.is_from(chunk);
    }

    void clone_to(object_pool_mt<T, UserAllocator> & clone) const {
        clone.pool_.~object_pool();
        pool_.clone_to(clone.pool_);
    }

    void restore(object_pool_mt<T, UserAllocator> & backup) {
        pool_.restore(backup.pool_);
    }

    element_type * construct(){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }


    template <class T0>
    element_type * construct(T0 & a){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0>
    element_type * construct(T0 const& a){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1>
    element_type * construct(T0 & a, T1 & b){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1>
    element_type * construct(T0 & a, T1 const& b){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1>
    element_type * construct(T0 const& a, T1 & b){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1>
    element_type * construct(T0 const& a, T1 const& b){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 & a, T1 & b, T2 & c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 & a, T1 & b, T2 const& c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 & a, T1 const& b, T2 & c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 & a, T1 const& b, T2 const& c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 const& a, T1 & b, T2 & c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 const& a, T1 & b, T2 const& c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 const& a, T1 const& b, T2 & c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2>
    element_type * construct(T0 const& a, T1 const& b, T2 const& c){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 & b, T2 & c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 & b, T2 & c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 & b, T2 const& c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 & b, T2 const& c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 const& b, T2 & c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 const& b, T2 & c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 const& b, T2 const& c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 & a, T1 const& b, T2 const& c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 & b, T2 & c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 & b, T2 & c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 & b, T2 const& c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 & b, T2 const& c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 const& b, T2 & c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 const& b, T2 & c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 const& b, T2 const& c, T3 & d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3>
    element_type * construct(T0 const& a, T1 const& b, T2 const& c, T3 const& d){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 & c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 & c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 & c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 & c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 const& c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 const& c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 const& c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 & b, T2 const& c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 & c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 & c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 & c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 & c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 const& c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 const& c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 const& c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 & a, T1 const& b, T2 const& c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 & c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 & c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 & c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 & c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 const& c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 const& c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 const& c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 & b, T2 const& c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 & c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 & c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 & c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 & c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 const& c, T3 & d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 const& c, T3 & d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 const& c, T3 const& d, T4 & e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }

    template <class T0, class T1, class T2, class T3, class T4>
    element_type * construct(T0 const& a, T1 const& b, T2 const& c, T3 const& d, T4 const& e){
      element_type * const ret = malloc_mt();
      if (ret == 0)
        return ret;
      try { new (ret) element_type(a, b, c, d, e); }
      catch (...) { free_mt(ret); throw; }
      return ret;
    }


private:
    inline element_type* malloc_mt(){
        boost::mutex::scoped_lock lock(mutex_);
        return pool_.malloc();
    }
    inline void free_mt(element_type* p){
        boost::mutex::scoped_lock lock(mutex_);
        pool_.free(p);
    }
    boost::mutex mutex_;
    boost::object_pool<T, UserAllocator> pool_;
};


template <class T>
class ObjectPool{
public:
    typedef typename T::pointer_type element_type;

public:
    static element_type create(){
        return element_type(SPool::Instance().construct(), Deleter());
    }

    template <class T0>
    static element_type create(T0 & a){
        return element_type(SPool::Instance().construct(a), Deleter());
    }

    template <class T0>
    static element_type create(T0 const& a){
        return element_type(SPool::Instance().construct(a), Deleter());
    }

    template <class T0, class T1>
    static element_type create(T0 & a, T1 & b){
        return element_type(SPool::Instance().construct(a, b), Deleter());
    }

    template <class T0, class T1>
    static element_type create(T0 & a, T1 const& b){
        return element_type(SPool::Instance().construct(a, b), Deleter());
    }

    template <class T0, class T1>
    static element_type create(T0 const& a, T1 & b){
        return element_type(SPool::Instance().construct(a, b), Deleter());
    }

    template <class T0, class T1>
    static element_type create(T0 const& a, T1 const& b){
        return element_type(SPool::Instance().construct(a, b), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 & b, T2 & c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 & b, T2 const& c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 const& b, T2 & c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 const& b, T2 const& c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 & b, T2 & c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 & b, T2 const& c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 const& b, T2 & c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 const& b, T2 const& c){
        return element_type(SPool::Instance().construct(a, b, c), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 & b, T2 & c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 & b, T2 & c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 & b, T2 const& c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 & b, T2 const& c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 const& b, T2 & c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 const& b, T2 & c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 const& b, T2 const& c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 & a, T1 const& b, T2 const& c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 & b, T2 & c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 & b, T2 & c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 & b, T2 const& c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 & b, T2 const& c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 const& b, T2 & c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 const& b, T2 & c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 const& b, T2 const& c, T3 & d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3>
    static element_type create(T0 const& a, T1 const& b, T2 const& c, T3 const& d){
        return element_type(SPool::Instance().construct(a, b, c, d), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 & c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 & c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 & c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 & c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 const& c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 const& c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 const& c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 & b, T2 const& c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 & c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 & c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 & c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 & c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 const& c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 const& c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 const& c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 & a, T1 const& b, T2 const& c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 & c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 & c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 & c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 & c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 const& c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 const& c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 const& c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 & b, T2 const& c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 & c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 & c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 & c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 & c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 const& c, T3 & d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 const& c, T3 & d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 const& c, T3 const& d, T4 & e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    template <class T0, class T1, class T2, class T3, class T4>
    static element_type create(T0 const& a, T1 const& b, T2 const& c, T3 const& d, T4 const& e){
        return element_type(SPool::Instance().construct(a, b, c, d, e), Deleter());
    }

    static void destroy_all(){
        Loki::DeletableSingleton<pool_type>::GracefulDelete();
    }

private:
    typedef object_pool_mt<T> pool_type;
    typedef Loki::SingletonHolder<pool_type, Loki::CreateUsingNew, Loki::DeletableSingleton> SPool;

    static void destroy(T* t){
        SPool::Instance().destroy_mt(t);
    }
    static bool is_from(T* t){
        return SPool::Instance().is_from(t);
    }

    friend class Deleter;
    class Deleter{
    public:
        typedef void result_type;
        typedef T* argument_type;

    public:
    // u.is_from(p)    bool    Returns true if p was allocated from u or may be returned as the result of a future allocation from u.
    // Returns false if p was allocated from some other pool or may be returned as the result of a future allocation from some other pool.
    // Otherwise, the return value is meaningless; note that this function may not be used to reliably test random pointer values.
        void operator()(argument_type p){
            if(ObjectPool<T>::is_from(p))
                ObjectPool<T>::destroy(p);
        }
    };
};

/// ******** Add some metadata information for restorable pool here ******** ///

template<typename T>
class ObjectPoolRestorable
{
    typedef boost::detail::sp_counted_impl_pda<T*, boost::detail::sp_ms_deleter<T> , boost::fast_pool_allocator<T> > FUCK_IT;
    typedef boost::singleton_pool<T, sizeof(FUCK_IT)> this_pool;
    typedef typename T::pointer_type element_type;

public:

    typedef typename this_pool::pool_type pool_type;

    static void backup() {
        backup_.purge_memory(); // This is only temporary.
        // When backup, we'll have to check if backup buffer is already all used or there's still empty slot.
        this_pool::clone_to(backup_);
    }

    static void restore() {
        // This is only temporary.
        // When restore, we have to check which frame in the backup we want to rollback to.
        this_pool::restore(backup_);
    }

    static element_type create(){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>());
    }

    template <class T0>
    static element_type create(T0 & a){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a);
    }

    template <class T0>
    static element_type create(T0 const& a){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a);
    }

    template <class T0, class T1>
    static element_type create(T0 & a, T1 & b){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b);
    }

    template <class T0, class T1>
    static element_type create(T0 & a, T1 const& b){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b);
    }

    template <class T0, class T1>
    static element_type create(T0 const& a, T1 & b){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b);
    }

    template <class T0, class T1>
    static element_type create(T0 const& a, T1 const& b){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 & b, T2 & c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 & b, T2 const& c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 const& b, T2 & c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 & a, T1 const& b, T2 const& c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 & b, T2 & c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 & b, T2 const& c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 const& b, T2 & c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    template <class T0, class T1, class T2>
    static element_type create(T0 const& a, T1 const& b, T2 const& c){
        return boost::allocate_shared<T>(boost::fast_pool_allocator<T>(), a, b, c);
    }

    // ... etc generated combinations

private:
    static pool_type backup_;

};

template<typename T>
typename ObjectPoolRestorable<T>::pool_type ObjectPoolRestorable<T>::backup_;

void pools_backup();
void pools_restore();

}
} // end of namespace

#endif
