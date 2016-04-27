/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <fcntl.h>
//#import <sys/wait.h>
#import <UIKit/UIKit-private.h>
#import <OpenGLES/EAGL-private.h>
#import <IOKit/IOKit.h>
#import <CoreGraphics/CoreGraphics-private.h>
#import <QuartzCore/QuartzCore-private.h>

#define _kInactiveTimeLimit     30.0
#define _kLongInactiveTimeLimit 60.0

NSString *const UIApplicationWillChangeStatusBarOrientationNotification = @"UIApplicationWillChangeStatusBarOrientationNotification";
NSString *const UIApplicationDidChangeStatusBarOrientationNotification = @"UIApplicationDidChangeStatusBarOrientationNotification";
NSString *const UIApplicationWillEnterForegroundNotification = @"UIApplicationWillEnterForegroundNotification";
NSString *const UIApplicationWillTerminateNotification = @"UIApplicationWillTerminateNotification";
NSString *const UIApplicationWillResignActiveNotification = @"UIApplicationWillResignActiveNotification";
NSString *const UIApplicationDidEnterBackgroundNotification = @"UIApplicationDidEnterBackgroundNotification";
NSString *const UIApplicationDidBecomeActiveNotification = @"UIApplicationDidBecomeActiveNotification";
NSString *const UIApplicationDidFinishLaunchingNotification = @"UIApplicationDidFinishLaunchingNotification";
NSString *const UIApplicationNetworkActivityIndicatorChangedNotification = @"UIApplicationNetworkActivityIndicatorChangedNotification";
NSString *const UIApplicationLaunchOptionsURLKey = @"UIApplicationLaunchOptionsURLKey";
NSString *const UIApplicationLaunchOptionsSourceApplicationKey = @"UIApplicationLaunchOptionsSourceApplicationKey";
NSString *const UIApplicationLaunchOptionsRemoteNotificationKey = @"UIApplicationLaunchOptionsRemoteNotificationKey";
NSString *const UIApplicationLaunchOptionsAnnotationKey = @"UIApplicationLaunchOptionsAnnotationKey";
NSString *const UIApplicationLaunchOptionsLocalNotificationKey = @"UIApplicationLaunchOptionsLocalNotificationKey";
NSString *const UIApplicationLaunchOptionsLocationKey = @"UIApplicationLaunchOptionsLocationKey";
NSString *const UIApplicationDidReceiveMemoryWarningNotification = @"UIApplicationDidReceiveMemoryWarningNotification";
NSString *const UITrackingRunLoopMode = @"UITrackingRunLoopMode";

const UIBackgroundTaskIdentifier UIBackgroundTaskInvalid = NSUIntegerMax; // correct?
const NSTimeInterval UIMinimumKeepAliveTimeout = 0;

static UIApplication *_application = nil;
static NSString *_processName = nil;

typedef struct {
    float green;
    int32_t x;
    int32_t y;
} saved_state;

typedef struct {
    struct android_app* app;
    EAGLContext *context;
    saved_state state;
} engine;

#pragma mark - Static functions

#ifdef ANDROID

static void _UIApplicationProcessInitialize()
{
    int argc=1;
    char** argv;
    char** env;
    //printf("_UIApplicationProcessInitialize 1");
    const char *myArgv[] = {"AppName",0};
    /*if (_processName) {
        myArgv[0] = [_processName cString];
    }*/
    argv = myArgv;
    const char *myEnv[] = {
        "TERM_PROGRAM=Apple_Terminal",
        "SHELL=/bin/bash",
        "TERM=xterm-256color",
        "TMPDIR=/var/folders/xl/dry9v7p17w38w8v4sy1wsyr40000gn/T/",
        "Apple_PubSub_Socket_Render=/tmp/launch-lVth2w/Render",
        "TERM_PROGRAM_VERSION=309",
        "TERM_SESSION_ID=02C012FB-0CBF-4182-BD1D-B03C6CAAE8A1",
        "USER=amr",
        "COMMAND_MODE=unix2003",
        "SSH_AUTH_SOCK=/tmp/launch-17Hdqv/Listeners",
        "Apple_Ubiquity_Message=/tmp/launch-knmMB6/Apple_Ubiquity_Message",
        "__CF_USER_TEXT_ENCODING=0x1F5:0:0",
        "PATH=/Users/amr/develop/adt/ndk:/Users/amr/develop/adt/sdk/tools:/Users/amr/develop/adt/sdk/platform-tools:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/git/bin",
        "PWD=/Users/amr/Documents/kit/ndk",
        "EDITOR=vim",
        "LANG=en_US.UTF-8",
        "HOME=/Users/amr",
        "SHLVL=2",
        "KIT_PATH=/Users/amr/Documents/kit",
        "LOGNAME=amr",
        "DISPLAY=/tmp/launch-8M6diV/org.macosforge.xquartz:0",
        "MACHINE_USERNAME=amr",
        "_=./HelloWorld",
        0
    };
    //printf("_UIApplicationProcessInitialize 2");
    env = myEnv;
    GSInitializeProcess(argc, argv, env);
    //printf("_UIApplicationProcessInitialize 3");
}

