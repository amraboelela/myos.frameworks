/*
 Copyright © 2014-2015 myOS Group.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 Contributor(s):
 Amr Aboelela <amraboelela@gmail.com>
 */

#import <IOKit/IOKit.h>

#ifdef ANDROID
#import <MAKit/MAKit.h>
#endif

static IOWindow *_window = nil;
static int _parentWindowID = 0;

#pragma mark - Static functions

static Bool WaitForNotify(Display *dpy, XEvent *event, XPointer arg) 
{
    return (event->type == MapNotify) && (event->xmap.window == (Window) arg);
}

@implementation IOWindow

- (void)dealloc
{
#ifdef ANDROID
    IOWindowDestroyNativeWindow(_nWindow);
#endif
    [super dealloc];
}

@end

#pragma mark - Public functions

IOWindow *IOWindowCreateSharedWindow()
{
    if (_window) {
        [_window release];
    }
    _window = [[IOWindow alloc] init];
    return _window;
}

IOWindow *IOWindowGetSharedWindow()
{
    return _window;
}

CGContextRef IOWindowContext()
{
    return _window->_context;
}

int IOWindowGetID()
{
#ifdef ANDROID
    return 0;
#else
    return _window->_xwindow;
#endif
}

void IOWindowSetParentID(int windowID)
{
#ifdef ANDROID
#else
    _parentWindowID = windowID;
    //DLog(@"_parentWindowID: 0x%lx", _parentWindowID);
#endif
}

void IOWindowDestroySharedWindow()
{
    if (_window) {
        [_window release];
    }
    _window = nil;
}

#ifdef ANDROID

void *IOWindowCreateNativeWindow(int pipeRead)
{
    /*ANativeWindow *nWindow = nil;
     
     mComposerClient = new SurfaceComposerClient;
     ASSERT_EQ(NO_ERROR, mComposerClient->initCheck());
     mSurfaceControl = mComposerClient->createSurface(String8("MN Surface"),
     getSurfaceWidth(), getSurfaceHeight(),
     PIXEL_FORMAT_RGB_888, 0);
     
     ASSERT_TRUE(mSurfaceControl != NULL);
     ASSERT_TRUE(mSurfaceControl->isValid());
     
     SurfaceComposerClient::openGlobalTransaction();
     ASSERT_EQ(NO_ERROR, mSurfaceControl->setLayer(0x7FFFFFFF));
     ASSERT_EQ(NO_ERROR, mSurfaceControl->show());
     SurfaceComposerClient::closeGlobalTransaction();
     
     sp<ANativeWindow> window = mSurfaceControl->getSurface();
     _window->_nWindow = window.get();*/
    
#ifdef NATIVE_APP
    _window->_nWindow = getNativeWindow(pipeRead);
#endif
    return _window->_nWindow;
}

void IOWindowDestroyNativeWindow(void *nWindow)
{
}

void IOWindowSetNativeWindow(void *nWindow)
{
    _window->_nWindow = nWindow;
}

CGContextRef IOWindowCreateContextWithRect(CGRect aRect)
{
    _window->_rect = aRect;
    //DLog(@"aRect: %@", NSStringFromRect(NSRectFromCGRect(aRect)));
    _window->_context = IOWindowCreateContext();
    //DLog(@"Created context\n");
    return _window->_context;
}

CGContextRef IOWindowCreateContext()
{
    CGContextRef ctx;
    return _CGBitmapContextCreateWithOptions(_window->_rect.size, YES, 1.0);
}

#else // not ANDROID

