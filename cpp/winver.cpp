
#include <cstdio>
#include <windows.h>

int main()
{
    #if (_WIN32_WINNT >= 0x0601)
    printf("Windows 7\n");
    #elif (_WIN32_WINNT >= 0x0501)
    printf("Windows XP\n");
    #elif (_WIN32_WINNT >= 0x0400)
    printf("Windows 2K/98?\n");
    #else
    printf("Fuckdows\n");
    #endif
    system("pause");
    return 0;
}
