
#include <cstdio>

#if(_WIN32_WINNT < 0x0601)
#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0601
#endif

#include <windows.h>
#include <windowsx.h>

#ifndef WM_TOUCH
#  define TOUCH_COORD_TO_PIXEL(l) ((l) / 100)
#  define WM_TOUCH 0x0240
#  undef TOUCHEVENTF_MOVE
#  undef TOUCHEVENTF_DOWN
#  define TOUCHEVENTF_MOVE       0x0001
#  define TOUCHEVENTF_DOWN       0x0002
#endif

COLORREF colors[] = {
    RGB(153,255,51), RGB(153,0,0), RGB(0,153,0),
    RGB(255,255,0), RGB(255,51,204), RGB(0,0,0) };

const int MAXPOINTS = 6;
struct TrackPoint {
    int id, x, y, radius;
    TrackPoint():id(-1), x(-1), y(-1), radius(10){}
};
TrackPoint POINTS_[MAXPOINTS];

// This function is used to return an index given an ID
TrackPoint* get_contact_point(int dwID){
  for( int i = 0; i < MAXPOINTS; ++i ) {
    if (POINTS_[i].id == -1){
      POINTS_[i].id = dwID;
      return &(POINTS_[i]);
    } else {
      if (POINTS_[i].id == dwID){
        return &(POINTS_[i]);
      }
    }
  }
  // Out of contacts
  return 0;
}

const char* WINDOW_CLASS_NAME_ = __TEXT("MTTest");
const int   WIDTH_ = 640;
const int   HEIGHT_= 480;

void             check_multitouch();
WNDCLASSEX       create_window_class(HINSTANCE&);
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);

int main()
{
    check_multitouch();

	HINSTANCE hInstance = GetModuleHandle(0); // get handle to exe file
	WNDCLASSEX wcex = create_window_class(hInstance);
	if( !RegisterClassEx(&wcex) ) {
	    printf("Create window class failed.\n");
	}
    HWND h = CreateWindow( WINDOW_CLASS_NAME_, __TEXT("WM_TOUCH test"),
        WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, WIDTH_, HEIGHT_, NULL, NULL, hInstance, NULL);

    if( !RegisterTouchWindow(h, 0) ) {
        printf("Error: RegisterTouchWindow failed.\n");
    }

    ShowWindow(h, SW_SHOW);
    UpdateWindow(h);

    // Main message loop:
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    UnregisterTouchWindow(h);
    system("pause");
    return (int) msg.wParam;
}

void check_touch_points(PTOUCHINPUT p, UINT input_count)
{
    for( UINT i = 0; i < input_count; ++i ) {
        printf(" point %d: ", i);
        TOUCHINPUT t = p[i];
        printf("[ID=%d, x=%ld, y=%ld]", static_cast<int>(t.dwID), t.x, t.y);
        if( t.dwFlags & TOUCHEVENTF_MOVE ) printf(" move");
        if( t.dwFlags & TOUCHEVENTF_DOWN ) printf(" *DOWN*");
        if( t.dwFlags & TOUCHEVENTF_UP )   printf(" *UP*");
        if( t.dwFlags & TOUCHEVENTF_PRIMARY ) printf(" PRIMARY");
        if( t.dwFlags & TOUCHEVENTF_PEN )  printf(" pen?");
        printf("\n");
    }
}

void setup_drawing_points(HWND h, PTOUCHINPUT p, UINT input_count)
{
    for( UINT i = 0; i < input_count; ++i ) {
        TOUCHINPUT ti = p[i];
        if( TrackPoint* tp = get_contact_point(ti.dwID) ) {
            POINT point;
            point.x = TOUCH_COORD_TO_PIXEL(ti.x);
            point.y = TOUCH_COORD_TO_PIXEL(ti.y);
            if( !ScreenToClient(h, &point) ) {
                printf("Error: contact point %d translation failed.\n", i);
            }
            if (ti.dwFlags & TOUCHEVENTF_UP) {
                tp->x = -1;
                tp->y = -1;
            } else {
                tp->x = point.x;
                tp->y = point.y;
            }
        }
    }
}

