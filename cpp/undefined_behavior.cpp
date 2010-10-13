#include <iostream>
#include <cstdio>

int func_a(int a) { return a; }
int func_b(int b) { return b; }

int main()
{
    int a = 1;
    printf("%d, %d", a, a++);
    return 0;
}
