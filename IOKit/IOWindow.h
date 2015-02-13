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

#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGContext-private.h>

#ifdef ANDROID
#import <rd_app_glue.h>
#else
#import <X11/Xlib.h>
#import <cairo-xlib.h>
#endif

@interface IOWindow : NSObject
{
@public
    CGContextRef _context;
#ifdef ANDROID
    ANativeWindow *_nWindow;
#else
    Window xwindow;
    cairo_user_data_key_t cwindow;
    Display *display;
#endif
    CGRect _rect;
}
@end

CGContextRef IOWindowCreateContext();
void *IOWindowCreateNativeWindow(int pipeRead);
void IOWindowDestroyNativeWindow(void *nWindow);
void IOWindowSetNativeWindow(void* nWindow);
IOWindow *IOWindowCreateSharedWindow();
IOWindow *IOWindowGetSharedWindow();
void IOWindowDestroySharedWindow();

CGContextRef IOWindowCreateContextWithRect(CGRect aRect);
CGContextRef IOWindowContext();

#ifdef ANDROID
#else
void IOWindowSetContextSize(CGSize size);
void IOWindowFlush();
void IOWindowClear();
#endif



