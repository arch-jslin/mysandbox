#include <cstdio>
#include <cstdlib>
#include <boost/tr1/random.hpp>
#include <ctime>

int main()
{
    //this program will prove that I only need to sync this ultimate seed to get deterministic outputs,
    //provided different random generator with the same engine, and the same seed.
    //the problem would be, how can I rollback?
    //or, I have to actually use one generator that I need to rollback (for model/state only)
    //and, one that I don't need the feature (for views and other non-game-states)
    std::time_t ULTIMATE_SEED = std::time(0)^std::clock();

    std::tr1::variate_generator<std::tr1::mt19937, std::tr1::uniform_int<> >
        rgen1(std::tr1::mt19937(ULTIMATE_SEED), std::tr1::uniform_int<>(0, 10));

    for (int i=0; i<10; ++i) {
        if( i == 5 ) {
            rgen1.distribution() = std::tr1::uniform_int<>(0, 50);
        } else {
            rgen1.distribution() = std::tr1::uniform_int<>(0, 10);
        }
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

