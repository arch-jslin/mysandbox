
#include <iostream>
#include <memory>
#include <functional>
#include <tuple>
#include <utility>
#include <list>
#include <cstdlib>
#include <deque>
#include <algorithm>

#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition.hpp>
#include <boost/thread/tss.hpp>
#include <boost/pool/object_pool.hpp>
#include <boost/foreach.hpp>

#include "ObjectPool.hpp"

using namespace std;

template <class T>
int func(T t) {
    cout << 0 << endl;
    return 0;
}

template <class T, class ...Args>
int func(T t, Args... args) {
    int i = sizeof...(Args);
    std::cout << i;
    return i + func(args...);
}

template<int N, int Last1 = 1, int Last2 = 0>
struct fib{ enum{ value = fib<N-1, Last1+Last2, Last1>::value };
};

template<int Last1, int Last2>
struct fib<1, Last1, Last2> { enum{ value = Last1 }; };

int moveint(int&& i)
{
    cout << i << endl;
    return i;
}

namespace view {
    class A{};
    typedef std::shared_ptr<A> pA;
    typedef std::weak_ptr<A>  wpA;
}

class B{};
class C{};
enum ENUM{D};

typedef std::function<void(view::pA&, int, int)>         CB;
typedef std::tuple<CB const*, B const*, ENUM, view::wpA> Event;
typedef std::list<Event>                                 Listener;

void push_tuple(CB const* cb, view::wpA const& pa, B const* b, ENUM const& e)
{
    Listener listener;
    listener.push_back( make_tuple(cb,b,e,pa) );
}

using std::bind;

typedef std::shared_ptr<char> pchar;
typedef std::weak_ptr<char> wpchar;
using namespace psc;
using namespace utils;

struct Data {
    typedef std::shared_ptr<Data> pointer_type;
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

typedef Data::pointer_type pint;

boost::mutex io_mutex;

struct Utils{
    static void clone_a_lot_of_times(pint orig) {
        for( volatile int i = 0; i < 10000; ++i ) {
            //pint clone = pint(new Data(i, orig->pch));
            pint clone = Data::create(i, pchar(new char('*')));
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
            oss_.reset(new std::ostringstream);
        *oss_ << in;
        return *this;
    }

    template<typename T>
    Logger& buf(T const* in) {
        if( oss_.get() == 0 )
            oss_.reset(new std::ostringstream);
        *oss_ << in;
        return *this;
    }

    Logger& endl() {
        if( oss_.get() == 0 )
            oss_.reset(new std::ostringstream);
        scoped_lock l(io_mutex_);
        std::cout << oss_->str() << std::endl;
        oss_->str("");
        return *this;
    }

    Logger& out() {
        if( oss_.get() == 0 )
            oss_.reset(new std::ostringstream);
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
    void go(std::vector<pint> const& data, int mult) {
        Logger::i().buf("thread ").buf(mult).buf(" before_data_assignment_and_clearance").endl();
        data_ = data;
        Logger::i().buf("thread ").buf(mult).buf(" after_data_assignment_and_clearance").endl();
        Logger::i().buf("thread ").buf(mult).buf(" says i am alive.").endl();

        Logger::i().buf(" thread yell ").buf(mult).endl();
        for( int i = 0; i < 100; ++i ) {
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
    pint fetch(int i) {
        lock l(mutex_);
        if( !data_.empty() && i < data_.size() )
            return data_[i];
        else
            return pint();
    }
    void pop() {
        lock l(mutex_);
        if( !data_.empty() )
            data_.erase( data_.begin() );
    }

private:
    friend class Utils;
    boost::mutex mutex_;
    std::vector<pint> data_;
};

class Runner {
    typedef std::shared_ptr< boost::thread > pThread;
    typedef boost::mutex::scoped_lock lock;
public:
    Runner():pch1(new char('a')), pch2(new char('b')), pch3(new char('c')) {}

    void run_threads()
    {
        std::vector<pint> orig_data;
        for( int i=0; i<10; ++i )
            orig_data.push_back(pint(new Data(-1, pch1) ));

        std::vector<pint> copied_data1, copied_data2, copied_data3;
        BOOST_FOREACH(pint& i, orig_data) {
            copied_data1.push_back( Data::create(i->d, pchar(new char('a'))) ) ;
            copied_data2.push_back( Data::create(i->d*2, pchar(new char('b'))) ) ;
            copied_data3.push_back( Data::create(i->d*3, pchar(new char('c'))) ) ;
        }

        thrd1 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc1, copied_data1, 1) ) );
        thrd2 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc2, copied_data2, 2) ) );
        thrd3 = pThread( new boost::thread( bind(&ThreadedClass::go, &tc3, copied_data3, 3) ) );
    }

    void probe_and_pop(int i) {
        pint a, b, c;
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
    CB cb; B b; view::pA pa(new view::A);
    push_tuple(&cb, pa, &b, D);

    cout << pa << endl;

    cout << fib<11>::value << endl;
    cout << func(1,'2',"3",4.f) << endl;

    std::shared_ptr<int> i(new int(1)), j;
    j = i;
    std::cout << (j == i) << "\n";

    Runner r;
    Logger::i().buf("Hi. This is ").buf(j).endl();
    Logger::i().buf("Hi. This is ").buf(i).endl();

    for( int j = 0; j < 5; ++j ) {
        r.run_threads();
        for( int i = 0; i < 100; ++i )
            r.probe_and_pop(i);
        r.join_all();
    }

    std::deque<int> idq{10, 3, 5};

    std::sort(idq.begin(), idq.end());

    while( !idq.empty() ) {
        std::cout << idq.front() << " ";
        idq.pop_front();
    }
    std::cout << std::endl;

    return 0;
}
