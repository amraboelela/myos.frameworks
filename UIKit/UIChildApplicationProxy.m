/*
 Copyright © 2015 myOS Group.
 
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

NSMutableDictionary *_allChildApplicationProxiesDictionary;
UIChildApplicationProxy *_currentChildApplicationProxy = nil;
NSMutableArray *_openedChildApplicationProxies;

#pragma mark - Static functions

static void UIChildApplicationProxyRun(NSString *appName)
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
}

static void UIChildApplicationProxySaveData(UIChildApplicationProxy *app)
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/apps/%@.app/data.json", _NSFileManagerMyAppsPath(), app->_bundleName];
    //DLog(@"dataPath: %@", dataPath);
    //[app->_data setValue:[NSNumber numberWithInt:app->_score] forKey:@"score"];
    //DLog(@"app->_data: %@", app->_data);
    NSData *data = [NSJSONSerialization dataWithJSONObject:app->_data options:0 error:NULL];
    [data writeToFile:dataPath atomically:YES];
}

@implementation UIChildApplicationProxy

@synthesize bundleName=_bundleName;
@synthesize score=_score;
@dynamic name;
@dynamic category;
@dynamic homeIcon;

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
    return [_data valueForKey:@"name"];
}

- (NSString *)category
{
    return [_data valueForKey:@"category"];
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
    //DLog(@"self: %@, running: %d", self, _opened);
    if (_opened) {
        _applicationIcon->_iconLabel.textColor = [UIColor yellowColor];
        _homeIcon->_iconLabel.textColor = [UIColor yellowColor];
    } else {
        _applicationIcon->_iconLabel.textColor = [UIColor whiteColor];
        _homeIcon->_iconLabel.textColor = [UIColor whiteColor];
    }
}

- (UIApplicationIcon *)homeIcon
{
    //DLog();
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
        //UIParentApplicationPresentAppScreen(self, YES);
    } else {
        _CFArrayMoveValueToTop(_openedChildApplicationProxies, self);
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
    //DLog(@"name: %@", self.name);
    //self.opened = YES;
    int pipe1[2];
    int pipe2[2];
    
    int animationPipe1[2];
    int animationPipe2[2];
    if (pipe(pipe1)) {
        ALog(@"Pipe1 failed.");
        return;
    }
    if (pipe(pipe2)) {
        ALog(@"Pipe2 failed.");
        return;
    }
    if (pipe(animationPipe1)) {
        ALog(@"AnimationPipe1 failed.");
        return;
    }
    if (pipe(animationPipe2)) {
        ALog(@"AnimationPipe2 failed.");
        return;
    }
    long flags;
    _pid = fork();
    //DLog(@"pid: %d", _pid);
    if (_pid == 0) { // Child process
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
        
        //DLog(@"dup2");
        IOPipeSetPipes(kMainPipeRead, kMainPipeWrite);
        IOPipeWriteMessage(MLPipeMessageChildIsReady, YES);
        //DLog();
        UIChildApplicationProxyRun(_bundleName);
    } else { // Parent process
        int pipeRead = pipe2[0];
        int pipeWrite = pipe1[1];
        flags = fcntl(pipeRead, F_GETFL);
        fcntl(pipeRead, F_SETFL, flags | O_NONBLOCK);
        
        close(pipe1[0]);
        close(pipe2[1]);
        
        int animationPipeRead = animationPipe2[0];
        int animationPipeWrite = animationPipe1[1];
        flags = fcntl(animationPipeRead, F_GETFL);
        fcntl(animationPipeRead, F_SETFL, flags | O_NONBLOCK);
        close(animationPipe1[0]);
        close(animationPipe2[1]);
        
        //IOPipeSetPipes(pipeRead, pipeWrite);
        _pipeRead = pipeRead;
        _pipeWrite = pipeWrite;
        _animationPipeRead = animationPipeRead;
        _animationPipeWrite = animationPipeWrite;
        //DLog();
        CFArrayAppendValue(_openedChildApplicationProxies, self);
        [self setAsCurrent:NO];

        IOPipeWriteMessage(MAPipeMessageCharString, NO);
        IOPipeWriteCharString(_bundleName);
#ifndef ANDROID
//#else
        IOPipeWriteMessage(MAPipeMessageInt, NO);
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
#ifdef NATIVE_APP
#ifdef ANDROID
    EAGLParentSetPipes(_animationPipeRead, _animationPipeWrite);
#endif
    if (withSignal) {
        kill(_pid, SIGALRM);
    }
#endif
    _score++;
}

- (void)gotoBackground
{
    //DLog(@"self: %@", self);
    if (_running) {
        //DLog(@"_running");
        _running = NO;
        IOPipeWriteMessage(MAPipeMessageWillEnterBackground, YES);
    }
}

- (void)terminate
{
    DLog(@"%@", self);
    self.opened = NO;
    UIChildApplicationProxySaveData(self);
    kill(_pid, SIGTERM);
    if (wait(NULL) == -1) {
        ALog(@"wait error");
    }
}

@end