#endif

static void _UIApplicationInitialize()
{
    _UINavigationItemInitialize();
    //_CoreTextInitialize();
}

static void _UIApplicationLaunchApplicationWithDefaultWindow(UIWindow *window)
{
    //UIApplication *app = [UIApplication sharedApplication];
    id<UIApplicationDelegate> appDelegate = _application->_delegate;
    
    if ([appDelegate respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
        [appDelegate application:_application didFinishLaunchingWithOptions:nil];
    } else if ([appDelegate respondsToSelector:@selector(applicationDidFinishLaunching:)]) {
        [appDelegate applicationDidFinishLaunching:_application];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification
                                                        object:_application];
    if ([appDelegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [appDelegate applicationDidBecomeActive:_application];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification
                                                        object:_application];
}

static BOOL TouchIsActiveGesture(UITouch *touch)
{
    return (touch.phase == _UITouchPhaseGestureBegan || touch.phase == _UITouchPhaseGestureChanged);
}

static BOOL TouchIsActiveNonGesture(UITouch *touch)
{
    return (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved || touch.phase == UITouchPhaseStationary);
}

static BOOL TouchIsActive(UITouch *touch)
{
    return TouchIsActiveGesture(touch) || TouchIsActiveNonGesture(touch);
}

#ifdef NATIVE_APP

#ifdef ANDROID

/**
 * Tear down the EGL context currently associated with the display.
 */
static void engine_term_display(engine* myEngine)
{
    //DLog(@"engine_term_display");
    UIParentApplicationTerminateApps();
    [EAGLContext setCurrentContext:nil];
    exit(0);
}

static void engine_handle_cmd(struct android_app* app, int32_t cmd)
{
    engine *myEngine = (engine*)app->userData;
    switch (cmd) {
        case APP_CMD_SAVE_STATE:
            // The system has asked us to save our current state.  Do so.
            myEngine->app->savedState = malloc(sizeof(saved_state));
            *((saved_state*)myEngine->app->savedState) = myEngine->state;
            myEngine->app->savedStateSize = sizeof(saved_state);
            break;
        case APP_CMD_INIT_WINDOW:
            // The window is being shown, get it ready.
            if (myEngine->app->window != NULL) {
                IOWindow *window = IOWindowCreateSharedWindow();
                IOWindowSetNativeWindow(app->window);
                _CAAnimatorInitialize();
                //UIParentApplicationInitialize();
                [_CAAnimatorConditionLock lockWhenCondition:_CAAnimatorConditionLockHasNoWork];
                myEngine->context = _EAGLGetCurrentContext();
                UIScreen *screen = [[UIScreen alloc] init];
                CGContextRef ctx = IOWindowCreateContextWithRect(screen->_bounds);
                UIGraphicsPushContext(ctx);
                [_CAAnimatorConditionLock unlock];
                //_application->_lastActivityTime = CACurrentMediaTime();
                _UIApplicationLaunchApplicationWithDefaultWindow(nil);
            }
            break;
        case APP_CMD_TERM_WINDOW: {
            // The window is being hidden or closed, clean it up.
            engine_term_display(myEngine);
            break;
        }
        case APP_CMD_LOST_FOCUS:
            // When our app loses focus, we stop monitoring the accelerometer.
            // Also stop animating.
            //myEngine->animating = 0;
            //engine_draw_frame(myEngine);
            break;
    }
}

static int32_t engine_handle_input(struct android_app* app, AInputEvent *event)
{
    engine *myEngine = (engine *)app->userData;
    size_t action = AMotionEvent_getAction(event) & AMOTION_EVENT_ACTION_MASK;
    int32_t keFlags = AKeyEvent_getFlags(event);
    //int32_t keyCode;
    //DLog(@"AKeyEvent_getKeyCode(event): %d", AKeyEvent_getKeyCode(event));
    if (keFlags & AKEY_EVENT_FLAG_FROM_SYSTEM) {
        int32_t keyCode = AKeyEvent_getKeyCode(event);
        if (action == AMOTION_EVENT_ACTION_UP) {
            switch (keyCode) {
                case AKEYCODE_BACK:
                    //DLog(@"Back button clicked");
                    UIParentApplicationGoBack();
                    return 1;
                case AKEYCODE_MENU:
                    //DLog(@"Menu button clicked");
                    UIParentApplicationShowLauncher();
                    return 1;
                default:
                    break;
            }
        }
    }
    if (action != AMOTION_EVENT_ACTION_UP && action != AMOTION_EVENT_ACTION_DOWN && action != AMOTION_EVENT_ACTION_MOVE) {
        return 0;
    }
    if (AInputEvent_getType(event) == AINPUT_EVENT_TYPE_MOTION) {
        UITouch *touch = [[_application->_currentEvent allTouches] anyObject];
        UIScreen *screen = _UIScreenMainScreen();
        float x = AMotionEvent_getX(event,0)/screen->_hScale;
        float y = AMotionEvent_getY(event,0)/screen->_vScale;
        CGPoint screenLocation = CGPointMake(x, y);
        //DLog(@"screenLocation: x:%0.0f, y:%0.0f", x, y);
        NSTimeInterval timestamp = CACurrentMediaTime();
        _application->_currentEvent->_timestamp = timestamp;
        if (action == AMOTION_EVENT_ACTION_UP) {
            //DLog(@"AMOTION_EVENT_ACTION_UP");
            IOPipeWriteMessage(ChildPipeMessageEventActionUp, NO);
            _UITouchUpdatePhase(touch, UITouchPhaseEnded, screenLocation, timestamp);
            UIParentApplicationMoveCurrentAppToTop();
        } else if (action == AMOTION_EVENT_ACTION_DOWN) {
            //DLog(@"AMOTION_EVENT_ACTION_DOWN");
            IOPipeWriteMessage(ChildPipeMessageEventActionDown, NO);
            CGPoint delta = CGPointZero;
            int tapCount = 1;
            NSTimeInterval timeDiff = fabs(touch.timestamp - timestamp);
            if (touch.phase == UITouchPhaseEnded && timeDiff < _kUIEventTimeDiffMax) {
                tapCount = touch.tapCount+1;
            }
            _UITouchSetPhase(touch, UITouchPhaseBegan, screenLocation, tapCount, delta, timestamp);
        } else {
            //DLog(@"AMOTION_EVENT_ACTION_MOVED");
            IOPipeWriteMessage(ChildPipeMessageEventActionMoved, NO);
            _UITouchUpdatePhase(touch, UITouchPhaseMoved, screenLocation, timestamp);
        }
        IOPipeWriteFloat(x);
        IOPipeWriteFloat(y);
        _UIApplicationSetCurrentEventTouchedView();
        //_application->_lastActivityTime = CACurrentMediaTime();
        return 1;
    }
}

#else // not ANDROID

#endif // ANDROID

#else // not NATIVE_APP

#ifdef ANDROID

static void _UIApplicationInitWindow()
{
    IOWindow *window = IOWindowCreateSharedWindow();
    IOWindowCreateNativeWindow(0);
    
    _CAAnimatorInitialize();
    [_CAAnimatorConditionLock lockWhenCondition:_CAAnimatorConditionLockHasNoWork];
    EAGLContext *context = _EAGLGetCurrentContext();
    UIScreen *screen = [[UIScreen alloc] init];
    CGContextRef ctx = IOWindowCreateContextWithRect(screen->_bounds);
    UIGraphicsPushContext(ctx);
    [_CAAnimatorConditionLock unlock];
    //_application->_lastActivityTime = CACurrentMediaTime();
    _UIApplicationLaunchApplicationWithDefaultWindow(nil);
}

#else // not ANDROID

#endif // ANDROID

#endif // NATIVE_APP

#pragma mark -

@implementation UIApplication

@synthesize keyWindow=_keyWindow;
@synthesize delegate=_delegate;
@synthesize idleTimerDisabled=_idleTimerDisabled;
@synthesize applicationSupportsShakeToEdit=_applicationSupportsShakeToEdit;
@synthesize applicationIconBadgeNumber=_applicationIconBadgeNumber;
@synthesize applicationState=_applicationState;
@synthesize appImage=_appImage;

#pragma mark - Life cycle

- (id)init
{
    if ((self=[super init])) {
        _currentEvent = [[UIEvent alloc] initWithEventType:UIEventTypeTouches];
        _UIEventSetTouch(_currentEvent, [[[UITouch alloc] init] autorelease]);
        _visibleWindows = [[NSMutableSet alloc] init];
        _backgroundTasks = [[NSMutableArray alloc] init];
        _applicationState = UIApplicationStateActive;
        _applicationSupportsShakeToEdit = YES;
    }
    return self;
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [_currentEvent release];
    [_visibleWindows release];
    [_backgroundTasks release];
    [_backgroundTasksExpirationDate release];
    //[_blackScreen release];
    IOWindowDestroySharedWindow();
    [_appImage release];
    [super dealloc];
}

#pragma mark - Class methods

+ (UIApplication *)sharedApplication
{
    return _application;
}

#pragma mark - Accessors

- (BOOL)isStatusBarHidden
{
    return YES;
}

- (BOOL)isNetworkActivityIndicatorVisible
{
    return _networkActivityIndicatorVisible;
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)b
{
    if (b != [self isNetworkActivityIndicatorVisible]) {
        _networkActivityIndicatorVisible = b;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationNetworkActivityIndicatorChangedNotification object:self];
    }
}

- (BOOL)isIgnoringInteractionEvents
{
    return (_ignoringInteractionEvents > 0);
}

- (UIInterfaceOrientation)statusBarOrientation
{
    return UIInterfaceOrientationPortrait;
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
}

- (UIStatusBarStyle)statusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated
{
}

- (NSTimeInterval)statusBarOrientationAnimationDuration
{
    return 0.3;
}

- (CGRect)statusBarFrame
{
    return CGRectZero;
}

- (NSTimeInterval)backgroundTimeRemaining
{
    return [_backgroundTasksExpirationDate timeIntervalSinceNow];
}

- (NSArray *)scheduledLocalNotifications
{
    return nil;
}

- (void)setScheduledLocalNotifications:(NSArray *)scheduledLocalNotifications
{
}

- (NSArray *)windows
{
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"windowLevel" ascending:YES] autorelease];
    return [[_visibleWindows valueForKey:@"nonretainedObjectValue"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (NSString *)description
{
    //DLog(@"_data: %@", _data);
    return [NSString stringWithFormat:@"<%@: %p; name: %@; applicationState: %d>", [self className], self, _processName, _applicationState];
}

#pragma mark - Delegates
/*
- (void)turnOnScreen:(id)sender
{
    [_blackScreen removeFromSuperview];
    _lastActivityTime = CACurrentMediaTime();
    _screenMode = _UIApplicationScreenModeActive;
}*/

#pragma mark - Public methods

- (void)beginIgnoringInteractionEvents
{
    _ignoringInteractionEvents++;
}

- (void)endIgnoringInteractionEvents
{
    _ignoringInteractionEvents--;
}

- (void)cancelAllLocalNotifications
{
}

- (UIBackgroundTaskIdentifier)beginBackgroundTaskWithExpirationHandler:(void(^)(void))handler
{
    UIBackgroundTask *task = [[[UIBackgroundTask alloc] initWithExpirationHandler:handler] autorelease];
    [_backgroundTasks addObject:task];
    return task.taskIdentifier;
}

- (void)endBackgroundTask:(UIBackgroundTaskIdentifier)identifier
{
    for (UIBackgroundTask *task in _backgroundTasks) {
        if (task.taskIdentifier == identifier) {
            [_backgroundTasks removeObject:task];
            break;
        }
    }
}

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
    if (!target) {
        // The docs say this method will start with the first responder if target==nil. Initially I thought this meant that there was always a given
        // or set first responder (attached to the window, probably). However it doesn't appear that is the case. Instead it seems UIKit is perfectly
        // happy to function without ever having any UIResponder having had a becomeFirstResponder sent to it. This method seems to work by starting
        // with sender and traveling down the responder chain from there if target==nil. The first object that responds to the given action is sent
        // the message. (or no one is)
        
        // My confusion comes from the fact that motion events and keyboard events are supposed to start with the first responder - but what is that
        // if none was ever set? Apparently the answer is, if none were set, the message doesn't get delivered. If you expicitly set a UIResponder
        // using becomeFirstResponder, then it will receive keyboard/motion events but it does not receive any other messages from other views that
        // happen to end up calling this method with a nil target. So that's a seperate mechanism and I think it's confused a bit in the docs.
        
        // It seems that the reality of message delivery to "first responder" is that it depends a bit on the source. If the source is an external
        // event like motion or keyboard, then there has to have been an explicitly set first responder (by way of becomeFirstResponder) in order for
        // those events to even get delivered at all. If there is no responder defined, the action is simply never sent and thus never received.
        // This is entirely independent of what "first responder" means in the context of a UIControl. Instead, for a UIControl, the first responder
        // is the first UIResponder (including the UIControl itself) that responds to the action. It starts with the UIControl (sender) and not with
        // whatever UIResponder may have been set with becomeFirstResponder.
        
        id responder = sender;
        while (responder) {
            if ([responder respondsToSelector:action]) {
                target = responder;
                break;
            } else if ([responder respondsToSelector:@selector(nextResponder)]) {
                responder = [responder nextResponder];
            } else {
                responder = nil;
            }
        }
    }
    if (target) {
        [target performSelector:action withObject:sender withObject:event];
        return YES;
    } else {
        return NO;
    }
}

- (void)sendEvent:(UIEvent *)event
{
    _UIApplicationSendEvent(event);
}

- (void)_runBackgroundTasks:(void (^)(void))run_tasks
{
    run_tasks();
}

@end

@implementation UIApplication(UIApplicationDeprecated)

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
{
}

@end

#pragma mark - Public functions

#ifdef ANDROID

#ifdef NATIVE_APP

void _UIApplicationMain(struct android_app *app, NSString *appName, NSString *delegateClassName)
{
    _UIApplicationProcessInitialize();
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [[NSProcessInfo processInfo] setProcessName:appName];
    _UIApplicationInitialize();
    engine *myEngine;
    int events;
    struct android_poll_source *source;
    
    myEngine = malloc(sizeof(engine));
    memset(myEngine, 0, sizeof(engine));
    app->userData = myEngine;
    app->onAppCmd = engine_handle_cmd;
    app->onInputEvent = engine_handle_input;
    myEngine->app = app;
    if (app->savedState != NULL) {
        // We are starting with a previous saved state; restore from it.
        myEngine->state = *(saved_state*)app->savedState;
    }
    _application = [[UIApplication alloc] init];
    //UIParentApplicationInitialize();
    Class appDelegateClass = NSClassFromString(delegateClassName);
    id appDelegate = [[appDelegateClass alloc] init];
    _application->_delegate = appDelegate;
    //NSTimeInterval currentTime = CACurrentMediaTime();
    
    _CoreGraphicsInitialize(app);
    
    //_startTime = EAGLCurrentTime();
    while (YES) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runUntilDate:limit];
        [limit release];
        if (ALooper_pollAll(0, NULL, &events, (void**)&source) >= 0) {
            if (source != NULL) {
                source->process(app, source);
            }
            // Check if we are exiting.
            if (app->destroyRequested != 0) {
                engine_term_display(myEngine);
                return;
            }
        }
        UIParentApplicationHandleMessages();
        [pool2 release];
    }
    free(myEngine);
    //UIChildApplicationClose();
    //close(_pipeRead);
    //close(_pipeWrite);
    int status;
    int died = wait(&status);
    DLog(@"died");
    
    [pool release];
}

