#include <iostream>
#include <cstdlib>

class PRNG {
    mutable unsigned long seed;
    static const unsigned long max = 0xffffffff;

    unsigned long rand_() const {
        seed = (seed * 314159269 + 1) & max;
        return seed;
    }

    public:
    PRNG(unsigned long s=0) : seed(s) {}

    double rand() const {
        return rand_() / static_cast<double>(max);
    }

    friend std::ostream& operator<<(std::ostream &os, PRNG const &p) {
        return os << p.seed;
    }

    friend std::istream& operator>>(std::istream &is, PRNG &p) {
        return is >> p.seed;
    }
};

#include <ctime>

int main() {

    PRNG p(time(NULL));
    int test[50] = {0};

    for (int i=0; i<1000; ++i) {
        test[static_cast<int>(p.rand()*50)] += 1;
    }

    for (int i=0; i < 50; ++i ) {
        std::cout << "occurence of " << i << " : " << test[i] << std::endl;
    }

    system("pause");
    return 0;
}

