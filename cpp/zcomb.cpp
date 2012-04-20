
#include <iostream>
#include <functional>
#include <cmath>

struct InnerLayer;
struct ActualFun;
struct Untype;

struct InnerLayer{
    Untype* x_;
    InnerLayer(Untype* x) : x_(x){}
    int operator()(int n);
};

struct Factorial{ //the actual would-be recursive program
    InnerLayer in_;
    Factorial(InnerLayer in) : in_(in){}
    int operator()(int n) {
        if( n == 0 ) return 1;
        return n*in_(n-1);
    }
};

struct Untype{
    Factorial operator()(Untype xprime) {
        return Factorial(InnerLayer(&xprime));
    }
};

int InnerLayer::operator()(int n) {
    return (*x_)(*x_)(n);
}

int factorialB(int);

int factorialA(int n) {
    if( n == 0 ) return 1;
    return n*factorialB(n-1);
}

int factorialB(int n) {
    if( n == 0 ) return 1;
    return n*factorialA(n-1);
}

#define F std::function

template <typename R, typename... Args>
struct Untyped {
    Untyped( F< F<R(Args...)>(Untyped<R, Args...>) > lamb )
        :lamb_(lamb){}

    F<R(Args...)> operator()(Untyped<R, Args...> xprime) const {
        return lamb_(xprime);
    }

    F< F<R(Args...)>(Untyped<R, Args...>) > lamb_;
};

template <typename R, typename... Args>
F<R(Args...)> Z(F< F<R(Args...)> (F<R(Args...)>) > f) {
    Untyped<R, Args...> temp(
        [f](Untyped<R, Args...> x) -> F<R(Args...)> {
            return f(
                [x](Args... args) -> R {
                    return x(x)(args...);
                }
            );
        });
    return temp(temp);
}

template <typename R, typename... Args>
struct Z1 {
    typedef std::function< R(Args...) >     func_t;
    typedef std::function< func_t(func_t) > xfunc_t;

    struct RecFun {
        typedef std::function< func_t(RecFun) > rec_func_t;
        RecFun( rec_func_t f ) :f_(f){}
        func_t operator()(RecFun xprime) const {
            return f_(xprime);
        }
        rec_func_t f_;
    };

    static func_t Fix(xfunc_t f) {
        RecFun rf( [f](RecFun x) -> func_t {
            return f( [x](Args... args) -> R {
                return x(x)(args...);
            });
        });
        return rf(rf);
    }
};

template <typename Lambda>
struct infer {
    //forcing to know the return function type, hence the real recursive function
    typedef typename infer<decltype(&Lambda::operator())>::fp fp;
};

//not used?
template <typename R, typename Lambda, typename... Args>
struct infer< F<R(Args...)> (Lambda::*)( F<R(Args...)> ) > {
    typedef Z1<R, Args...> fp;
};

//literal lambda objects adapter
template <typename R, typename Lambda, typename... Args>
struct infer< F<R(Args...)> (Lambda::*)( F<R(Args...)> ) const > {
    typedef Z1<R, Args...> fp;
};

//literal function adapter
template <typename R, typename... Args>
struct infer< F<R(Args...)> (*)( F<R(Args...)> ) > {
    typedef Z1<R, Args...> fp;
};

template <typename Lambda>
auto Z2(Lambda f) -> typename infer<Lambda>::fp::func_t {
    return infer<Lambda>::fp::Fix(f);
}

auto almost_fac2(F<int(int)> f) -> F<int(int)> {
    return [f](int n) -> int {
        if( n == 0 ) return 1;
        return n*f(n-1);
    };
}

int main()
{
    auto almost_factorial =
    //F< F<int(int)>(F<int(int)>) > almost_factorial =
        [](F<int(int)> f) -> F<int(int)> {
            return [f](int n) -> int {
                if( n == 0 ) return 1;
                return n*f(n-1);
            };
        };

    std::cout << Z2(almost_fac2)(10) << std::endl;

    F< F<int(int)> (F<int(int)>) > almost_fibonacci =
        [](F<int(int)> f) -> F<int(int)> {
            return [f](int n) -> int {
                if( n == 0 ) return 0;
                else if( n == 1 ) return 1;
                else return f(n-1) + f(n-2);
            };
        };

    std::cout << Z(almost_fibonacci)(10) << std::endl;

    F< F<int(int, int)> (F<int(int, int)>) > almost_ackermann =
        [](F<int(int, int)> f) -> F<int(int, int)> {
            return [f](int m, int n) -> int {
                if( m == 0 ) return n+1;
                else if( m > 0 && n == 0 ) return f(m-1, 1);
                else if( m > 0 && n > 0 )  return f(m-1, f(m, n-1));
            };
        };

    //beware of the growth rate of ackermann function for m >= 4 !
    std::cout << Z(almost_ackermann)(3, 3) << std::endl;

    std::cout << Untype()(Untype())(10) << std::endl;
    //std::cout << Factorial(InnerLayer(&Untype()))(12) << std::endl;
    std::cout << factorialA(10) << std::endl;

    return 0;
}
