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
#import "EAGL-private.h"

#ifdef ANDROID
#import <EGL/egl.h>
#import <GLES/gl.h>
#endif

BOOL _EAGLSwappingBuffers = NO;

static EAGLContext *_currentContext = nil;

#pragma mark - Static functions

#ifdef ANDROID

static void _EAGLCreateContext(EAGLContext *context)
{
    // initialize OpenGL ES and EGL
    
    /*
     * Here specify the attributes of the desired configuration.
     * Below, we select an EGLConfig with at least 8 bits per color
     * component compatible with on-screen windows
     */
    const EGLint attribs[] = {
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_BLUE_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_RED_SIZE, 8,
        EGL_NONE
    };
    
    //        EGL_SURFACE_TYPE,   EGL_WINDOW_BIT,
    
    /*static const EGLint attribs[] =
    {
        EGL_RED_SIZE,       8,
        EGL_GREEN_SIZE,     8,
        EGL_BLUE_SIZE,      8,
        EGL_DEPTH_SIZE,     0,
        EGL_ALPHA_SIZE,     EGL_DONT_CARE,
        EGL_STENCIL_SIZE,   EGL_DONT_CARE,
        EGL_NONE
    };*/
    
    EGLint w, h, dummy, format;
    EGLint numConfigs;
    EGLConfig config;
    EGLSurface surface;
    EGLContext eglcontext;
    
    //DLog();
    context->_window = [IOWindowGetSharedWindow() retain];
    EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    //DLog(@"eglGetError: %d",eglGetError());
    //DLog(@"display: %p", display);
    eglInitialize(display, 0, 0);
    //DLog(@"eglGetError: %d",eglGetError());
    /* Here, the application chooses the configuration it desires. In this
     * sample, we have a very simplified selection process, where we pick
     * the first EGLConfig that matches our criteria */
    eglChooseConfig(display, attribs, &config, 1, &numConfigs);
    //DLog(@"config: %d", config);
    /* EGL_NATIVE_VISUAL_ID is an attribute of the EGLConfig that is
     * guaranteed to be accepted by ANativeWindow_setBuffersGeometry().
     * As soon as we picked a EGLConfig, we can safely reconfigure the
     * ANativeWindow buffers to match, using EGL_NATIVE_VISUAL_ID. */
    eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format);
    //DLog(@"eglGetError: %d",eglGetError());
    //DLog(@"ANativeWindow_setBuffersGeometry");
    //DLog(@"context->_window->_nWindow: %p", context->_window->_nWindow);
    ANativeWindow_setBuffersGeometry(context->_window->_nWindow, 0, 0, format);

    //DLog(@"display: %p", display);
    //DLog(@"eglCreateWindowSurface");
    surface = eglCreateWindowSurface(display, config, context->_window->_nWindow, NULL);
    //DLog(@"surface: %p", surface);
    eglcontext = eglCreateContext(display, config, NULL, NULL);
    //DLog(@"eglcontext: %p", eglcontext);
    eglQuerySurface(display, surface, EGL_WIDTH, &w);
    eglQuerySurface(display, surface, EGL_HEIGHT, &h);
    //w = 480;
    //h = 800;
    //DLog(@"w: %d", w);
    //DLog(@"h: %d", h);
    
    context->_eglDisplay = display;
    context->_eglContext = eglcontext;
    context->_eglSurface = surface;
    context->_width = w;
    context->_height = h;
}

#else

static void _EAGLCreateContext(EAGLContext *context)
{
    int attribList[] = {
        GLX_DEPTH_SIZE, 1,
        GLX_RGBA,
        GLX_RED_SIZE, 1,
        GLX_GREEN_SIZE, 1,
        GLX_BLUE_SIZE, 1,
        None
    };
    context->_window = [IOWindowGetSharedWindow() retain];
    context->_display = XOpenDisplay(NULL);
    //Display *display = context->_window->display;
    int screen = DefaultScreen(context->_display);
    XVisualInfo *visualInfo;
    visualInfo = glXChooseVisual(context->_display, screen, attribList);
    if (!visualInfo) {
        NSLog(@"glXChooseVisual failed");
        return;
    }
    context->_glXContext = glXCreateContext(context->_display, visualInfo, NULL, GL_TRUE);
    DLog(@"created GLX context: %p", context->_glXContext);
}

#endif

