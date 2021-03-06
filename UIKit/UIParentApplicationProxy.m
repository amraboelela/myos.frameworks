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
#import <CoreGraphics/CoreGraphics-private.h>

UIParentApplicationProxy *_currentParentApplicationProxy = nil;
NSMutableArray *_openedParentApplicationProxies;

#pragma mark - Static functions

static void UIParentApplicationProxyRun(NSString *appName, NSString *appPath)
{
    const char *appWithFullPath = [[NSString stringWithFormat:@"%@/%@", appPath, appName] cString];
    const char *cAppName = [appName cString];
    //DLog(@"appPath: %@", appPath);
    //DLog(@"appWithFullPath: %s", appWithFullPath);
    char *const args[] = {cAppName, NULL};
    const char *myEnv[] = {"LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH", 0};
    execve(appWithFullPath, args, myEnv);
}

@implementation UIParentApplicationProxy

@synthesize bundleName=_bundleName;
@synthesize bundlePath=_bundlePath;

#pragma mark - Life cycle

+ (void)initialize
{
    //_allChildApplicationProxiesDictionary = [[NSMutableDictionary alloc] init];
    _openedParentApplicationProxies = CFArrayCreateMutable(kCFAllocatorDefault, 5, &kCFTypeArrayCallBacks);
}

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
    //DLog(@"bundleName: %@", self.bundleName);
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
    if (_pid == 0) { // Child process
        flags = fcntl(pipe1[0], F_GETFL);
        fcntl(pipe1[0], F_SETFL, flags | O_NONBLOCK);
        //dup(mypipe[0]);
        dup2(pipe1[0], ParentApplicationPipeRead);
        dup2(pipe2[1], ParentApplicationPipeWrite);
        
        //DLog(@"dup2");
        //IOPipeSetPipes(ParentApplicationPipeRead, ParentApplicationPipeWrite);
        IOPipeWriteMessageWithPipe(NativePipeMessageParentIsReady, YES, ParentApplicationPipeWrite);
        UIParentApplicationProxyRun(_bundleName, _bundlePath);
    } else { // Parent process
        //DLog(@"pid: %d", _pid);
        int pipeRead = pipe2[0];
        int pipeWrite = pipe1[1];
        flags = fcntl(pipeRead, F_GETFL);
        fcntl(pipeRead, F_SETFL, flags | O_NONBLOCK);
        
        close(pipe1[0]);
        close(pipe2[1]);
        
        //IOPipeSetPipes(pipeRead, pipeWrite);
        _pipeRead = pipeRead;
        _pipeWrite = pipeWrite;

        CFArrayAppendValue(_openedParentApplicationProxies, self);
        [self setAsCurrent:NO];

        IOPipeWriteMessage(ParentPipeMessageCharString, NO);
        IOPipeWriteCharString(_bundleName);
        //DLog(@"_bundleName: %@", _bundleName);
        IOPipeWriteMessage(ParentPipeMessageCharString, NO);
        IOPipeWriteCharString(_NSFileManagerMyAppsPath());
        //DLog(@"_NSFileManagerMyAppsPath(): %@", _NSFileManagerMyAppsPath());
        IOPipeWriteMessage(ParentPipeMessageInt, NO);
        IOPipeWriteInt(IOWindowGetID());
        //DLog(@"IOWindowGetID(): %@", IOWindowGetID());
        UINativeApplicationSetParentAppIsRunning(YES);
    }
}

- (BOOL)isCurrent
{
    return (_currentParentApplicationProxy == self);
}

- (void)setAsCurrent:(BOOL)withSignal
{
    IOPipeSetPipes(_pipeRead, _pipeWrite);
    _currentParentApplicationProxy = self;
    _running = YES;
    //DLog(@"self: %@", self);
    if (withSignal) {
        kill(_pid, SIGALRM);
    }
}

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
