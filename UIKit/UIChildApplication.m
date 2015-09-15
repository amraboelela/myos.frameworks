/*
 Copyright © 2014-2015 myOS Group.
 
 This file is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This file is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 Contributor(s):
 Amr Aboelela <amraboelela@gmail.com>
 */

#import <fcntl.h>
#import <UIKit/UIKit-private.h>
#import <IOKit/IOKit.h>
#import <OpenGLES/EAGL-private.h>
#import <CoreGraphics/CoreGraphics-private.h>

NSMutableDictionary *_allApplicationsDictionary;
UIChildApplication *_currentChildApplication = nil;
NSMutableArray *_openedApplications;
UIApplication *_application = nil;


#pragma mark - Static functions

static void UIChildApplicationTerminate()
{
    if ([_application->_delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
        [_application->_delegate applicationWillTerminate:_application];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification
                                                        object:_application];
    exit(0);
}

static void UIChildApplicationSignal(int sig)
{
    int status;
    pid_t pid;
    
    //DLog(@"Signal %d", sig);
    switch (sig) {
        case SIGALRM:
            //DLog(@"SIGALRM");
            //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
            break;
        case SIGTERM:
            //DLog(@"SIGTERM");
            UIChildApplicationTerminate();
            break;
        default:
            break;
    }
}

static void UIChildApplicationRunApp(NSString *appName)
{
    const char *appPath = [[NSString stringWithFormat:@"%@/apps/%@.app/%@", _NSFileManagerMyAppsPath(), appName, appName] cString];
    const char *cAppName = [appName cString];
    //DLog(@"appPath: %s", appPath);
    char *const args[] = {cAppName, NULL};
#ifdef ANDROID
    const char *myEnv[] = {"LD_LIBRARY_PATH=/data/data/com.myos.myapps/lib:$LD_LIBRARY_PATH", 0};
#else
    const char *myEnv = NULL;
#endif
    execve(appPath, args, myEnv);
    //DLog();
}

@implementation UIChildApplication

@synthesize bundleName=_bundleName;
@synthesize score=_score;
@dynamic name;
@dynamic category;
@dynamic homeIcon;
//@dynamic yLocation;
//@dynamic anchored;

#pragma mark - Life cycle

+ (void)initialize
{
    _allApplicationsDictionary = [[NSMutableDictionary alloc] init];
    _openedApplications = CFArrayCreateMutable(kCFAllocatorDefault, 5, &kCFTypeArrayCallBacks);
}

- (id)initWithBundleName:(NSString *)bundleName
{
    if ((self=[super init])) {
        _bundleName = [bundleName retain];
        [_allApplicationsDictionary setObject:self forKey:_bundleName];
        _opened = NO;
        //_needsScreenCapture = YES;
        NSString *dataPath = [NSString stringWithFormat:@"%@/apps/%@.app/data.json", _NSFileManagerMyAppsPath(), _bundleName];
        NSData *data = [NSData dataWithContentsOfFile:dataPath];
        _data = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL] retain];
        //DLog(@"_data: %@", _data);
        //int x = [[_data valueForKey:@"xLocation"] intValue];
        //int y = [[_data valueForKey:@"yLocation"] intValue];
        //_score = [[_data valueForKey:@"score"] intValue];
        
        _applicationIcon = [[UIApplicationIcon alloc] initWithApplication:self];
        
        //NSString *imagePath = [NSString stringWithFormat:@"/data/data/com.myos.myapps/apps/%@.app/Default.png", _bundleName];
        //UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        //_screenImageView = nil;//[[UIImageView alloc] initWithImage:image];
        //DLog(@"%@, Loaded _screenImageView: %@", name, _screenImageView);
        
        //DLog(@"x: %d", x);
    }
    return self;
}

- (void)dealloc
{
    [_bundleName release];
    [_data release];
    [_applicationIcon release];
    [_homeIcon release];
    [super dealloc];
}

#pragma mark - Accessors

