/*
 Copyright © 2014 myOS Group.
 
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
#import <MAKit/MAKit.h>

static IOWindow *_window = nil;

#pragma mark - Static functions
/*
static void _IOWindowGetBuffers()
{
    DLog();
    int myuid = getuid();
    DLog(@"myuid: %d", myuid);
    execv("su");
    DLog(@"myuid 2: %d", myuid);
    IOPipeRunCommand(@"dumpsys SurfaceFlinger", YES);
}*/

@implementation IOWindow
/*
- (id)init
{
    self = [super init];
    if (self) {
        _nWindow = nil;
    }
    return self;
}*/

- (void)dealloc
{
    IOWindowDestroyNativeWindow(_nWindow);
    [super dealloc];
}

@end

#pragma mark - Shared functions

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

void IOWindowDestroySharedWindow()
{
    if (_window) {
        [_window release];
    }
    _window = nil;
}

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
    
#ifndef NA
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
    //DLog(@"_window->rect.size: %@", NSStringFromSize(NSSizeFromCGSize(_window->rect.size)));
    return _CGBitmapContextCreateWithOptions(_window->_rect.size, YES, 1.0);
    /*
    CGContextRef ctx;
    XWindowAttributes wa;
    cairo_surface_t *target;
    int ret;

    ret = XGetWindowAttributes(_window->display, _window->xwindow, &wa);
    if (!ret) {
        NSLog(@"XGetWindowAttributes returned %d", ret);
        return NULL;
    }
    target = cairo_xlib_surface_create(_window->display, _window->xwindow, wa.visual, wa.width, wa.height);
    ret = cairo_surface_set_user_data(target, &_window->cwindow, (void *)_window->xwindow, NULL);
    if (ret) {
        NSLog(@"cairo_surface_set_user_data %s", cairo_status_to_string(CAIRO_STATUS_NO_MEMORY));
        cairo_surface_destroy(target);
        return NULL;
    }
    
    // NOTE: It doesn't looks like cairo will support using both device_scale and 
    //             device_offset any time soon, so I moved the translation part of the
    //             flip to the transformation matrix, to be consistent.
    //             - Eric
    ctx = opal_new_CGContext(target, CGSizeMake(wa.width, wa.height));
    cairo_surface_destroy(target);
    return ctx;*/
}
/*
void IOWindowSetContextSize(CGSize size)
{
    _window->rect.size = size;
    OPContextSetSize(_window->context, size); // Updates CTM
    cairo_xlib_surface_set_size(cairo_get_target(_window->context->ct), size.width, size.height);
}*/

CGContextRef IOWindowContext()
{
    return _window->_context;
}
/*
void IOWindowFlush()
{
//    XFlushGC(_window->display, _window->context);
    XFlush(_window->display);
}

void IOWindowClear()
{
    XClearWindow(_window->display, _window->xwindow);
}*/