#else

int UIApplicationMain(int argc, char *argv[], NSString *principalClassName, NSString *delegateClassName)
{
    _UIApplicationProcessInitialize();
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    _UIApplicationInitialize();
    
    int events;
    
    UIChildApplicationInitialize();
    _application = [[UIApplication alloc] init];
    UIChildApplicationSetApplication(_application);
    Class appDelegateClass = NSClassFromString(delegateClassName);
    
    id appDelegate = [[appDelegateClass alloc] init];
    _application->_delegate = appDelegate;
    _UIApplicationInitWindow();
    
    while (YES) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runUntilDate:limit];
        [limit release];
        //ChildPipeMessage pipeMessage = UIChildApplicationHandleMessages();
        //if (pipeMessage) {
        UIChildApplicationHandleMessages();
        [pool2 release];
    }
    DLog(@"outside. exiting");
    UIChildApplicationClosePipes();
    [pool release];
    return 0;
}

#endif

#else // not ANDROID

int UIApplicationMain(int argc, char *argv[], NSString *principalClassName, NSString *delegateClassName)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    _UIApplicationInitialize();
    XInitThreads();
    IOWindow *window = IOWindowCreateSharedWindow();
#ifdef NATIVE_APP
    CGRect cr = CGRectMake(0,0,_kScreenWidth*_kScreenScaleFactor,(_kScreenHeight + _kScreenFooter)*_kScreenScaleFactor);
    CGContextRef ctx = IOWindowCreateContextWithRect(cr);
    UIGraphicsPushContext(ctx);
    BOOL canDraw = NO;
    while (!canDraw) {
        if (IOEventCanDrawWindow(window)) {
            canDraw = YES;
        }
    }
    NSTimeInterval currentTime = CACurrentMediaTime();
    
    _application = [[UIApplication alloc] init];
    Class appDelegateClass = NSClassFromString(delegateClassName);
    id appDelegate = [[appDelegateClass alloc] init];
    _application->_delegate = appDelegate;
    
    _CAAnimatorInitialize();
    [_CAAnimatorConditionLock lockWhenCondition:_CAAnimatorConditionLockHasNoWork];
    [[UIScreen alloc] init];
    [_CAAnimatorConditionLock unlock];
    NSTimeInterval timestamp = CACurrentMediaTime();
    _UIApplicationLaunchApplicationWithDefaultWindow(nil);
    while (YES) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runUntilDate:limit];
        [limit release];
        timestamp = CACurrentMediaTime();
        if (IOEventGetNextEvent(window, _application->_currentEvent)) {
            _UIApplicationSetCurrentEventTouchedView();
            //_application->_lastActivityTime = timestamp;
            _application->_currentEvent->_timestamp = timestamp;
        }
        UINativeApplicationHandleMessages();
        [pool2 release];
        //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
    }
