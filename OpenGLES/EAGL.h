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

#import <Foundation/Foundation.h>

#ifdef ANDROID
#import <EGL/egl.h>
#else
#import <GL/glx.h>
#endif

#define EAGL_MAJOR_VERSION      1
#define EAGL_MINOR_VERSION      0

typedef enum {
    kEAGLRenderingAPIOpenGLES1 = 1,
    kEAGLRenderingAPIOpenGLES2,
} EAGLRenderingAPI;

extern void EAGLGetVersion(unsigned int *major, unsigned int *minor);

@interface EAGLSharegroup : NSObject

@end

@class IOWindow;

@interface EAGLContext : NSObject {
@public
    EAGLRenderingAPI API;
    EAGLSharegroup *_sharegroup;
    IOWindow *_window;
    float _width;
    float _height;
#ifdef ANDROID
    EGLDisplay _eglDisplay;
    EGLConfig _eglFBConfig[1];
    EGLSurface _eglSurface;
    EGLContext _eglContext;
#else
    GLXContext _glXContext;
    Display *_display;
#endif
    BOOL _vSyncEnabled;
}

@property (readonly) EAGLRenderingAPI API;
@property (readonly) EAGLSharegroup *sharegroup;

- (id)initWithAPI:(EAGLRenderingAPI)api;
- (id)initWithAPI:(EAGLRenderingAPI)api sharegroup:(EAGLSharegroup *)aSharegroup;

+ (BOOL)setCurrentContext:(EAGLContext *)context;
+ (EAGLContext *)currentContext;

@end
