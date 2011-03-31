
#include <iostream>
#include <tr1/memory>
#include <cstdlib>

#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/pool/object_pool.hpp>

#include "Logger.hpp"
#include "ObjectPool.hpp"

using namespace std;
using namespace tr1;
using namespace psc;
using namespace utils;

struct Dummy {
    Dummy(int i) { i_ = i; }
    ~Dummy() {
        //Logger::i().buf(" Dummy ").buf(this).buf(" is killed.").endl();
        int a = 10 + 2.3f;
        volatile int b = a * 2.2;
    }
    int i_;
};
typedef shared_ptr<Dummy> pDummy;

struct Data {
    typedef shared_ptr<Data> pointer_type;
    static pointer_type create(int i, pDummy p) {
        return ObjectPool<Data>::create(i, p);
    }
    static pointer_type create(int i) {
        return ObjectPool<Data>::create(i);
    }
    Data(int i, pDummy p):d(i), pd(p){}
    Data(int i):d(i){}
    Data():d(0){}
    ~Data(){
        //Logger::i().buf("Data destructor called.").endl();
    }

    int d;
    double dd[10];
    pDummy pd;
};

typedef Data::pointer_type pData;

void threaded_func1() {
    for( int i = 0; i < 1000; ++i ) {
        pDummy dummy = pDummy(new Dummy(1)); //although dummy's life cycle is so short
        //it won't give back the memory of new Dummy(1)
    }
//    for( int i = 0; i < 1000; ++i ) {
//        volatile Dummy* dummy = new Dummy(1);
//        dummy->i_[0] = 2; //anyway make sure it's not optimized by compiler.
//        delete dummy;     //and you'll find out dummy is released here correctly. (no mem growth)
//    }
}

int main()
{
    typedef shared_ptr<boost::thread> pThread;

    pThread my_thread_;

    for( int j = 0; j < 1000; ++j ) {
        my_thread_ = pThread( new boost::thread(&threaded_func1) );
        my_thread_->join();
    }

    Logger::i().buf(" Main Program ends.").endl();

    return 0;
}
