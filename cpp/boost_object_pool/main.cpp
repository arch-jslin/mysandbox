
#include <iostream>
#include <sstream>
#include <tr1/memory>
#include <tr1/functional>
#include <tr1/tuple>
#include <utility>
#include <list>
#include <cstdlib>

//#include <boost/shared_ptr.hpp>
//#include <boost/weak_ptr.hpp>
//#include <boost/tr1/memory.hpp>
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

struct Data {
    typedef shared_ptr<Data> pointer_type;
    Data(int i):d(i){}
    Data():d(0){}
    ~Data(){}

    int d;
    double dd[10];
};

typedef Data::pointer_type pData;

boost::mutex io_mutex;

struct Utils{
    static void clone_a_lot_of_times(pData orig) {
        Data* big_array[2000];
        for( volatile int i = 0; i < 2000; ++i ) {
            big_array[i] = pData(new Data(i));
        }
        for( int i = 0; i < 2000; ++i ) {
            delete big_array[i];
        }
    }
};

class ThreadedClass {
public:
    typedef boost::mutex::scoped_lock lock;
    void go(vector<pData> const& data, int mult) {
        data_ = data;
        for( int i = 0; i < 1000; ++i ) {
            lock l(mutex_);
            data_.push_back(Data::create( i*mult, pDummy(new Dummy(1))));
            Utils::clone_a_lot_of_times(data_.back());
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
        a = tc1.fetch(0); b = tc2.fetch(0); c = tc3.fetch(0);
        tc1.pop(); tc2.pop(); tc3.pop();
    }

    void join_all() {
        thrd1->join();
        thrd2->join();
        thrd3->join();
    }

private:
    pThread thrd1, thrd2, thrd3;
    ThreadedClass tc1, tc2, tc3;
    pDummy pd1, pd2, pd3;
};

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
