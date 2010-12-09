
#include <cstdio>

#if(_WIN32_WINNT < 0x0601)
#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0601
#endif
#include <windows.h>

int main()
{
    system("pause");
    return 0;
}
