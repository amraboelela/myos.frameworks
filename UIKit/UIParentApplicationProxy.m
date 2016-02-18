/*
 Copyright © 2016 myOS Group.
 
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
#import <UIKit/UIParentApplicationProxy.h>
#import <UIKit/UIParentApplication.h>
#import <IOKit/IOKit.h>
//#import <OpenGLES/EAGL-private.h>
#import <CoreGraphics/CoreGraphics-private.h>

#pragma mark - Static functions

static void UIParentApplicationProxyRun(NSString *appName, NSString *appPath)
{
    const char *appWithFullPath = [[NSString stringWithFormat:@"%@/%@", appPath, appName] cString];
    const char *cAppName = [appName cString];
    DLog(@"appPath: %s", appPath);
    char *const args[] = {cAppName, NULL};
    const char *myEnv[] = {"LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH", 0};
    execve(appWithFullPath, args, myEnv);
}

@implementation UIParentApplicationProxy

@synthesize bundleName=_bundleName;
@synthesize bundlePath=_bundlePath;

#pragma mark - Life cycle
 
- (id)initWithBundleName:(NSString *)bundleName andPath:(NSString *)path
{
    if ((self=[super init])) {
        _bundleName = [bundleName retain];
        _bundlePath = [path retain];
    }
    return self;
}

- (void)dealloc
{
    [_bundleName release];
    [_bundlePath release];
    [super dealloc];
}

#pragma mark - Accessors

#pragma mark - Actions

#pragma mark - Public methods

- (void)startApp
{
    DLog(@"name: %@", self.name);
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
    
    long flags;
    _pid = fork();
    DLog(@"pid: %d", _pid);
    if (_pid == 0) { // Child process
        flags = fcntl(pipe1[0], F_GETFL);
        fcntl(pipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(pipe1[0], ParentApplicationPipeRead);
        dup2(pipe2[1], ParentApplicationPipeWrite);
        
        //DLog(@"dup2");
        IOPipeSetPipes(ParentApplicationPipeRead, ParentApplicationPipeWrite);
        //IOPipeWriteMessage(ParentPipeMessageChildIsReady, YES);
        //DLog();
        UIParentApplicationProxyRun(_bundleName, _bundlePath);
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

        //CFArrayAppendValue(_openedChildApplicationProxies, self);
        [self setAsCurrent:NO];

        IOPipeWriteMessage(ParentPipeMessageCharString, NO);
        IOPipeWriteCharString(_bundleName);
//#ifndef ANDROID
//#else
        //IOPipeWriteMessage(ChildPipeMessageCharString, NO);
        //IOPipeWriteCharString(_NSFileManagerMyAppsPath());
        IOPipeWriteMessage(ParentPipeMessageInt, NO);
        IOPipeWriteInt(IOWindowGetID());
//#endif
        //UIParentApplicationSetChildAppIsRunning(YES);
    }
}

/*
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
    DLog(@"self: %@", self);
}*/

- (void)terminate
{
    DLog(@"%@", self);
    /*self.opened = NO;
    UIChildApplicationProxySaveData(self);
    kill(_pid, SIGTERM);
    if (wait(NULL) == -1) {
        ALog(@"wait error");
    }*/
}

@end
