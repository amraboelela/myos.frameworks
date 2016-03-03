/*
 Copyright © 2015-2016 myOS Group.
 
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
#import <UIKit/UIChildApplicationProxy.h>
#import <UIKit/UIKit-private.h>
#import <UIKit/UIChildApplication.h>
#import <IOKit/IOKit.h>
#import <OpenGLES/EAGL-private.h>
#import <CoreGraphics/CoreGraphics-private.h>

NSMutableDictionary *_allChildApplicationProxiesDictionary;
UIChildApplicationProxy *_currentChildApplicationProxy = nil;
NSMutableArray *_openedChildApplicationProxies;

#pragma mark - Static functions

static void UIChildApplicationProxyRunApp(UIChildApplicationProxy *childAppProxy, BOOL coldStart)
{
    //DLog();
    //_launcherView.hidden = YES;
    if (coldStart) {
        //UIParentApplicationCheckMemory();
        //[_childAppView addSubview:childAppProxy.defaultScreenView];
#ifdef ANDROID
        long freeMemory = CFGetFreeMemory();
        //DLog(@"%@ Free memory: %ld KB", childApp->_bundleName, freeMemory);
        if (freeMemory > _freeMemory && (_freeMemoryCount % 2 == 0) ||
            freeMemory < 5000 && (_freeMemoryCount % 2 == 1)) {
            DLog(@"Low memory");
            UIParentApplicationTerminateSomeApps();
            freeMemory = CFGetFreeMemory();
            DLog(@"%@ Free memory 2: %ld KB", childAppProxy->_bundleName, freeMemory);
        }
        _freeMemory = freeMemory;
#endif
        [childAppProxy startApp];
    } else {
        [childAppProxy setAsCurrent:YES];
    }
    _UIApplicationEnterBackground();
#if defined(ANDROID) && defined(NATIVE_APP)
    [_CAAnimatorNAConditionLock unlockWithCondition:_CAAnimatorConditionLockHasWork];
#endif
}

static void UIChildApplicationProxyRun(NSString *appName)
{
    const char *appWithFullPath = [[NSString stringWithFormat:@"%@/apps/%@.app/%@", _NSFileManagerMyAppsPath(), appName, appName] cString];
    const char *cAppName = [appName cString];
    //DLog(@"appPath: %s", appPath);
    char *const args[] = {cAppName, NULL};
#ifdef ANDROID
    const char *myEnv[] = {"LD_LIBRARY_PATH=/data/data/com.myos.myapps/lib:$LD_LIBRARY_PATH", 0};
#else
    const char *myEnv[] = {"LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH", 0};
#endif
    execve(appWithFullPath, args, myEnv);
}

@implementation UIChildApplicationProxy

@synthesize bundleName=_bundleName;
@synthesize score=_score;
//@dynamic name;
@dynamic category;
@dynamic homePageIcon;

#pragma mark - Life cycle

+ (void)initialize
{
    _allChildApplicationProxiesDictionary = [[NSMutableDictionary alloc] init];
    _openedChildApplicationProxies = CFArrayCreateMutable(kCFAllocatorDefault, 5, &kCFTypeArrayCallBacks);
}

- (id)initWithBundleName:(NSString *)bundleName
{
    if ((self=[super init])) {
        _bundleName = [bundleName retain];
        [_allChildApplicationProxiesDictionary setObject:self forKey:_bundleName];
        _opened = NO;
        NSString *infoPath = [NSString stringWithFormat:@"%@/apps/%@.app/Info.plist", _NSFileManagerMyAppsPath(), _bundleName];
        _info = [[NSDictionary dictionaryWithContentsOfFile:infoPath] retain];
        
        //NSData *infoData = [NSData dataWithContentsOfFile:infoPath];
        //_data = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL] retain];
        
        _applicationIcon = [[UIApplicationIcon alloc] initWithApplication:self];
    }
    return self;
}

- (void)dealloc
{
    [_bundleName release];
    [_info release];
    [_applicationIcon release];
    [_homePageIcon release];
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)name
{
    return [_info valueForKey:@"CFBundleDisplayName"];
}

- (NSString *)category
{
    return [_info valueForKey:@"LSApplicationCategoryType"];
}

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
    DLog(@"self: %@, opened: %d", self, _opened);
    if (_opened) {
        _applicationIcon->_iconLabel.textColor = [UIColor yellowColor];
        _homePageIcon->_iconLabel.textColor = [UIColor yellowColor];
    } else {
        _applicationIcon->_iconLabel.textColor = [UIColor whiteColor];
        _homePageIcon->_iconLabel.textColor = [UIColor whiteColor];
    }
}

- (UIApplicationIcon *)homePageIcon
{
    //DLog();
    if (!_homePageIcon) {
        _homePageIcon = [[UIApplicationIcon alloc] initWithApplication:self];
    }
    return _homePageIcon;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name: %@; opened: %d; isCurrent: %d; score: %d;>", [self className], self, self.bundleName, _opened, [self isCurrent], _score];
}

#pragma mark - Data


#pragma mark - Delegates

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
        //UIChildApplicationProxyRunApp(self, YES);
    } else {
        _CFArrayMoveValueToTop(_openedChildApplicationProxies, self);
        UIChildApplicationProxyRunApp(self, NO);
    }
}

- (void)presentAppScreen
{
    UIChildApplicationProxyRunApp(self, YES);
}

#pragma mark - Public methods

- (void)startApp
{
    //DLog(@"name: %@", self.name);
    //self.opened = YES;
    int pipe1[2];
    int pipe2[2];
    
    if (pipe(pipe1)) {
        ALog(@"Pipe1 failed.");
        return;
    }
    if (pipe(pipe2)) {
        ALog(@"Pipe2 failed.");
        return;
    }
    
#ifdef ANDROID
    int animationPipe1[2];
    int animationPipe2[2];

    if (pipe(animationPipe1)) {
        ALog(@"AnimationPipe1 failed.");
        return;
    }
    if (pipe(animationPipe2)) {
        ALog(@"AnimationPipe2 failed.");
        return;
    }
#endif
    
    long flags;
    _pid = fork();
    //DLog(@"pid: %d", _pid);
    if (_pid == 0) { // Child process
        flags = fcntl(pipe1[0], F_GETFL);
        fcntl(pipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(pipe1[0], ChildApplicationPipeRead);
        dup2(pipe2[1], ChildApplicationPipeWrite);
        
#ifdef ANDROID
        flags = fcntl(animationPipe1[0], F_GETFL);
        fcntl(animationPipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(animationPipe1[0], _kEAGLChildPipeRead);
        dup2(animationPipe2[1], _kEAGLChildPipeWrite);
#endif
        //DLog(@"dup2");
        IOPipeSetPipes(ChildApplicationPipeRead, ChildApplicationPipeWrite);
        IOPipeWriteMessage(ParentPipeMessageChildIsReady, YES);
        //DLog();
        UIChildApplicationProxyRun(_bundleName);
    } else { // Parent process
        int pipeRead = pipe2[0];
        int pipeWrite = pipe1[1];
        flags = fcntl(pipeRead, F_GETFL);
        fcntl(pipeRead, F_SETFL, flags | O_NONBLOCK);
        
        close(pipe1[0]);
        close(pipe2[1]);
        
        //IOPipeSetPipes(pipeRead, pipeWrite);
        _pipeRead = pipeRead;
        _pipeWrite = pipeWrite;
#ifdef ANDROID
        int animationPipeRead = animationPipe2[0];
        int animationPipeWrite = animationPipe1[1];
        flags = fcntl(animationPipeRead, F_GETFL);
        fcntl(animationPipeRead, F_SETFL, flags | O_NONBLOCK);
        close(animationPipe1[0]);
        close(animationPipe2[1]);
        _animationPipeRead = animationPipeRead;
        _animationPipeWrite = animationPipeWrite;
        //DLog();
#endif
        CFArrayAppendValue(_openedChildApplicationProxies, self);
        [self setAsCurrent:NO];

        IOPipeWriteMessage(ChildPipeMessageCharString, NO);
        IOPipeWriteCharString(_bundleName);
#ifndef ANDROID
//#else
        IOPipeWriteMessage(ChildPipeMessageCharString, NO);
        IOPipeWriteCharString(_NSFileManagerMyAppsPath());
        IOPipeWriteMessage(ChildPipeMessageInt, NO);
        IOPipeWriteInt(IOWindowGetID());
#endif
        UIParentApplicationSetChildAppIsRunning(YES);
    }
}

- (BOOL)isCurrent
{
    return (_currentChildApplicationProxy == self);
}

- (void)setAsCurrent:(BOOL)withSignal
{
    IOPipeSetPipes(_pipeRead, _pipeWrite);
    _currentChildApplicationProxy = self;
    //DLog(@"indexOfObject:_currentChildApplicationProxy: %d", _CFArrayGetIndexOfValue(_openedChildApplicationProxies, _currentChildApplicationProxy));
    _running = YES;
    //DLog(@"self: %@", self);
//#ifdef NATIVE_APP
#ifdef ANDROID
    EAGLParentSetPipes(_animationPipeRead, _animationPipeWrite);
#endif
    if (withSignal) {
        kill(_pid, SIGALRM);
    }
//#endif
    _score++;
}

- (void)gotoBackground
{
    //DLog(@"self: %@", self);
    if (_running) {
        //DLog(@"_running");
        _running = NO;
        IOPipeWriteMessage(ChildPipeMessageWillEnterBackground, YES);
    }
}

- (void)terminate
{
    DLog(@"%@", self);
    self.opened = NO;
    //UIChildApplicationProxySaveData(self);
    kill(_pid, SIGTERM);
    if (wait(NULL) == -1) {
        ALog(@"wait error");
    }
}

@end
