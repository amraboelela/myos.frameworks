
#import <CoreGraphics/CoreGraphics-private.h>

#ifdef ANDROID

struct android_app *_app;

void _CoreGraphicsInitialize(struct android_app *app)
{
    _app = app;
}

#endif
