#include <windows.h>
#include <process.h>
#include <stdio.h>

unsigned __stdcall Display(void* p)
{
    Sleep(200 * (*(int*)p) );
    printf("Display\n");
    printf("  %d\n",*((int*)p));
    return 0;
}

int main()
{
    unsigned taddr = 0;
    unsigned createFlag = 0;
    HANDLE handles[5] = {0};
    int data[5] = {1,2,3,4,5};
    int i;
    for(i=0;i<5;++i)
    {
        if ( handles[i] = (HANDLE)_beginthreadex(NULL,0,&Display,data+i,createFlag,&taddr) )
        {
            printf("success\n");
        }
        else
            printf("failed\n");
    }
    WaitForMultipleObjects(5, handles, TRUE, INFINITE);
    printf("main's execution is over\n");
    return 0;
}
