#ifndef _CUBEAT_UTILS_OBJECTPOOL_
#define _CUBEAT_UTILS_OBJECTPOOL_

#include <boost/pool/object_pool.hpp>
#include <boost/thread/mutex.hpp>

#define LOKI_CLASS_LEVEL_THREADING
#include "loki/Singleton.h"

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
        return element_type(SPool::Instance().construct(), Deleter(), boost::fast_pool_allocator<element_type>());
    }

    static void backup() {
        SPool::Instance().clone_to(backup_);
    }

    static void restore() {
        SPool::Instance().restore(backup_);
    }

    template <class T0>
    static element_type create(T0 & a){
        return element_type(SPool::Instance().construct(a), Deleter(), boost::fast_pool_allocator<element_type>());
    }

    template <class T0>
    static element_type create(T0 const& a){
        return element_type(SPool::Instance().construct(a), Deleter(), boost::fast_pool_allocator<element_type>());
    }

    template <class T0, class T1>
    static element_type create(T0 & a, T1 & b){
        return element_type(SPool::Instance().construct(a, b), Deleter(), boost::fast_pool_allocator<element_type>());
    }

    template <class T0, class T1>
    static element_type create(T0 & a, T1 const& b){
        return element_type(SPool::Instance().construct(a, b), Deleter(), boost::fast_pool_allocator<element_type>());
    }

    template <class T0, class T1>
    static element_type create(T0 const& a, T1 & b){
        return element_type(SPool::Instance().construct(a, b), Deleter(), boost::fast_pool_allocator<element_type>());
    }

    template <class T0, class T1>
    static element_type create(T0 const& a, T1 const& b){
        return element_type(SPool::Instance().construct(a, b), Deleter(), boost::fast_pool_allocator<element_type>());
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

    static pool_type backup_;

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

template<typename T>
object_pool_mt<T> ObjectPool<T>::backup_;

}} // end of namespace

#endif