#elif defined(PARENT_APP)
    UIParentApplicationInitialize();
    //DLog();

    CGRect cr = CGRectMake(0,0,_kScreenWidth*_kScreenScaleFactor,_kScreenHeight*_kScreenScaleFactor);
    CGContextRef ctx = IOWindowCreateContextWithRect(cr);
    UIGraphicsPushContext(ctx);
    BOOL canDraw = NO;
    while (!canDraw) {
        if (IOEventCanDrawWindow(window)) {
            canDraw = YES;
        }
    }
    NSTimeInterval currentTime = CACurrentMediaTime();
    
    _application = [[UIApplication alloc] init];
    Class appDelegateClass = NSClassFromString(delegateClassName);
    id appDelegate = [[appDelegateClass alloc] init];
    _application->_delegate = appDelegate;
    //DLog();
    
    _CAAnimatorInitialize();
    [_CAAnimatorConditionLock lockWhenCondition:_CAAnimatorConditionLockHasNoWork];
    [[UIScreen alloc] init];
    [_CAAnimatorConditionLock unlock];
    NSTimeInterval timestamp = CACurrentMediaTime();
    //DLog();
    _UIApplicationLaunchApplicationWithDefaultWindow(nil);

    while (YES) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runUntilDate:limit];
        [limit release];
        timestamp = CACurrentMediaTime();
    //DLog();
        if (IOEventGetNextEvent(window, _application->_currentEvent)) {
            _UIApplicationSetCurrentEventTouchedView();
            //_application->_lastActivityTime = timestamp;
            _application->_currentEvent->_timestamp = timestamp;
        }
        UIParentApplicationHandleMessages();
        [pool2 release];
        //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
    }
