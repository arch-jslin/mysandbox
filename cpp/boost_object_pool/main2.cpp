
#include <iostream>
//#include <tr1/memory> // FUCK YOU TR1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#include <cstdlib>

#include <boost/shared_ptr.hpp>
#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/pool/object_pool.hpp>

#include "Logger.hpp"
#include "ObjectPool.hpp"

using namespace std;
//using namespace tr1;
using namespace psc;
using namespace utils;

struct Dummy {
    Dummy(int i) { i_ = i; }
    ~Dummy() {
        //Logger::i().buf(" Dummy ").buf(this).buf(" is killed.").endl();
        //you can verify this is called. everything "inside of" this object should be released
        //correctly no matter what.
        //The only thing is..  when using shared_ptr, there're other things eating up memory.
    }
    int i_;
};
typedef boost::shared_ptr<Dummy> pDummy;

void threaded_func1() {
    for( int i = 0; i < 10000; ++i ) {
        pDummy dummy = pDummy(new Dummy(1)); //although dummy's life cycle is so short
        //it won't give back the memory of some mysterious things... it's not new Dummy(1)'s memory.
    }
//    for( int i = 0; i < 10000; ++i ) {
//        volatile Dummy* dummy = new Dummy(1);
//        dummy->i_ = 2;    //anyway make sure it's not optimized by compiler.
//        delete dummy;     //and you'll find out all is released here correctly. (no mem growth)
//    }
//    for( volatile int i = 0; i < 1000000; ++i ) {
//        volatile Dummy dummy(1);
//        dummy.i_ = 2;
//    }
}

int main()
{
    typedef boost::shared_ptr<boost::thread> pThread;

    pThread my_thread_;

    for( int j = 0; j < 1000; ++j ) {
        my_thread_ = pThread( new boost::thread(&threaded_func1) );
        my_thread_->join();
    }

//    for( int j = 0; j < 1000; ++j )
//        threaded_func1(); //This is the shittiest thing I've encountered lately.
//        //The memory growth have nothing to do with threads. shared_ptr's done it all.

    Logger::i().buf(" Main Program ends.").endl();

    return 0;
}