void translate_touch(HWND h, WPARAM wp, LPARAM lp)
{
    BOOL handled = FALSE;
    UINT input_count = LOWORD(wp);
    PTOUCHINPUT pInputs = new TOUCHINPUT[input_count];
    if ( pInputs ) {
        if ( GetTouchInputInfo((HANDLE)lp, input_count, pInputs, sizeof(TOUCHINPUT)) ) {
            printf("------ Processing WM_TOUCH ------\n");
            check_touch_points(pInputs, input_count);
            setup_drawing_points(h, pInputs, input_count);
            handled = TRUE;
        } else {
             DWORD dw = GetLastError();
             printf("Error: %d", static_cast<int>(dw));
        }
        delete [] pInputs;
    } else {
        printf("Error: structure for touch inputs not allocated.\n");
    }
    if ( handled )
        CloseTouchInputHandle((HANDLE)lp);
}

void paint(HWND h)
{
    // For double buffering
    HDC memDC       = 0;
    HBITMAP hMemBmp = 0;
    HBITMAP hOldBmp = 0;

    // For drawing / fills
    PAINTSTRUCT ps;
    HDC hdc;

    hdc = BeginPaint(h, &ps);
    RECT rect;
    GetClientRect(h, &rect);

    // start double buffering
    if (!memDC){
        memDC = CreateCompatibleDC(hdc);
    }
    hMemBmp = CreateCompatibleBitmap(hdc, rect.right, rect.bottom);
    hOldBmp = (HBITMAP)SelectObject(memDC, hMemBmp);
    FillRect(memDC, &rect, CreateSolidBrush(RGB(255,255,255)));

    for ( int i = 0; i < MAXPOINTS; ++i ) { //Draw Touched Points
      SelectObject( memDC, CreateSolidBrush(colors[i]) );
      int x = POINTS_[i].x;
      int y = POINTS_[i].y;
      int r = POINTS_[i].radius;
      if (x > 0 && y > 0) {
        Ellipse(memDC, x - r, y - r, x + r, y + r);
      }
    }
    BitBlt(hdc, 0, 0, rect.right, rect.bottom, memDC, 0, 0, SRCCOPY);
    EndPaint(h, &ps);
}

LRESULT CALLBACK WndProc(HWND h, UINT msg, WPARAM wp, LPARAM lp)
{
    switch (msg)
    {
        case WM_PAINT:
            paint(h);
            break;
        case WM_TOUCH:
            translate_touch(h, wp, lp);
            break;
        case WM_DESTROY:
            PostQuitMessage(0);
            break;
        default:
            return DefWindowProc(h, msg, wp, lp);
            break;
    }
    return 0;
}

void check_multitouch()
{
    int value = GetSystemMetrics(94); //SM_DIGITIZER
    printf("Touch support feature (%d)\n", value);
    if( value & 0x00000001 ) printf("  integrated touch digitizer.\n");
    if( value & 0x00000002 ) printf("  external touch digitizer.\n");
    if( value & 0x00000004 ) printf("  integrated pen digitizer.\n");
    if( value & 0x00000008 ) printf("  external pen digitizer.\n");
    if( value & 0x00000040 ) printf("  has multi-input.\n");
    if( value & 0x00000080 ) printf("  the device(s) are working correctly.\n");
}

WNDCLASSEX create_window_class(HINSTANCE& hInstance)
{
    WNDCLASSEX wcex;
    wcex.cbSize			= sizeof(WNDCLASSEX);
    wcex.style			= CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc	= WndProc;
    wcex.cbClsExtra		= 0;
    wcex.cbWndExtra		= 0;
    wcex.hInstance		= hInstance;
    wcex.hIcon			= NULL;
    wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
    wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName	= 0;
    wcex.lpszClassName	= WINDOW_CLASS_NAME_;
    wcex.hIconSm		= 0;
    // if there is an icon, load it
    //wcex.hIcon = (HICON)LoadImage(hInstance, __TEXT("irrlicht.ico"), IMAGE_ICON, 0,0, LR_LOADFROMFILE);
    return wcex;
}
