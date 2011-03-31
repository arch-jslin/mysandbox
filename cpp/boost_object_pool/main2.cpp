
#include <iostream>
#include <tr1/memory>
#include <cstdlib>
//#include <boost/tr1/memory.hpp>

using namespace std;

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
    for( int j = 0; j < 100000; ++j )
        func1();

    return 0;
}
