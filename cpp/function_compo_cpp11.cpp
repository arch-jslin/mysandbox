
// How to overload an operator for composition of functionals in C++0x
// By: a guest on Apr 7th, 2012  |  syntax: None  |  size: 9.85 KB  |  hits: 14  |  expires: Never
// download  |  raw  |  embed  |  report abuse

    #include <iostream>
    #include <functional>
     
    using namespace std;
     
    // An example of a quick and dirty function composition.
    // Note that instead of 'std::function' this operator should accept
    // any functional/callable type (just like 'bind').
    template<typename R1, typename R2, typename... ArgTypes1>
    function<R2(ArgTypes1...)> operator >> (
                    const function<R1(ArgTypes1...)>& f1,
                    const function<R2(R1)>& f2) {
        return [=](ArgTypes1... args){ return f2(f1(args...)); };
    }
     
    int main(int argc, char **args) {
        auto l1 = [](int i, int j) {return i + j;};
        auto l2 = [](int i) {return i * i;};
     
        function<int(int, int)> f1 = l1;
        function<int(int)> f2 = l2;
     
        cout << "Function composition: " << (f1 >> f2)(3, 5) << endl;
     
        // The following is desired, but it doesn't compile as it is:
        cout << "Function composition: " << (l1 >> l2)(3, 5) << endl;
     
        return 0;
    }
           
    // https://ideone.com/MS2E3
     
    #include <iostream>
    #include <functional>
     
    namespace detail
    {
        template <typename R, typename... Args>
        class composed_function;
     
        // utility stuff
        template <typename... Args>
        struct variadic_typedef;
     
        template <typename Func>
        struct callable_type_info :
            callable_type_info<decltype(&Func::operator())>
        {};
     
        template <typename Func>
        struct callable_type_info<Func*> :
            callable_type_info<Func>
        {};
     
        template <typename DeducedR, typename... DeducedArgs>
        struct callable_type_info<DeducedR(DeducedArgs...)>
        {
            typedef DeducedR return_type;
            typedef variadic_typedef<DeducedArgs...> args_type;
        };
     
        template <typename O, typename DeducedR, typename... DeducedArgs>
        struct callable_type_info<DeducedR (O::*)(DeducedArgs...) const>
        {
            typedef DeducedR return_type;
            typedef variadic_typedef<DeducedArgs...> args_type;
        };
     
        template <typename DeducedR, typename... DeducedArgs>
        struct callable_type_info<std::function<DeducedR(DeducedArgs...)>>
        {
            typedef DeducedR return_type;
            typedef variadic_typedef<DeducedArgs...> args_type;
        };
     
        template <typename Func>
        struct return_type
        {
            typedef typename callable_type_info<Func>::return_type type;
        };
     
        template <typename Func>
        struct args_type
        {
            typedef typename callable_type_info<Func>::args_type type;
        };
     
        template <typename FuncR, typename... FuncArgs>
        struct composed_function_type
        {
            typedef composed_function<FuncR, FuncArgs...> type;
        };
     
        template <typename FuncR, typename... FuncArgs>
        struct composed_function_type<FuncR, variadic_typedef<FuncArgs...>> :
            composed_function_type<FuncR, FuncArgs...>
        {};
     
        template <typename R, typename... Args>
        class composed_function
        {
        public:
            composed_function(std::function<R(Args...)> func) :
            mFunction(std::move(func))
            {}
     
            template <typename... CallArgs>
            R operator()(CallArgs&&... args)
            {
                return mFunction(std::forward<CallArgs>(args)...);
            }
     
            template <typename Func>
            typename composed_function_type<
                        typename return_type<Func>::type, Args...>::type
                 operator>>(Func func) /* && */ // rvalues only (unsupported for now)
            {
                std::function<R(Args...)> thisFunc = std::move(mFunction);
     
                return typename composed_function_type<
                                    typename return_type<Func>::type, Args...>::type(
                                            [=](Args... args)
                                            {
                                                return func(thisFunc(args...));
                                            });
            }
     
        private:    
            std::function<R(Args...)> mFunction;
        };
    }
     
    template <typename Func>
    typename detail::composed_function_type<
                typename detail::return_type<Func>::type,
                    typename detail::args_type<Func>::type>::type
        compose(Func func)
    {
        return typename detail::composed_function_type<
                            typename detail::return_type<Func>::type,
                                typename detail::args_type<Func>::type>::type(func);
    }
     
    int main()
    {
        using namespace std;
     
        auto l1 = [](int i, int j) {return i + j;};
        auto l2 = [](int i) {return i * i;};
     
        std:function<int(int, int)> f1 = l1;
        function<int(int)> f2 = l2;
     
        cout << "Function composition: " << (compose(f1) >> f2)(3, 5) << endl;
        cout << "Function composition: " << (compose(l1) >> l2)(3, 5) << endl;
        cout << "Function composition: " << (compose(f1) >> l2)(3, 5) << endl;
        cout << "Function composition: " << (compose(l1) >> f2)(3, 5) << endl;
     
        return 0;
           
    #include <iostream>
     
    template <class LAMBDA, class ARG>
    auto apply(LAMBDA&& l, ARG&& arg) -> decltype(l(arg))
    {
      return l(arg);
    }
     
    template <class LAMBDA1, class LAMBDA2>
    class compose_class
    {
    public:
      LAMBDA1 l1;
      LAMBDA2 l2;
     
      template <class ARG>
      auto operator()(ARG&& arg) ->
        decltype(apply(l2, apply(l1, std::forward<ARG>(arg))))
      { return apply(l2, apply(l1, std::forward<ARG>(arg))); }
     
      compose_class(LAMBDA1&& l1, LAMBDA2&& l2)
        : l1(std::forward<LAMBDA1>(l1)), l2(std::forward<LAMBDA2>(l2)) {}
    };
     
    template <class LAMBDA1, class LAMBDA2>
    auto operator>>(LAMBDA1&& l1, LAMBDA2&& l2) -> compose_class<LAMBDA1, LAMBDA2>
    {
      return compose_class<LAMBDA1, LAMBDA2>
        (std::forward<LAMBDA1>(l1), std::forward<LAMBDA2>(l2));
    }
     
    int main()
    {    
      auto l1 = [](int i) { return i + 2; };
      auto l2 = [](int i) { return i * i; };
     
      std::cout << (l1 >> l2)(3) << std::endl;
    }
           
    class compose_syntax_helper_middle
    {
    } o;
     
    template <typename Func>
    typename detail::composed_function_type<
    typename detail::return_type<Func>::type,
        typename detail::args_type<Func>::type>::type
        operator<< (Func func, compose_syntax_helper_middle)
    {
        return typename detail::composed_function_type<
            typename detail::return_type<Func>::type,
                     typename detail::args_type<Func>::type>::type(func);
    }
           
    (func1 <<o>> func2) (arg1, arg2)
           
    #include <cstdio>
    #include <functional>
     
    template <typename F, typename F_ret, typename... F_args,
              typename G, typename G_ret, typename... G_args>
    std::function<G_ret (F_args...)>
         composer(F f, F_ret (F::*)(F_args...) const ,
                  G g, G_ret (G::*)(G_args...) const)
    {
      // Cannot create and return a lambda. So using std::function as a lambda holder.
      std::function<G_ret (F_args...)> holder;
      holder = [f, g](F_args... args) { return g(f(args...)); };
      return holder;
    }
     
    template<typename F, typename G>
    auto operator >> (F f, G g)
      -> decltype(composer(f, &F::operator(), g, &G::operator()))
    {
      return composer(f, &F::operator(), g, &G::operator());
    }
     
    int main(void)
    {
      auto l1 = [](int i , int j) { return i + j; };
      auto l2 = [](int a) { return a*a; };
     
      printf("%dn", (l1 >> l2 >> l2)(2, 3)); // prints 625
     
      return 0;
    }
           
    #include <cstdio>
    #include <functional>
     
    template <typename F, typename F_ret, typename... F_args,
              typename G, typename G_ret, typename... G_args>
    std::function<G_ret (F_args...)>
         composer(F f, F_ret (F::*)(F_args...) const ,
                  G g, G_ret (G::*)(G_args...) const)
    {
      // Cannot create and return a lambda. So using std::function as a lambda holder.
      std::function<G_ret (F_args...)> holder;
      holder = [f, g](F_args... args) { return g(f(args...)); };  
      return holder;
    }
     
    template<typename F_ret, typename... F_args>
    std::function<F_ret (F_args...)>
    make_function (F_ret (*f)(F_args...))
    {
      // Not sure why this helper isn't available out of the box.
      return f;
    }
     
    template<typename F, typename F_ret, typename... F_args>
    std::function<F_ret (F_args...)>
    make_function (F_ret (F::*func)(F_args...), F & obj)
    {
      // Composing a member function pointer and an object.  
      // This one is probably doable without using a lambda.
      std::function<F_ret (F_args...)> holder;
      holder = [func, &obj](F_args... args) { return (obj.*func)(args...); };  
      return holder;
    }
     
    template<typename F, typename F_ret, typename... F_args>
    std::function<F_ret (F_args...)>
    make_function (F_ret (F::*func)(F_args...) const, F const & obj)
    {
      // Composing a const member function pointer and a const object.  
      // This one is probably doable without using a lambda.
      std::function<F_ret (F_args...)> holder;
      holder = [func, &obj](F_args... args) { return (obj.*func)(args...); };  
      return holder;
    }
     
    template<typename F, typename G>
    auto operator >> (F f, G g)
      -> decltype(composer(f, &F::operator(), g, &G::operator()))
    {
      return composer(f, &F::operator(), g, &G::operator());
    }
     
    // This one allows a free function pointer to be the second parameter
    template<typename F, typename G_ret, typename... G_args>
    auto operator >> (F f, G_ret (*g)(G_args...))
      -> decltype(f >> make_function(g))
    {
      return f >> make_function(g);
    }
     
    // This one allows a free function pointer to be the first parameter
    template<typename F, typename G_ret, typename... G_args>
    auto operator >> (G_ret (*g)(G_args...), F f)
      -> decltype(make_function(g) >> f)
    {
      return make_function(g) >> f;
    }
     
    // Not possible to have function pointers on both sides of the binary operator >>
     
    int increment(int i) {
      return i+1;
    }
     
    int sum(int i, int j) {
      return i+j;
    }
     
    struct math {
      int increment (int i) {
        return i+1;
      }
     
      int sum (int i, int j) const {
        return i+j;
      }
    };
     
    int main(void)
    {
      auto l1 = [](int i , int j) { return i + j; };
      auto l2 = [](int a) { return a*a; };
     
      auto l3 = l1 >> l2 >> l2 >> increment; // does 11 allocs on Linux
      printf("%dn", l3(2, 3));              // prints 626
      printf("%dn", (sum >> l2)(3, 3));     // prints 36
     
      math m;
      printf("%dn",
       (make_function(&math::sum, m) >> make_function(&math::increment, m))(2, 3)); // prints 6
     
     
      return 0;
    }
           
    template<typename F, typename G>
     class compose {...}
     
     template<typename f, typename g>
     compose <F, G> operator >> (F f, G g)
     { return compose<F, G>(f, g); }