CGContextRef IOWindowCreateContextWithRect(CGRect aRect)
{
    XSetWindowAttributes wa;
    XEvent event;
    int numReturned;
    //GLXFBConfig *fbConfigs;
    
    int doubleBufferAttributes[] = {
        GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
        GLX_RENDER_TYPE,   GLX_RGBA_BIT,
        GLX_DOUBLEBUFFER,  True,  /* Request a double-buffered color buffer with */
        GLX_RED_SIZE,      1,     /* the maximum number of bits per component    */
        GLX_GREEN_SIZE,    1,
        GLX_BLUE_SIZE,     1,
        None
    };
    
    _window->_rect = aRect;
#ifdef NATIVE_APP
    _window->_display = XOpenDisplay(NULL);
    Window parentWindow = DefaultRootWindow(_window->_display);
#else
    _window->_display = XOpenDisplay(":0");
    Window parentWindow = _parentWindowID;
#endif
    
    //DLog(@"display: %p", _window->_display);
    if (!_window->_display) {
        NSLog(@"Cannot open display: %s\n", XDisplayName(NULL));
        exit(EXIT_FAILURE);
    }
    //printf("Opened display %s\n", DisplayString(_window->_display));
    
    /* Request a suitable framebuffer configuration - try for a double
     ** buffered configuration first */
    //_window->_hasDoubleBuffer = YES;
    _window->_fbConfigs = glXChooseFBConfig(_window->_display, DefaultScreen(_window->_display), doubleBufferAttributes, &numReturned);
    if (_window->_fbConfigs == NULL) {  /* no double buffered configs available */
        NSLog(@"No double buffered configs available");
        exit(EXIT_FAILURE);
    }
    
    /* Create an X colormap and window with a visual matching the first
     ** returned framebuffer config */
    _window->_visualInfo = glXGetVisualFromFBConfig(_window->_display, _window->_fbConfigs[0]);
    
    wa.border_pixel = 0;
    //wa.event_mask = StructureNotifyMask;
    wa.event_mask = StructureNotifyMask | ExposureMask | ButtonPressMask | Button1MotionMask | ButtonReleaseMask;
    wa.colormap = XCreateColormap(_window->_display, parentWindow, _window->_visualInfo->visual, AllocNone);
    int swaMask = CWBorderPixel | CWColormap | CWEventMask;
    /* Create a window */
    _window->_xwindow = XCreateWindow(_window->_display, /* Display */
                                     parentWindow, /* Parent */
                                     _window->_rect.origin.x, _window->_rect.origin.y, /* x, y */
                                     _window->_rect.size.width, _window->_rect.size.height, /* width, height */
                                     0, /* border_width */
                                     _window->_visualInfo->depth, /* depth */
                                     InputOutput, /* class */
                                     _window->_visualInfo->visual, /* visual */
                                     swaMask, /* valuemask */
                                     &wa); /* attributes */

    //DLog(@"_window->_xwindow: 0x%lx\n", _window->_xwindow);
    XSelectInput(_window->_display, _window->_xwindow, ExposureMask | StructureNotifyMask | ButtonPressMask | Button1MotionMask | ButtonReleaseMask);

    /* Map the window to the screen, and wait for it to appear */
    //XMapWindow(dpy, xWin);
    //XIfEvent(dpy, &event, WaitForNotify, (XPointer) xWin);
    
    /* Map the window */
    int ret = XMapRaised(_window->_display, _window->_xwindow);
    //printf("XMapRaised returned: %x\n", ret);
    XIfEvent(_window->_display, &event, WaitForNotify, (XPointer)_window->_xwindow);
    
    /* Create a CGContext */
    _window->_context = IOWindowCreateContext();
    if (!_window->_context) {
        ALog(@"Cannot create context\n");
        exit(EXIT_FAILURE);
    }

    //printf("Created context\n");
    return _window->_context;
}

CGContextRef IOWindowCreateContext()
{
    CGContextRef ctx;
    XWindowAttributes wa;
    cairo_surface_t *target;
    int ret;
   
    //DLog(); 
    ret = XGetWindowAttributes(_window->_display, _window->_xwindow, &wa); 
    if (!ret) {
        DLog(@"XGetWindowAttributes returned %d", ret);
        return NULL;
    }
    target = cairo_xlib_surface_create(_window->_display, _window->_xwindow, wa.visual, wa.width, wa.height);
    //DLog(@"wa.visual: %p, wa.width: %d, wa.height: %d", wa.visual, wa.width, wa.height); 
    //DLog(@"target: %p", target);
    /* May not need this but left here for reference */
    ret = cairo_surface_set_user_data(target, &_window->_cwindow, (void *)_window->_xwindow, NULL);
    if (ret) {
        ALog(@"cairo_surface_set_user_data %s", cairo_status_to_string(CAIRO_STATUS_NO_MEMORY));
        cairo_surface_destroy(target);
        return NULL;
    }
    
    // NOTE: It doesn't looks like cairo will support using both device_scale and
    //             device_offset any time soon, so I moved the translation part of the
    //             flip to the transformation matrix, to be consistent.
    //             - Eric
    ctx = opal_new_CGContext(target, CGSizeMake(wa.width, wa.height));
    cairo_surface_destroy(target);
    return ctx;
}

void IOWindowSetContextSize(CGSize size)
{
    _window->_rect.size = size;
    OPContextSetSize(_window->_context, size); // Updates CTM
    cairo_xlib_surface_set_size(cairo_get_target(_window->_context->ct), size.width, size.height);
}

void IOWindowFlush()
{
    XFlush(_window->_display);
}

void IOWindowClear()
{
    XClearWindow(_window->_display, _window->_xwindow);
}

void IOWindowHideWindow()
{
    int ret = XUnmapWindow(_window->_display, _window->_xwindow);
}

#endif
