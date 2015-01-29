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
UIChildApplication *_currentMAApplication = nil;
NSMutableArray *_openedApplications;

static NSString *const _kUIChildApplicationPageNumberPath = @"page.pageNumber";
static NSString *const _kUIChildApplicationXLocationPath = @"page.xLocation";
static NSString *const _kUIChildApplicationYLocationPath = @"page.yLocation";
static NSString *const _kUIChildApplicationAnchoredPath = @"page.anchored";
static NSString *const _kUIChildApplicationScorePath = @"application.score";

#pragma mark - Static functions

static void UIChildApplicationRunApp(NSString *appName)
{
    const char *appPath = [[NSString stringWithFormat:@"/data/data/com.myos.myapps/apps/%@.app/%@", appName, appName] cString];
    const char *cAppName = [appName cString];
    //DLog(@"appPath: %s", appPath);
    char *const args[] = {cAppName, NULL};
    const char *myEnv[] = {"LD_LIBRARY_PATH=/data/data/com.myos.myapps/lib:$LD_LIBRARY_PATH", 0};
    execve(appPath, args, myEnv);
    //DLog();
}

@implementation UIChildApplication

@synthesize name=_name;
@synthesize score=_score;
@dynamic pageNumber;
@dynamic xLocation;
@dynamic yLocation;
@dynamic anchored;

#pragma mark - Life cycle

+ (void)initialize
{
    _allApplicationsDictionary = [[NSMutableDictionary alloc] init];
    _openedApplications = CFArrayCreateMutable(kCFAllocatorDefault, 5, &kCFTypeArrayCallBacks);
}

- (id)initWithAppName:(NSString *)name
{
    if ((self=[super init])) {
        _name = name;
        [_allApplicationsDictionary setObject:self forKey:name];
        _opened = NO;
        //_needsScreenCapture = YES;
        NSString *dataPath = [NSString stringWithFormat:@"/data/data/com.myos.myapps/apps/%@.app/data.json", _name];
        NSData *data = [NSData dataWithContentsOfFile:dataPath];
        _data = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL] retain];
        //DLog(@"_data: %@", _data);
        int x = [[_data valueForKeyPath:_kUIChildApplicationXLocationPath] intValue];
        int y = [[_data valueForKeyPath:_kUIChildApplicationYLocationPath] intValue];
        _score = [[_data valueForKeyPath:_kUIChildApplicationScorePath] intValue];
        
        _applicationIcon = [[UIApplicationIcon alloc] initWithApplication:self];
        
        //NSString *imagePath = [NSString stringWithFormat:@"/data/data/com.myos.myapps/apps/%@.app/Default.png", _name];
        //UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        //_screenImageView = nil;//[[UIImageView alloc] initWithImage:image];
        //DLog(@"%@, Loaded _screenImageView: %@", name, _screenImageView);
        
        //DLog(@"x: %d", x);
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_data release];
    [_applicationIcon release];
    [super dealloc];
}

#pragma mark - Accessors

- (int)pageNumber
{
    //DLog(@"self: %p", self);
    return [[_data valueForKeyPath:_kUIChildApplicationPageNumberPath] intValue];
}

- (void)setPageNumber:(int)pageNumber
{
    [_data setValue:[NSNumber numberWithInt:pageNumber] forKeyPath:_kUIChildApplicationPageNumberPath];
}

- (int)xLocation
{
    //DLog();
    return [[_data valueForKeyPath:_kUIChildApplicationXLocationPath] intValue];
}

- (void)setXLocation:(int)x
{
    [_data setValue:[NSNumber numberWithInt:x] forKeyPath:_kUIChildApplicationXLocationPath];
}

- (int)yLocation
{
    //DLog();
    return [[_data valueForKeyPath:_kUIChildApplicationYLocationPath] intValue];
}

- (void)setYLocation:(int)y
{
    [_data setValue:[NSNumber numberWithInt:y] forKeyPath:_kUIChildApplicationYLocationPath];
}

- (BOOL)anchored
{
    //DLog();
    return [[_data valueForKeyPath:_kUIChildApplicationAnchoredPath] boolValue];
}

- (void)setAnchored:(BOOL)anchored
{
    [_data setValue:[NSNumber numberWithBool:anchored] forKeyPath:_kUIChildApplicationAnchoredPath];
}

- (UIImageView *)defaultScreenView
{
    NSString *imagePath = [NSString stringWithFormat:@"/data/data/com.myos.myapps/apps/%@.app/Default.png", _name];
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name: %@; opened: %d; isCurrent: %d; score: %d;>", [self className], self, _name, _opened, [self isCurrent], _score];
    /*return [NSString stringWithFormat:@"<%@: %p; name: %@; opened: %d; isCurrent: %d; score: %d; pageNumber: %d; xLocation: %d; yLocation: %d; anchored: %d>", [self className], self, _name, _opened, [self isCurrent], _score, self.pageNumber, self.xLocation, self.yLocation, self.anchored];*/
}

#pragma mark - Data

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
}

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
    //DLog(@"_name: %@", _name);
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
    //DLog(@"_name: %@", _name);
    long flags;
    _pid = fork();
    //DLog(@"pid: %d", pid);
    if (_pid == 0) {
        flags = fcntl(pipe1[0], F_GETFL);
        fcntl(pipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(pipe1[0], kMainPipeRead);
        dup2(pipe2[1], kMainPipeWrite);
        
        flags = fcntl(animationPipe1[0], F_GETFL);
        fcntl(animationPipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(animationPipe1[0], _kEAGLChildApplicationPipeRead);
        dup2(animationPipe2[1], _kEAGLChildApplicationPipeWrite);
        
        //DLog(@"dup2");
        IOPipeSetPipes(kMainPipeRead, kMainPipeWrite);
        //DLog();
        IOPipeWriteMessage(MLPipeMessageChildIsReady, YES);
        //DLog();
        UIChildApplicationRunApp(_name);
    } else {
        int pipeRead = pipe2[0];
        int pipeWrite = pipe1[1];
        flags = fcntl(pipeRead, F_GETFL);
        fcntl(pipeRead, F_SETFL, flags | O_NONBLOCK);
        
        //DLog();
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
        //DLog();
        CFArrayAppendValue(_openedApplications, self);
        [self setAsCurrent:NO];
        IOPipeWriteMessage(MAPipeMessageCharString, NO);
        IOPipeWriteCharString(_name);
        UIParentApplicationSetChildAppIsRunning(YES);
    }
}

- (BOOL)isCurrent
{
    return (_currentMAApplication == self);
}

- (void)setAsCurrent:(BOOL)withSignal
{
    IOPipeSetPipes(_pipeRead, _pipeWrite);
    _currentMAApplication = self;
    //DLog(@"indexOfObject:_currentMAApplication: %d", _CFArrayGetIndexOfValue(_openedApplications, _currentMAApplication));
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

#pragma mark - Shared functions

void UIChildApplicationSaveData(UIChildApplication *app)
{
    NSString *dataPath = [NSString stringWithFormat:@"/data/data/com.myos.myapps/apps/%@.app/data.json", app->_name];
    //DLog(@"dataPath: %@", dataPath);
    [app->_data setValue:[NSNumber numberWithInt:app->_score] forKeyPath:_kUIChildApplicationScorePath];
    //DLog(@"app->_data: %@", app->_data);
    NSData *data = [NSJSONSerialization dataWithJSONObject:app->_data options:0 error:NULL];
    [data writeToFile:dataPath atomically:YES];
}

void UIChildApplicationClosePipes()
{
    close(kMainPipeRead);
    close(kMainPipeWrite);
}
