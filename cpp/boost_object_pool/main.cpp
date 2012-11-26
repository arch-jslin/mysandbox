
#include <iostream>
#include <sstream>
//#include <tr1/memory>
#include <tr1/functional>
#include <tr1/tuple>
#include <utility>
#include <list>
#include <cstdlib>

#include <boost/shared_ptr.hpp>
#include <boost/weak_ptr.hpp>
#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition.hpp>
#include <boost/thread/tss.hpp>
#include <boost/pool/object_pool.hpp>
#include <boost/foreach.hpp>

#include "Logger.hpp"
#include "ObjectPool.hpp"

using namespace std;
using namespace tr1;
using boost::shared_ptr;
using boost::weak_ptr;

namespace view {
    class A{};
    typedef shared_ptr<A> pA;
    typedef weak_ptr<A>  wpA;
}

class B{};
class C{};
enum ENUM{D};

typedef function<void(view::pA&, int, int)>         CB;
typedef tuple<CB const*, B const*, ENUM, view::wpA> Event;
typedef list<Event>                                 Listener;

void push_tuple(CB const* cb, view::wpA const& pa, B const* b, ENUM const& e)
{
    Listener listener;
    listener.push_back( make_tuple(cb,b,e,pa) );
}

typedef shared_ptr<char> pchar;
typedef weak_ptr<char> wpchar;
using namespace psc;
using namespace utils;

struct Dummy {
    Dummy(int i):i_(i){}
    ~Dummy() {
        //Logger::i().buf(" Dummy ").buf(this).buf(" is killed.").endl();
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

boost::mutex io_mutex;

struct Utils{
    static void clone_a_lot_of_times(pData orig) {
        volatile Data* big_array[100];
        //Data bigarray[1000];
        //Logger::i().endl();
        //Logger::i().buf(" ----------- Start of massive allocation ----------- ").endl();
        for( volatile int i = 0; i < 100; ++i ) {
            //pData clone = pData(new Data(i, orig->pch));
            //pData clone = Data::create(i);
            big_array[i] = new Data(i, pDummy(new Dummy(1)));
            //bigarray[i].dd[5] = (double)i;
        }
        for( volatile int i = 0; i < 100; ++i ) {
            delete big_array[i];
            //Data d(i);
            //d.dd[3] = 3.0;
        }
        //Logger::i().endl();
        //Logger::i().buf(" ----------- End of massive allocation ----------- ").endl();
        //delete [] big_array;
    }
};

class ThreadedClass {
public:
    typedef boost::mutex::scoped_lock lock;
    void go(vector<pData> const& data, int mult) {
        //Logger::i().buf("thread ").buf(mult).buf(" before_data_assignment_and_clearance").endl();
        data_ = data;
        //Logger::i().buf("thread ").buf(mult).buf(" after_data_assignment_and_clearance").endl();
        //Logger::i().buf("thread ").buf(mult).buf(" says i am alive.").endl();

        //Logger::i().buf(" thread yell ").buf(mult).endl();
        for( int i = 0; i < 1000; ++i ) {
            lock l(mutex_);
            //Logger::i().buf(" thread ").buf(mult).buf(" before creating new clone.").endl();

            data_.push_back(Data::create( i*mult, pDummy(new Dummy(1))));
            Utils::clone_a_lot_of_times(data_.back());

            //Logger::i().buf(" thread ").buf(mult).buf(" after creating new clone.").endl();

            boost::thread::yield();
            //if( i%30 == 0 )
                //Logger::i().buf("thread ").buf(mult).buf(" pushing(").buf(i*mult).buf(")").endl();
        }
    }
    pData fetch(unsigned int i) {
        lock l(mutex_);
        if( !data_.empty() && i < data_.size() )
            return data_[i];
        else
            return pData();
    }
    void pop() {
        lock l(mutex_);
        if( !data_.empty() )
            data_.erase( data_.begin() );
    }

private:
    friend class Utils;
    boost::mutex mutex_;
    vector<pData> data_;
};

class Runner {
    typedef shared_ptr< boost::thread > pThread;
    typedef boost::mutex::scoped_lock lock;
public:
    Runner():pd1(new Dummy(1)), pd2(new Dummy(2)), pd3(new Dummy(3)) {}

    void run_threads()
    {
        vector<pData> orig_data;
        for( int i=0; i<10; ++i )
            orig_data.push_back(pData(new Data(-1, pd1) ));

        vector<pData> copied_data1, copied_data2, copied_data3;
        BOOST_FOREACH(pData& i, orig_data) {
            copied_data1.push_back( Data::create(i->d, pDummy(new Dummy(1))) ) ;
            copied_data2.push_back( Data::create(i->d*2, pDummy(new Dummy(2))) ) ;
            copied_data3.push_back( Data::create(i->d*3, pDummy(new Dummy(3))) ) ;
        }

        thrd1 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc1, copied_data1, 1) ) );
        thrd2 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc2, copied_data2, 2) ) );
        thrd3 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc3, copied_data3, 3) ) );
    }

    void probe_and_pop(int i) {
        pData a, b, c;
        //Logger::i().buf("   fetching ...").endl();
        a = tc1.fetch(0); b = tc2.fetch(0); c = tc3.fetch(0);
        //if( i%50 == 0 ) {
            Logger::i().buf("main thread fetch from thread1: ").buf(a?a->d:-1).endl()
                       .buf("main thread fetch from thread2: ").buf(b?b->d:-1).endl()
                       .buf("main thread fetch from thread3: ").buf(c?c->d:-1).endl();
        //}
        //Logger::i().buf("   popping ...").endl();
        tc1.pop(); tc2.pop(); tc3.pop();
        //Logger::i().buf("  end of probing and popping").endl();
    }

    void join_all() {
        //Logger::i().buf(" call join all").endl();
        thrd1->join();
        thrd2->join();
        thrd3->join();
    }

private:
    pThread thrd1, thrd2, thrd3;
    ThreadedClass tc1, tc2, tc3;
    pDummy pd1, pd2, pd3;
};

void print_log()
{
    for( int i = 0 ; i < 10 ; ++i )
        Logger::i().buf("HI i am in the thread.").endl();
}

int main()
{
    Runner r;

    for( int j = 0; j < 1; ++j ) {
        r.run_threads();
        for( int i = 0; i < 2; ++i )
            r.probe_and_pop(i);
        r.join_all();
    }

    return 0;
}
