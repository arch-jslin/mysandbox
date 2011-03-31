
#include <iostream>
#include <sstream>
#include <tr1/memory>
#include <tr1/functional>
#include <tr1/tuple>
#include <utility>
#include <list>
#include <cstdlib>

#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition.hpp>
#include <boost/thread/tss.hpp>
#include <boost/pool/object_pool.hpp>
#include <boost/foreach.hpp>

#include "ObjectPool.hpp"

using namespace std;
using namespace tr1;

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

struct Data {
    typedef shared_ptr<Data> pointer_type;
    static pointer_type create(int i, pchar p) {
        return ObjectPool<Data>::create(i, p);
    }
    static pointer_type create(int i) {
        return ObjectPool<Data>::create(i);
    }

    Data(int i, pchar p):d(i), pch(p){}
    Data(int i):d(i){}

    int d;
    pchar pch;
};

typedef Data::pointer_type pData;

boost::mutex io_mutex;

struct Utils{
    static void clone_a_lot_of_times(pData orig) {
        for( volatile int i = 0; i < 10000; ++i ) {
            //pData clone = pData(new Data(i, orig->pch));
            pData clone = Data::create(i, pchar(new char('*')));
        }
    }
};

class Logger {
    typedef boost::thread_specific_ptr< std::ostringstream > pOSS;
    typedef boost::mutex::scoped_lock scoped_lock;

public:
    static Logger& i() {
        static Logger singleton;
        return singleton;
    }

    template<typename T>
    Logger& buf(T const& in) {
        if( oss_.get() == 0 )
            oss_.reset(new ostringstream);
        *oss_ << in;
        return *this;
    }

    template<typename T>
    Logger& buf(T const* in) {
        if( oss_.get() == 0 )
            oss_.reset(new ostringstream);
        *oss_ << in;
        return *this;
    }

    Logger& endl() {
        if( oss_.get() == 0 )
            oss_.reset(new ostringstream);
        scoped_lock l(io_mutex_);
        std::cout << oss_->str() << std::endl;
        oss_->str("");
        return *this;
    }

    Logger& out() {
        if( oss_.get() == 0 )
            oss_.reset(new ostringstream);
        scoped_lock l(io_mutex_);
        std::cout << oss_->str();
        oss_->str("");
        return *this;
    }

private:
    Logger(){}
    Logger(Logger const&);
    static boost::mutex io_mutex_;
    pOSS oss_;
};

boost::mutex Logger::io_mutex_;

class ThreadedClass {
public:
    typedef boost::mutex::scoped_lock lock;
    void go(vector<pData> const& data, int mult) {
        Logger::i().buf("thread ").buf(mult).buf(" before_data_assignment_and_clearance").endl();
        data_ = data;
        Logger::i().buf("thread ").buf(mult).buf(" after_data_assignment_and_clearance").endl();
        Logger::i().buf("thread ").buf(mult).buf(" says i am alive.").endl();

        Logger::i().buf(" thread yell ").buf(mult).endl();
        for( int i = 0; i < 10; ++i ) {
            lock l(mutex_);
            Logger::i().buf(" thread ").buf(mult).buf(" before creating new clone.").endl();

            data_.push_back(Data::create( i*mult, pchar(new char('*'))));
            Utils::clone_a_lot_of_times(data_.back());

            Logger::i().buf(" thread ").buf(mult).buf(" after creating new clone.").endl();

            boost::thread::yield();
            if( i%30 == 0 )
                Logger::i().buf("thread ").buf(mult).buf(" pushing(").buf(i*mult).buf(")").endl();
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
    Runner():pch1(new char('a')), pch2(new char('b')), pch3(new char('c')) {}

    void run_threads()
    {
        vector<pData> orig_data;
        for( int i=0; i<10; ++i )
            orig_data.push_back(pData(new Data(-1, pch1) ));

        vector<pData> copied_data1, copied_data2, copied_data3;
        BOOST_FOREACH(pData& i, orig_data) {
            copied_data1.push_back( Data::create(i->d, pchar(new char('a'))) ) ;
            copied_data2.push_back( Data::create(i->d*2, pchar(new char('b'))) ) ;
            copied_data3.push_back( Data::create(i->d*3, pchar(new char('c'))) ) ;
        }

        thrd1 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc1, copied_data1, 1) ) );
        thrd2 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc2, copied_data2, 2) ) );
        thrd3 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc3, copied_data3, 3) ) );
    }

    void probe_and_pop(int i) {
        pData a, b, c;
        Logger::i().buf("   fetching ...").endl();
        a = tc1.fetch(0); b = tc2.fetch(0); c = tc3.fetch(0);
        if( i%30 == 0 ) {
            Logger::i().buf("main thread fetch from thread1: ").buf(a?a->d:-1).endl()
                       .buf("main thread fetch from thread2: ").buf(b?b->d:-1).endl()
                       .buf("main thread fetch from thread3: ").buf(c?c->d:-1).endl();
        }
        Logger::i().buf("   popping ...").endl();
        tc1.pop(); tc2.pop(); tc3.pop();
        Logger::i().buf("  end of probing and popping").endl();
    }

    void join_all() {
        Logger::i().buf(" call join all").endl();
        thrd1->join();
        thrd2->join();
        thrd3->join();
    }

private:
    pThread thrd1, thrd2, thrd3;
    ThreadedClass tc1, tc2, tc3;
    pchar pch1, pch2, pch3;
};

void print_log()
{
    for( int i = 0 ; i < 10 ; ++i )
        Logger::i().buf("HI i am in the thread.").endl();
}

int main()
{
    Runner r;

    for( int j = 0; j < 5; ++j ) {
        r.run_threads();
        for( int i = 0; i < 10000; ++i )
            r.probe_and_pop(i);
        r.join_all();
    }

    return 0;
}
