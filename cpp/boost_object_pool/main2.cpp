
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
        //you can verify this is called. everything "inside of" this object should be released
        //correctly no matter what.
        //The only thing is..  when using shared_ptr, there're other things eating up memory.
    }
    int i_;
};
typedef shared_ptr<Dummy> pDummy;

void threaded_func1() {
    for( int i = 0; i < 1000; ++i ) {
        pDummy dummy = pDummy(new Dummy(1)); //although dummy's life cycle is so short
        //it won't give back the memory of some mysterious things... it's not new Dummy(1)'s memory.
    }
//    for( int i = 0; i < 1000; ++i ) {
//        volatile Dummy* dummy = new Dummy(1);
//        dummy->i_[0] = 2; //anyway make sure it's not optimized by compiler.
//        delete dummy;     //and you'll find out all is released here correctly. (no mem growth)
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