static void _EAGLCreateContextFromAnother(EAGLContext *context, EAGLContext *otherContext)
{
    // initialize OpenGL ES and EGL
    
    /*
     * Here specify the attributes of the desired configuration.
     * Below, we select an EGLConfig with at least 8 bits per color
     * component compatible with on-screen windows
     */
    const EGLint attribs[] = {
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_BLUE_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_RED_SIZE, 8,
        EGL_NONE
    };
    
    EGLint w, h, dummy, format;
    EGLint numConfigs;
    EGLConfig config;
    EGLSurface surface;
    EGLContext eglcontext;
    
    context->_window = [otherContext->_window retain];
    EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    DLog();
    eglInitialize(display, 0, 0);
    
    /* Here, the application chooses the configuration it desires. In this
     * sample, we have a very simplified selection process, where we pick
     * the first EGLConfig that matches our criteria */
    eglChooseConfig(display, attribs, &config, 1, &numConfigs);
    
    /* EGL_NATIVE_VISUAL_ID is an attribute of the EGLConfig that is
     * guaranteed to be accepted by ANativeWindow_setBuffersGeometry().
     * As soon as we picked a EGLConfig, we can safely reconfigure the
     * ANativeWindow buffers to match, using EGL_NATIVE_VISUAL_ID. */
    eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format);
    
    //ANativeWindow_setBuffersGeometry(context->_window->nwindow, 0, 0, format);
    
    surface = otherContext->_eglSurface;
    eglcontext = eglCreateContext(display, config, NULL, NULL);
    
    eglQuerySurface(display, surface, EGL_WIDTH, &w);
    eglQuerySurface(display, surface, EGL_HEIGHT, &h);
    
    context->_eglDisplay = display;
    context->_eglContext = eglcontext;
    context->_eglSurface = surface;
    context->_width = w;
    context->_height = h;
}

