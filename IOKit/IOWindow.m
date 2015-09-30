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

#pragma mark - Static functions

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
    //DLog();
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

int IOWindowGetHandle()
{
#ifdef ANDROID
    return 0;
#else
    return _window->xwindow;
#endif
}

void IOWindowSetHandle(int _handle)
{
#ifdef ANDROID
#else
    //DLog();
    _window->xwindow = _handle;
    DLog(@"_window->xwindow: 0x%lx", _window->xwindow);
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
    //DLog();
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
    
    _window->_rect = aRect;
    _window->display = XOpenDisplay(":0");
    //DLog(@"display: %p", _window->display);
    if (!_window->display) {
        NSLog(@"Cannot open display: %s\n", XDisplayName(NULL));
        exit(EXIT_FAILURE);
    }
    //printf("Opened display %s\n", DisplayString(_window->display));
    
    //cr = CGRectMake(0,0,640,480);
    wa.background_pixel = WhitePixel(_window->display, DefaultScreen(_window->display));
    wa.event_mask = ExposureMask | ButtonPressMask | Button1MotionMask | ButtonReleaseMask;
#ifdef NATIVE_APP
    /* Create a window */
    _window->xwindow = XCreateWindow(_window->display, /* Display */
                                     DefaultRootWindow(_window->display), /* Parent */
                                     _window->_rect.origin.x, _window->_rect.origin.y, /* x, y */
                                     _window->_rect.size.width, _window->_rect.size.height, /* width, height */
                                     0, /* border_width */
                                     CopyFromParent, /* depth */
                                     InputOutput, /* class */
                                     CopyFromParent, /* visual */
                                     CWBackPixel | CWEventMask, /* valuemask */
                                     &wa); /* attributes */
#endif
    DLog(@"_window->xwindow: 0x%lx\n", _window->xwindow);
    XSelectInput(_window->display, _window->xwindow, ExposureMask | StructureNotifyMask | ButtonPressMask | Button1MotionMask | ButtonReleaseMask);
    /* Map the window */
    int ret = XMapRaised(_window->display, _window->xwindow);
    printf("XMapRaised returned: %x\n", ret);
    
    /* Create a CGContext */
    _window->_context = IOWindowCreateContext();
    if (!_window->_context) {
        ALog(@"Cannot create context\n");
        exit(EXIT_FAILURE);
    }
    printf("Created context\n");
    return _window->_context;
}

CGContextRef IOWindowCreateContext()
{
    CGContextRef ctx;
    XWindowAttributes wa;
    cairo_surface_t *target;
    int ret;
   
    //DLog(); 
#ifdef NATIVE_APP
    ret = XGetWindowAttributes(_window->display, _window->xwindow, &wa); 
    if (!ret) {
        DLog(@"XGetWindowAttributes returned %d", ret);
        return NULL;
    }
    target = cairo_xlib_surface_create(_window->display, _window->xwindow, wa.visual, wa.width, wa.height);
    DLog(@"wa.visual: %p, wa.width: %d, wa.height: %d", wa.visual, wa.width, wa.height); 
    DLog(@"target: %p", target);
    /* May not need this but left here for reference */
    ret = cairo_surface_set_user_data(target, &_window->cwindow, (void *)_window->xwindow, NULL);
    if (ret) {
        ALog(@"cairo_surface_set_user_data %s", cairo_status_to_string(CAIRO_STATUS_NO_MEMORY));
        cairo_surface_destroy(target);
        return NULL;
    }
#else
    target = cairo_xlib_surface_create(_window->display, _window->xwindow, NULL, 400, 710);
#endif
    /* Flip coordinate system */
    //cairo_surface_set_device_offset(target, 0, wa.height);
    /* FIXME: The scale part of device transform does not work correctly in
     * cairo so for now we have to patch the CTM! This should really be fixed
     * in cairo and then the ScaleCTM call below and the hacks in GetCTM in
     * CGContext should be removed in favour of the following line: */
    /* _cairo_surface_set_device_scale(target, 1.0, -1.0); */
    
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
    //    XFlushGC(_window->display, _window->_context);
    XFlush(_window->display);
}

void IOWindowClear()
{
    XClearWindow(_window->display, _window->xwindow);
}

#endif