/*
- (int)pageNumber
{
    return [[_data valueForKey:@"pageNumber"] intValue];
}

- (void)setPageNumber:(int)pageNumber
{
    [_data setValue:[NSNumber numberWithInt:pageNumber] forKey:@"pageNumber"];
}*/

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    id dataValue = [_data valueForKey:key];
    if (!dataValue) {
        [super setValue:value forUndefinedKey:key];
    } else {
        [_data setValue:value forKey:key];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{
    //DLog(@"key: %@", key);
    id result = [_data valueForKey:key];
    if (!result) {
        return [super valueForUndefinedKey:key];
    } else {
        return result;
    }
}

- (NSString *)name
{
    //DLog();
    return [_data valueForKey:@"name"];
}

- (NSString *)category
{
    //DLog();
    return [_data valueForKey:@"category"];
}

/*
- (void)setXLocation:(int)x
{
    [_data setValue:[NSNumber numberWithInt:x] forKey:@"xLocation"];
}

- (int)yLocation
{
    //DLog();
    return [[_data valueForKey:@"yLocation"] intValue];
}

- (void)setYLocation:(int)y
{
    [_data setValue:[NSNumber numberWithInt:y] forKey:@"yLocation"];
}

- (BOOL)anchored
{
    //DLog();
    return [[_data valueForKeyPath:_kUIChildApplicationAnchoredPath] boolValue];
}

- (void)setAnchored:(BOOL)anchored
{
    [_data setValue:[NSNumber numberWithBool:anchored] forKeyPath:_kUIChildApplicationAnchoredPath];
}*/

- (UIImageView *)defaultScreenView
{
    NSString *imagePath = [NSString stringWithFormat:@"%@/apps/%@.app/Default.png", _NSFileManagerMyAppsPath(), _bundleName];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return [[[UIImageView alloc] initWithImage:image] autorelease];
    //return [[[UIImageView alloc] init] autorelease];
}

- (BOOL)opened
{
    return _opened;
}

- (void)setOpened:(BOOL)newValue
{
    //[self willChangeValueForKey:@"running"];
    _opened = newValue;
    //DLog(@"self: %@, running: %d", self, _opened);
    if (_opened) {
        _applicationIcon->_iconLabel.textColor = [UIColor yellowColor];
    } else {
        _applicationIcon->_iconLabel.textColor = [UIColor whiteColor];
        //DLog(@"self: %@", self);
    }
}

- (UIApplicationIcon *)homeIcon
{
    if (!_homeIcon) {
        _homeIcon = [[UIApplicationIcon alloc] initWithApplication:self];
    }
    return _homeIcon;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name: %@; opened: %d; isCurrent: %d; score: %d;>", [self className], self, self.name, _opened, [self isCurrent], _score];
}

#pragma mark - Data

/*
- (void)swapLocationWithApp:(UIChildApplication *)anotherApp
{
    int tempPageNumber = self.pageNumber;
    self.pageNumber = anotherApp.pageNumber;
    anotherApp.pageNumber = tempPageNumber;
    int tempX = self.xLocation;
    int tempY = self.yLocation;
    self.xLocation = anotherApp.xLocation;
    self.yLocation = anotherApp.yLocation;
    anotherApp.xLocation = tempX;
    anotherApp.yLocation = tempY;
}*/

#pragma mark - Delegates
/*
- (void)closeApp
{
    DLog(@"self: %@", self);
}*/

- (void)deleteApp
{
    DLog(@"self: %@", self);
}

- (void)showMenu
{
    DLog(@"self: %@", self);
}

#pragma mark - Actions

- (void)singleTapped
{
    //DLog();
    if (!_opened) {
        self.opened = YES;
        [self performSelector:@selector(presentAppScreen) withObject:nil afterDelay:0.01];
        //UIParentApplicationPresentAppScreen(self, YES);
    } else {
        //DLog();
        _CFArrayMoveValueToTop(_openedApplications, self);
        UIParentApplicationPresentAppScreen(self, NO);
    }
}

- (void)presentAppScreen
{
    UIParentApplicationPresentAppScreen(self, YES);
}

#pragma mark - Public methods

- (void)startApp
{
    //return;
    //DLog(@"name: %@", self.name);
    //self.opened = YES;
    int pipe1[2];
    int pipe2[2];
    
    int animationPipe1[2];
    int animationPipe2[2];
    if (pipe(pipe1)) {
        NSLog(@"Pipe1 failed.");
        return;
    }
    if (pipe(pipe2)) {
        NSLog(@"Pipe2 failed.");
        return;
    }
    if (pipe(animationPipe1)) {
        NSLog(@"Pipe1 failed.");
        return;
    }
    if (pipe(animationPipe2)) {
        NSLog(@"Pipe2 failed.");
        return;
    }
    //DLog(@"name: %@", self.name);
    long flags;
    _pid = fork();
    DLog(@"pid: %d", _pid);
    if (_pid == 0) {
        flags = fcntl(pipe1[0], F_GETFL);
        fcntl(pipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(pipe1[0], kMainPipeRead);
        dup2(pipe2[1], kMainPipeWrite);
        
        flags = fcntl(animationPipe1[0], F_GETFL);
        fcntl(animationPipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(animationPipe1[0], _kEAGLChildPipeRead);
        dup2(animationPipe2[1], _kEAGLChildPipeWrite);
        
        DLog(@"dup2");
        IOPipeSetPipes(kMainPipeRead, kMainPipeWrite);
        DLog();
        IOPipeWriteMessage(MLPipeMessageChildIsReady, YES);
        DLog();
        UIChildApplicationRunApp(_bundleName);
    } else {
        int pipeRead = pipe2[0];
        int pipeWrite = pipe1[1];
        flags = fcntl(pipeRead, F_GETFL);
        fcntl(pipeRead, F_SETFL, flags | O_NONBLOCK);
        
        DLog();
        close(pipe1[0]);
        close(pipe2[1]);
        
        int animationPipeRead = animationPipe2[0];
        int animationPipeWrite = animationPipe1[1];
        flags = fcntl(animationPipeRead, F_GETFL);
        fcntl(animationPipeRead, F_SETFL, flags | O_NONBLOCK);
        //DLog();
        close(animationPipe1[0]);
        close(animationPipe2[1]);
        
        //IOPipeSetPipes(pipeRead, pipeWrite);
        _pipeRead = pipeRead;
        _pipeWrite = pipeWrite;
        _animationPipeRead = animationPipeRead;
        _animationPipeWrite = animationPipeWrite;
        DLog();
        CFArrayAppendValue(_openedApplications, self);
        [self setAsCurrent:NO];
        IOPipeWriteMessage(MAPipeMessageCharString, NO);
        IOPipeWriteCharString(_bundleName);
        UIParentApplicationSetChildAppIsRunning(YES);
    }
}

- (BOOL)isCurrent
{
    return (_currentChildApplication == self);
}

- (void)setAsCurrent:(BOOL)withSignal
{
    IOPipeSetPipes(_pipeRead, _pipeWrite);
    _currentChildApplication = self;
    //DLog(@"indexOfObject:_currentChildApplication: %d", _CFArrayGetIndexOfValue(_openedApplications, _currentChildApplication));
    _running = YES;
    //DLog(@"self: %@", self);
#ifdef NATIVE_APP
    EAGLParentSetPipes(_animationPipeRead, _animationPipeWrite);
    if (withSignal) {
        kill(_pid, SIGALRM);
    }
#endif
    _score++;
}

- (void)gotoBackground
{
    _running = NO;
    IOPipeWriteMessage(MAPipeMessageWillEnterBackground, YES);
}

- (void)terminate
{
    DLog(@"%@", self);
    self.opened = NO;
    UIChildApplicationSaveData(self);
    kill(_pid, SIGTERM);
    if (wait(NULL) == -1) {
        NSLog(@"wait error");
    }
}

@end

#pragma mark - Public functions

void UIChildApplicationInitialize()
{
    DLog();
    //_UINavigationItemInitialize();
    IOPipeSetPipes(kMainPipeRead, kMainPipeWrite);
    
    MAPipeMessage message = IOPipeReadMessage();
    DLog(@"message: %d", message);
#ifdef ANDROID
    _processName = @"ProcessName";
    if (message == MAPipeMessageCharString) {
        _processName = [IOPipeReadCharString() retain];
        DLog(@"processName: %@", _processName);
        [[NSProcessInfo processInfo] setProcessName:_processName];
        [[NSBundle mainBundle] reInitialize];
        _CGDataProviderSetChildAppName(_processName);
    } else {
        //DLog(@"message: %d", message);
        NSLog(@"Error can't get process name");
    }
#endif
    (void)signal(SIGALRM, UIChildApplicationSignal);
    (void)signal(SIGTERM, UIChildApplicationSignal);
}

void UIChildApplicationSetApplication(UIApplication *application)
{
    DLog(@"application: %@", application);
    _application = application;
}

int UIChildApplicationHandleMessages()
{
    int message = IOPipeReadMessage();
    //DLog();
    switch (message) {
        case MAPipeMessageEndOfMessage:
            break;
        case MAPipeMessageEventActionDown:
        case MAPipeMessageEventActionMoved:
        case MAPipeMessageEventActionUp: {
            UITouch *touch = [[_application->_currentEvent allTouches] anyObject];
            UIScreen *screen = _UIScreenMainScreen();
            float x = IOPipeReadFloat();
            float y = IOPipeReadFloat();
            //DLog(@"screenLocation: x:%0.0f, y:%0.0f", x, y);
            CGPoint screenLocation = CGPointMake(x, y);
            NSTimeInterval timestamp = CACurrentMediaTime();
            _application->_currentEvent->_timestamp = timestamp;
            switch (message) {
                case MAPipeMessageEventActionDown: {
                    //DLog(@"MAPipeMessageEventActionDown");
                    CGPoint delta = CGPointZero;
                    int tapCount = 1;
                    NSTimeInterval timeDiff = fabs(touch.timestamp - timestamp);
                    if (touch.phase == UITouchPhaseEnded && timeDiff < _kUIEventTimeDiffMax) {
                        tapCount = touch.tapCount+1;
                    }
                    _UITouchSetPhase(touch, UITouchPhaseBegan, screenLocation, tapCount, delta, timestamp);
                    break;
                }
                case MAPipeMessageEventActionMoved:
                    //DLog(@"MAPipeMessageEventActionMoved");
                    _UITouchUpdatePhase(touch, UITouchPhaseMoved, screenLocation, timestamp);
                    break;
                case MAPipeMessageEventActionUp:
                    //DLog(@"screenLocation: x:%0.0f, y:%0.0f", x, y);
                    //DLog(@"MAPipeMessageEventActionUp");
                    _UITouchUpdatePhase(touch, UITouchPhaseEnded, screenLocation, timestamp);
                    break;
                default:
                    break;
            }
            _UIApplicationSetCurrentEventTouchedView();
            break;
        }
        case MAPipeMessageWillEnterBackground:
            _UIApplicationEnterBackground();
            pause();
            //DLog(@"_application: %@", _application);
            //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
            _UIApplicationEnterForeground();
            break;
            /*case MAPipeMessageHello:
             DLog(@"MAPipeMessageHello");
             break;*/
        case MAPipeMessageTerminateApp:
            DLog(@"MAPipeMessageTerminateApp");
            IOPipeWriteMessage(MLPipeMessageTerminateApp, YES);
            UIChildApplicationTerminate();
            //return MAPipeMessageTerminateApp;
        default:
            break;
    }
    return 0;
}

void UIChildApplicationSaveData(UIChildApplication *app)
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/apps/%@.app/data.json", _NSFileManagerMyAppsPath(), app->_bundleName];
    //DLog(@"dataPath: %@", dataPath);
    //[app->_data setValue:[NSNumber numberWithInt:app->_score] forKey:@"score"];
    //DLog(@"app->_data: %@", app->_data);
    NSData *data = [NSJSONSerialization dataWithJSONObject:app->_data options:0 error:NULL];
    [data writeToFile:dataPath atomically:YES];
    //DLog();
}

void UIChildApplicationClosePipes()
{
    close(kMainPipeRead);
    close(kMainPipeWrite);
}
