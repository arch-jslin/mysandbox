#include <iostream>

void func(int const& ref)
{
    std::cout << &ref << std::endl;
}

int main()
{
    int a;
    std::cout << &a << std::endl;
    func(a);
    return 0;
}