#else // Child app
    DLog();
    UIChildApplicationInitialize();
    CGRect cr = CGRectMake(0,0,_kScreenWidth*_kScreenScaleFactor,_kScreenHeight*_kScreenScaleFactor);
    CGContextRef ctx = IOWindowCreateContextWithRect(cr);
    UIGraphicsPushContext(ctx);
    BOOL canDraw = NO;
    while (!canDraw) {
        if (IOEventCanDrawWindow(window)) {
            canDraw = YES;
        }
    }
    //NSTimeInterval currentTime = CACurrentMediaTime();
    _application = [[UIApplication alloc] init];
    UIChildApplicationSetApplication(_application);
    Class appDelegateClass = NSClassFromString(delegateClassName);
    id appDelegate = [[appDelegateClass alloc] init];
    _application->_delegate = appDelegate;
    //DLog(@"4");
    _CAAnimatorInitialize();
    [_CAAnimatorConditionLock lockWhenCondition:_CAAnimatorConditionLockHasNoWork];
    [[UIScreen alloc] init];
    [_CAAnimatorConditionLock unlock];
    
    NSTimeInterval timestamp = CACurrentMediaTime();
    _UIApplicationLaunchApplicationWithDefaultWindow(nil);
    
    while (YES) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        //DLog();
        NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runUntilDate:limit];
        [limit release];
        if (IOEventGetNextEvent(window, _application->_currentEvent)) {
            _UIApplicationSetCurrentEventTouchedView();
            //_application->_lastActivityTime = CACurrentMediaTime();
            _application->_currentEvent->_timestamp = timestamp;
        }
        UIChildApplicationHandleMessages();
        [pool2 release];
        //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
    }
    //[tapGesture release];
    DLog(@"outside. exiting");
    UIChildApplicationClosePipes();
