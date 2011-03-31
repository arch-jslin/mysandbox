
#include <iostream>
#include <tr1/memory>
#include <tr1/functional>

//#include <boost/tr1/memory.hpp>
#include <boost/thread/thread.hpp>

using namespace std;

struct Data {
    typedef tr1::shared_ptr<Data> pointer_type;
    Data(int i):d(i){}
    Data():d(0){}
    ~Data(){}

    int d;
    double dd;
};

typedef Data::pointer_type pData;

struct Utils{
    static void clone_a_lot_of_times(pData orig) {
        for( volatile int i = 0; i < 2000; ++i ) {
            pData data = pData(new Data(i));
            data->dd = orig->d + data->d;
        }
    }
};

class ThreadedClass {
public:
    void go() {
        data_ = pData(new Data(1));
        for( int i = 0; i < 1000; ++i ) {
            Utils::clone_a_lot_of_times(data_);
        }
    }

private:
    friend class Utils;
    pData data_;
};

class Runner {
    typedef tr1::shared_ptr< boost::thread > pThread;
public:
    Runner(){}

    void run_threads() {
        thrd1 = pThread( new boost::thread( tr1::bind(&ThreadedClass::go, &tc1) ) );
        thrd2 = pThread( new boost::thread( tr1::bind(&ThreadedClass::go, &tc2) ) );
        thrd3 = pThread( new boost::thread( tr1::bind(&ThreadedClass::go, &tc3) ) );
    }

    void join_all() {
        thrd1->join();
        thrd2->join();
        thrd3->join();
    }

private:
    pThread thrd1, thrd2, thrd3;
    ThreadedClass tc1, tc2, tc3;
};

struct Dummy {
    Dummy(int i) { i_ = i; }
    ~Dummy() {}
    int i_;
};
typedef tr1::shared_ptr<Dummy> pDummy;

void func1() {
    for( int i = 0; i < 100000; ++i ) {
        pDummy dummy = pDummy(new Dummy(1));
    }
}

int main()
{
    //First part: This shows excessive memory usage when using tr1/memory's shared_ptr
    for( int j = 0; j < 100000; ++j )
        func1();

    //Second part: This shows when shared_ptr caused an excessive memory usage in a multi-threaded
    //             environment, an unhandled exception will be thrown.
    //            (exception Breakpoint on Windows7-64 bit using MinGW gcc 4.5.2-tdm1 32-bit)
    //            (Comment above code and uncomment the code below to run.)
//    Runner r;
//    for( int j = 0; j < 5; ++j ) {
//        r.run_threads();
//        r.join_all();
//    }

    return 0;
}