static void _EAGLDestroyContext(EAGLContext *context)
{
    if (context->_eglDisplay != EGL_NO_DISPLAY) {
        eglMakeCurrent(context->_eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (context != EGL_NO_CONTEXT) {
            eglDestroyContext(context->_eglDisplay, context->_eglContext);
        }
        if (context->_eglSurface != EGL_NO_SURFACE) {
            eglDestroySurface(context->_eglDisplay, context->_eglSurface);
        }
        eglTerminate(context->_eglDisplay);
    }
}

static bool checkGLXExtension(const char* extName)
{
    /*
     Search for extName in the extensions string.  Use of strstr()
     is not sufficient because extension names can be prefixes of
     other extension names.  Could use strtok() but the constant
     string returned by glGetString can be in read-only memory.
     */
    
    EAGLContext *context = _EAGLGetCurrentContext();
    Display *display = context->_display;
    int screen = DefaultScreen(display);
    char *list = (char*) glXQueryExtensionsString(display, screen);
    //NSLog(@"list: %s", list);
    char *end;
    int extNameLen;
    extNameLen = strlen(extName);
    end = list + strlen(list);
    while (list < end) {
        int n = strcspn(list, " ");
        
        if ((extNameLen == n) && (strncmp(extName, list, n) == 0))
            return true;
        
        list += (n + 1);
    };
    return false;
};

@implementation EAGLSharegroup

@end

@implementation EAGLContext

@synthesize API;
@synthesize sharegroup=_sharegroup;

#pragma mark - Life cycle

- (id)initWithAPI:(EAGLRenderingAPI)api
{
    self = [super init];
    if (self) {
        API = api;
        _sharegroup = [[EAGLSharegroup alloc] init];
        _EAGLCreateContext(self);
    }
    return self;
}

- (id)initWithAPI:(EAGLRenderingAPI)api sharegroup:(EAGLSharegroup *)aSharegroup
{
    self = [super init];
    if (self) {
        API = api;
        if (!aSharegroup) {
            _sharegroup = [[EAGLSharegroup alloc] init];
        } else {
            _sharegroup = [aSharegroup retain];
            DLog(@"_sharegroup: %@", _sharegroup);
            if (_currentContext) {
                if (_currentContext->_sharegroup == aSharegroup) {
                    _EAGLCreateContextFromAnother(self, _currentContext);
                    return self;
                }
            }
        }
        _EAGLCreateContext(self);
    }
    return self;
}
/*
- (id)initWithAPI:(EAGLRenderingAPI)api
{
    self = [super init];
    if (self) {
        API = api;
        shareGroup = [[EAGLShareGroup alloc] init];
        _EAGLContextCreateContext(self);
    }
    return self;
}

- (id)initWithAPI:(EAGLRenderingAPI)api sharegroup:(EAGLShareGroup *)aSharegroup
{
    self = [super init];
    if (self) {
        API = api;
        shareGroup = [aSharegroup retain];
        _EAGLContextCreateContext(self);
    }
    return self;
}*/

- (void)dealloc
{
    [_sharegroup release];
    [_window release];
#ifdef ANDROID
    if (_eglDisplay != EGL_NO_DISPLAY) {
        eglMakeCurrent(_eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (_eglContext != EGL_NO_CONTEXT) {
            eglDestroyContext(_eglDisplay, _eglContext);
        }
        if (_eglSurface != EGL_NO_SURFACE) {
            eglDestroySurface(_eglDisplay, _eglSurface);
        }
        eglTerminate(_eglDisplay);
    }
#else
    glXDestroyContext(_window->display, _glXContext);
#endif
    [super dealloc];
}

#pragma mark - Class methods

#ifdef ANDROID

+ (BOOL)setCurrentContext:(EAGLContext *)context
{
    if (_currentContext) {
        //DLog();
        [_currentContext release];
    }
    _currentContext = [context retain];
    if (context) {
        //DLog(@"eglGetError: %d",eglGetError());
        //DLog(@"context: %@",context);
        if (eglMakeCurrent(context->_eglDisplay, context->_eglSurface, context->_eglSurface, context->_eglContext) == EGL_FALSE) {
            DLog(@"Unable to eglMakeCurrent");
            return NO;
        }
        //DLog(@"eglGetError: %d",eglGetError());
        //DLog(@"%d", eglSwapInterval(context->_eglDisplay, 0));
        //DLog(@"eglGetError: %d",eglGetError());
        return YES;
    }
    return NO;
}

#else

+ (BOOL)setCurrentContext:(EAGLContext *)context
{
    if (_currentContext) {
        [_currentContext release];
    }
    _currentContext = [context retain];
    //DLog(@"_currentContext: %@", _currentContext);
    if (context) {
        //DLog(@"context: %@", context);
        BOOL result = glXMakeCurrent(context->_display, context->_window->xwindow, context->_glXContext);
        //DLog(@"result: %d", result);
        if (result) {
            //DLog(@"Success");
            return YES;
        } else {
            //DLog(@"Failed to make current context");
            return NO;
        }
    }
    return NO;
}

#endif

+ (EAGLContext *)currentContext
{
    return _currentContext;
}

@end

#pragma mark - Shared functions

void EAGLGetVersion(unsigned int *major, unsigned int *minor)
{
    if (_currentContext->API == kEAGLRenderingAPIOpenGLES1) {
        *major = EAGL_MAJOR_VERSION;
        *minor = EAGL_MINOR_VERSION;
    } else {
        *major = 2;
        *minor = 0;
    }
}

EAGLContext *_EAGLGetCurrentContext()
{
    //DLog();
    return _currentContext;
}

#ifdef ANDROID

void _EAGLSetup()
{
    //DLog(@"_EAGLSetup: 1");
    glMatrixMode(GL_MODELVIEW);
    //DLog(@"glGetError: %d", glGetError());
    
    glLoadIdentity();
    
    //glEnable(GL_DEPTH_TEST);
    //DLog(@"glGetError: %d", glGetError());
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_TEXTURE_2D);
    
    
    //glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    //glEnable(GL_CULL_FACE);
    //glShadeModel(GL_SMOOTH);
    //glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    //DLog(@"glGetError: %d", glGetError());
    glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
    //glBlendFunc(GL_ZERO, GL_SRC_COLOR);
    //DLog(@"glGetError: %d", glGetError());
    glAlphaFunc(GL_GREATER, 0);
    glEnable(GL_ALPHA_TEST);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    //glEnable(GL_CULL_FACE);
    glShadeModel(GL_SMOOTH);
    glDisable(GL_DEPTH_TEST);
    
    //DLog(@"glGetError: %d", glGetError());
}

#else

void _EAGLSetup()
{
    //DLog();
    glMatrixMode(GL_MODELVIEW);
    
    glLoadIdentity();
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    //DLog(@"glGetError: %d", glGetError());
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
    glAlphaFunc(GL_GREATER, 0);
    glEnable(GL_ALPHA_TEST);
    _EAGLSetSwapInterval(1);
}

#endif

void _EAGLSetSwapInterval(int interval)
{
#ifndef ANDROID
    void(*swapInterval)(int);
    if (checkGLXExtension("GLX_MESA_swap_control")) {
        swapInterval = (void (*)(int)) glXGetProcAddress((const GLubyte*) "glXSwapIntervalMESA");
        NSLog(@"GLX_MESA_swap_control");
        _currentContext->_vSyncEnabled = YES;
    } else if (checkGLXExtension("GLX_SGI_swap_control")) {
        swapInterval = (void (*)(int)) glXGetProcAddress((const GLubyte*) "glXSwapIntervalSGI");
        NSLog(@"GLX_SGI_swap_control");
        _currentContext->_vSyncEnabled = YES;
    } else {
        printf("no vsync?!\n");
        _currentContext->_vSyncEnabled = NO;
        return;
    }
    swapInterval(interval);
#endif
}

void _EAGLClear()
{
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void _EAGLFlush()
{
#ifdef ANDROID
    glFlush();
#endif
}

void _EAGLSwapBuffers()
{
    //DLog();
    _EAGLSwappingBuffers = YES;
    glFlush();
    //DLog();
    //DLog(@"currentContext->_eglDisplay: %p, currentContext->_eglSurface: %p", currentContext->_eglDisplay, currentContext->_eglSurface);
#ifdef ANDROID
    eglSwapBuffers(_currentContext->_eglDisplay, _currentContext->_eglSurface);
#endif
    //DLog();

//    EAGLMASwapBuffers();

    _EAGLSwappingBuffers = NO;
}

NSTimeInterval EAGLCurrentTime()
{
    return (CFTimeInterval)[NSDate timeIntervalSinceReferenceDate];
}