#endif
    [pool release];
}

#endif /* ANDROID */

void _UIApplicationSetCurrentEventTouchedView()
{
    UIEvent *currentEvent = _application->_currentEvent;
    //DLog(@"currentEvent: %@", currentEvent);
    NSSet *touches = [currentEvent allTouches];
    UITouch *touch = [touches anyObject];
    //DLog(@"touch: %@", touch);
    //DLog(@"touch.view: %@", touch.view);
    UIView *previousView = [touch.view retain];
    CGPoint screenLocation = touch->_location;
    UIScreen *theScreen = _application->_keyWindow->_screen;
    UIView *hitView = _UIScreenHitTest(theScreen, screenLocation, currentEvent);
    //DLog(@"hitView: %@", hitView);
    _UITouchSetTouchedView(touch, hitView);
    if (hitView != previousView) {
        UITouchPhase phase = touch.phase;
        //DLog(@"phase: %d", phase);
        if (phase == UITouchPhaseMoved) {
            //DLog(@"phase == UITouchPhaseMoved");
            [previousView touchesMoved:touches withEvent:currentEvent];
        }
    }
    _UIApplicationSendEvent(currentEvent);
    [previousView release];
}

void _UIApplicationSetKeyWindow(UIApplication *application, UIWindow *newKeyWindow)
{
    application->_keyWindow = newKeyWindow;
    //DLog(@"_keyWindow: %@", application->_keyWindow);
}

