#include <cstdio>
#include <cstdlib>
#include <boost/tr1/random.hpp>
#include <ctime>

int main()
{
    //this program will prove that I only need to sync this ultimate seed to get deterministic outputs,
    //provided different random generator with the same engine, range, and the same seed.
    std::time_t ULTIMATE_SEED = std::time(0)^std::clock();

    std::tr1::variate_generator<std::tr1::mt19937, std::tr1::uniform_int<> >
        rgen1(std::tr1::mt19937(ULTIMATE_SEED), std::tr1::uniform_int<>(0, 10));

    for (int i=0; i<10; ++i) {
        printf("%d ", rgen1());
    }
    printf("\n");

    printf("ok lets be busy for a sec...\n");
    for (volatile int j=0; j < 300000000; ++j);

    std::tr1::variate_generator<std::tr1::mt19937, std::tr1::uniform_int<> >
        rgen2(std::tr1::mt19937(ULTIMATE_SEED), std::tr1::uniform_int<>(0, 10));

    for (int i=0; i<10; ++i) {
        printf("%d ", rgen2());
        if( i == 3 || i == 6 ) {
            for (volatile int j=0; j < 150000000; ++j); //pretend to be busy
        }
    }
    printf("\n");

    system("pause");
    return 0;
}

