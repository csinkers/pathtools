#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdlib.h>

int main(int argc, const char **argv) {
    int x = 0, y = 0;
    if(argc == 3) {
        x = atoi(argv[1]);
        y = atoi(argv[2]);
    }

    Display *display = XOpenDisplay(0);
    Window rootWindow = XRootWindow(display, 0);
    XSelectInput(display, rootWindow, KeyReleaseMask);
    XWarpPointer(display, None, rootWindow, 0, 0, 0, 0, x, y);
    XFlush(display);
    return 0;
}