void _UIApplicationWindowDidBecomeVisible(UIApplication *application, UIWindow *theWindow)
{
    [application->_visibleWindows addObject:[NSValue valueWithNonretainedObject:theWindow]];
}

void _UIApplicationWindowDidBecomeHidden(UIApplication *application, UIWindow *theWindow)
{
    if (theWindow == application->_keyWindow) {
        _UIApplicationSetKeyWindow(application, nil);
    }
    [application->_visibleWindows removeObject:[NSValue valueWithNonretainedObject:theWindow]];
}

BOOL _UIApplicationEnterBackground()
{
    //DLog();
    //DLog(@"_application: %@", _application);
    if (_application->_applicationState != UIApplicationStateBackground) {
        _application->_applicationState = UIApplicationStateBackground;
        if ([_application->_delegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [_application->_delegate applicationDidEnterBackground:_application];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification
                                                            object:_application];
        //_application->_applicationState = UIApplicationStateBackground;
        return YES;
    } else {
        return NO;
    }
}

void _UIApplicationEnterForeground()
{
    //DLog();
    if (_application->_applicationState == UIApplicationStateBackground) {
        if ([_application->_delegate respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [_application->_delegate applicationWillEnterForeground:_application];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                            object:_application];
        _application->_applicationState = UIApplicationStateActive;
        _CALayerSetNeedsComposite(_application->_keyWindow->_layer);
        IOWindowShowWindow();
    }
}

void _UIApplicationSendEvent(UIEvent *event)
{
    for (UITouch *touch in [event allTouches]) {
        //DLog(@"touch: %@", touch);
        [touch.window sendEvent:event];
    }
}

BOOL _UIApplicationRunRunLoopForBackgroundTasksBeforeDate(UIApplication *application, NSDate *date)
{
    // check if all tasks were done, and if so, break
    if ([application->_backgroundTasks count] == 0) {
        return NO;
    }
    // run the runloop in the default mode so things like connections and timers still work for processing our
    // background tasks. we'll make sure not to run this any longer than 1 second at a time, otherwise the alert
    // might hang around for a lot longer than is necessary since we might not have anything to run in the default
    // mode for awhile or something which would keep this method from returning.
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:date];
    // otherwise check if we've timed out and if we are, break
    if ([[NSDate date] timeIntervalSinceReferenceDate] >= [application->_backgroundTasksExpirationDate timeIntervalSinceReferenceDate]) {
        return NO;
    }
    return YES;
}

void _UIApplicationCancelBackgroundTasks(UIApplication* application)
{
    // if there's any remaining tasks, run their expiration handlers
    for (UIBackgroundTask *task in application->_backgroundTasks) {
        if (task.expirationHandler) {
            task.expirationHandler();
        }
    }
    // remove any lingering tasks so we're back to being empty
    [application->_backgroundTasks removeAllObjects];
}

UIResponder *_UIApplicationFirstResponderForScreen(UIApplication* application, UIScreen* screen)
{
    if (application->_keyWindow.screen == screen) {
        return application->_keyWindow->_firstResponder;
    } else {
        return nil;
    }
}

BOOL _UIApplicationSendActionToFirstResponder(UIApplication* application, SEL action, id sender, UIScreen* theScreen)
{
    UIResponder *responder = _UIApplicationFirstResponderForScreen(application, theScreen);
    while (responder) {
        if ([responder respondsToSelector:action]) {
            [responder performSelector:action withObject:sender];
            return YES;
        } else {
            responder = [responder nextResponder];
        }
    }
    return NO;
}

BOOL _UIApplicationFirstResponderCanPerformAction(UIApplication *application, SEL action, id sender, UIScreen *theScreen)
{
    return [_UIApplicationFirstResponderForScreen(application, theScreen) canPerformAction:action withSender:sender];
}

// this is used to cause an interruption/cancel of the current touches.
// Use this when a modal UI element appears (such as a native popup menu), or when a UIPopoverController appears. It seems to make the most sense
// to call _cancelTouches *after* the modal menu has been dismissed, as this causes UI elements to remain in their "pushed" state while the menu
// is being displayed. If that behavior isn't desired, the simple solution is to present the menu from touchesEnded: instead of touchesBegan:.
void _UIApplicationCancelTouches(UIApplication *application)
{
    UIEvent *currentEvent = application->_currentEvent;
    UITouch *touch = [[currentEvent allTouches] anyObject];
    const BOOL wasActiveTouch = TouchIsActive(touch);
    touch->_phase = UITouchPhaseCancelled;    
    if (wasActiveTouch) {
        _UIApplicationSendEvent(currentEvent);
    }
}

// this sets the touches view property to nil (while retaining the window property setting)
// this is used when a view is removed from its superview while it may have been the origin
// of an active touch. after a view is removed, we don't want to deliver any more touch events
// to it, but we still may need to route the touch itself for the sake of gesture recognizers
// so we need to retain the touch's original window setting so that events can still be routed.
//
// note that the touch itself is not being cancelled here so its phase remains unchanged.
// I'm not entirely certain if that's the correct thing to do, but I think it makes sense. The
// touch itself has not gone anywhere - just the view that it first touched. That breaks the
// delivery of the touch events themselves as far as the usual responder chain delivery is
// concerned, but that appears to be what happens in the real UIKit when you remove a view out
// from under an active touch.
//
// this whole thing is necessary because otherwise a gesture which may have been initiated over
// some specific view would end up getting cancelled/failing if the view under it happens to be
// removed. this is more common than you might expect. a UITableView that is not reusing rows
// does exactly this as it scrolls - which coincidentally is how I found this bug in the first
// place. :P
void _UIApplicationRemoveViewFromTouches(UIApplication *application, UIView *aView)
{
    for (UITouch *touch in [application->_currentEvent allTouches]) {
        if (touch.view == aView) {
            _UITouchRemoveFromView(touch);
        }
    }
}

void _UIApplicationTerminate()
{
    if ([_application->_delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
        [_application->_delegate applicationWillTerminate:_application];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification
                                                        object:_application];
    exit(0);
}

