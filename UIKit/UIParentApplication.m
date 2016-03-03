/*
 Copyright © 2014-2016 myOS Group.
 
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

#import <UIKit/UIParentApplication.h>
#import <UIKit/UIKit-private.h>
#import <UIKit/UIChildApplicationProxy.h>
#import <IOKit/IOKit.h>
#import <CoreFoundation/CoreFoundation-private.h>

#define _kTerminateChildTimeOut         2.0

static BOOL _childAppRunning = NO;
//static UIParentApplication *_mlApp = nil;
static CFTimeInterval _startTime;
static UIParentApplication *_UIParentApplication = nil;
static long _freeMemory = NSIntegerMax;
static int _freeMemoryCount = 0;

#pragma mark - Static functions

static void UIParentApplicationSignal(int sig)
{
    int status;
    pid_t pid;
    
    //DLog(@"Signal %d", sig);
    switch (sig) {
        case SIGALRM:
            DLog(@"SIGALRM");
            //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
            break;
        case SIGTERM:
            DLog(@"SIGTERM");
            _UIApplicationTerminate();
            break;
        default:
            break;
    }
}

#pragma mark - Public functions

void UIParentApplicationInitialize()
{
    IOPipeSetPipes(ParentApplicationPipeRead, ParentApplicationPipeWrite);
    
    ParentPipeMessage message = IOPipeReadMessage();
    //DLog(@"message: %d", message);
    NSString *processName = @"ProcessName";
    if (message == ParentPipeMessageCharString) {
        processName = [IOPipeReadCharString() retain];
        //DLog(@"processName: %@", processName);
        _CGDataProviderSetAppName(processName);
    } else {
        ALog(@"Error can't get process name");
    }
    
    message = IOPipeReadMessage();
    if (message == ParentPipeMessageCharString) {
        NSString *myappsPath = [IOPipeReadCharString() retain];
        //DLog(@"myappsPath: %@", myappsPath);
        _NSFileManagerSetMyAppsPath(myappsPath);
    } else {
        ALog(@"Error can't get MyAppsPath");
    }
    
    message = IOPipeReadMessage();
#ifndef ANDROID
    if (message == ParentPipeMessageInt) {
        int parentWindowID = IOPipeReadInt();
        //DLog(@"parentWindowID: 0x%lx", parentWindowID);
        IOWindowSetParentID(parentWindowID);
    } else {
        DLog(@"message: %d", message);
        ALog(@"Error can't get xWindow handle");
    }
#endif
    (void)signal(SIGALRM, UIParentApplicationSignal);
    (void)signal(SIGTERM, UIParentApplicationSignal);
}

void UIParentApplicationSetChildAppIsRunning(BOOL isRunning)
{
    _startTime = CACurrentMediaTime();
    //DLog(@"_startTime: %f", _startTime);
    _childAppRunning = isRunning;
#if defined(ANDROID) && defined(NATIVE_APP)
    EAGLParentSetChildAppIsRunning(isRunning);
#endif
}

void UIParentApplicationHandleMessages()
{
    ParentPipeMessage message = IOPipeReadMessageWithPipe(ParentApplicationPipeRead);
    switch (message) {
        case ParentPipeMessageEndOfMessage:
            //DLog(@"ParentPipeMessageEndOfMessage");
            break;
        case ParentPipeMessageHomeButtonClicked:
            //DLog(@"ParentPipeMessageHomeButtonClicked");
            UIParentApplicationShowLauncher();
            break;
        case ParentPipeMessageBackButtonClicked:
            //DLog(@"ParentPipeMessageBackButtonClicked");
            UIParentApplicationGoBack();
            break;
        default:
            break;
    }
    if (!_childAppRunning) {
        return;
    }
    //DLog();
    message = IOPipeReadMessage();
    switch (message) {
        case ParentPipeMessageEndOfMessage:
            //DLog(@"ParentPipeMessageEndOfMessage");
            break;
        case ParentPipeMessageChildIsReady:
            DLog(@"ParentPipeMessageChildIsReady");
            break;
        case ParentPipeMessageMoveApplicationToTop:
            UIParentApplicationMoveCurrentAppToTop();
            break;
        case ParentPipeMessageHomeButtonClicked:
            DLog(@"ParentPipeMessageHomeButtonClicked");
            break;
        case ParentPipeMessageBackButtonClicked:
            DLog(@"ParentPipeMessageBackButtonClicked");
            break;
        case ParentPipeMessageTerminateApp:
            DLog(@"ParentPipeMessageTerminateApp");
            //[[[_application->_keyWindow subviews] lastObject] removeFromSuperview];
            break;
        default:
            break;
    }
//#endif
}

void UIParentApplicationShowLauncher()
{
    DLog();
    [_currentChildApplicationProxy gotoBackground];
    //_currentChildApplicationProxy = nil;
    _UIApplicationEnterForeground();
    //_launcherView.hidden = NO;
    //DLog();
    //[_uiApplication->_keyWindow bringSubviewToFront:_launcherView];
#if defined(ANDROID) && defined(NATIVE_APP)
    if ([_CAAnimatorNAConditionLock condition] == _CAAnimatorConditionLockHasWork) {
        [_CAAnimatorNAConditionLock lockWithCondition:_CAAnimatorConditionLockHasNoWork];
    }
#endif
}

void UIParentApplicationGoBack()
{
    //DLog();
    if (CFArrayGetCount(_openedChildApplicationProxies) == 1) {
        //DLog(@"(CFArrayGetCount(_openedChildApplicationProxies) == 1)");
        if (!_currentChildApplicationProxy->_running) {
            _UIApplicationEnterBackground();
            [_currentChildApplicationProxy setAsCurrent:YES];
        }
    } else {
        if (_currentChildApplicationProxy->_running) {
            [_currentChildApplicationProxy gotoBackground];
            int currentAppIndex = _CFArrayGetIndexOfValue(_openedChildApplicationProxies, _currentChildApplicationProxy);
            //DLog(@"currentAppIndex: %d", currentAppIndex);
            UIChildApplicationProxy *childApplicationProxy;
            if (currentAppIndex == 0) {
                childApplicationProxy = _CFArrayGetLastValue(_openedChildApplicationProxies);
            } else {
                childApplicationProxy = CFArrayGetValueAtIndex(_openedChildApplicationProxies, currentAppIndex-1);
                //DLog(@"_UIChildApplication: %@", _UIChildApplication);
            }
            [childApplicationProxy setAsCurrent:YES];
        } else {
            _UIApplicationEnterBackground();
            [_currentChildApplicationProxy setAsCurrent:YES];
        }
    }
}

void UIParentApplicationMoveCurrentAppToTop()
{
    //DLog(@"_currentChildApplicationProxy: %@", _currentChildApplicationProxy);
    /*if (!_launcherView.hidden) {
        return;
    }*/
    //_currentChildApplicationProxy->_needsScreenCapture = YES;
    /*if (currentAppIndex == CFArrayGetCount(_openedChildApplicationProxies) - 1) {
        return;
    }*/
    //DLog();
    if (!_currentChildApplicationProxy) {
        return;
    }
    if (_currentChildApplicationProxy->_running) {
        _currentChildApplicationProxy->_score++;
        //}
        _CFArrayMoveValueToTop(_openedChildApplicationProxies, _currentChildApplicationProxy);
        //DLog(@"_openedChildApplicationProxies: %@", _openedChildApplicationProxies);
    }
}

void UIParentApplicationTerminateSomeApps()
{
    //DLog(@"_openedChildApplicationProxies 1: %@", _openedChildApplicationProxies);
    //NSMutableArray *openedApplications = CFArrayCreateCopy(kCFAllocatorDefault, _openedChildApplicationProxies);
    _freeMemoryCount++;
    int count = _openedChildApplicationProxies.count;
    for (int i=0; i<=count; i++) {
        UIChildApplicationProxy *childAppProxy = CFArrayGetValueAtIndex(_openedChildApplicationProxies, 0);
        if (childAppProxy != _currentChildApplicationProxy) {
            //DLog(@"Terminating app: %@", childApp);
            [childAppProxy terminate];
            CFArrayRemoveValueAtIndex(_openedChildApplicationProxies, 0);
        } else {
            return;
        }
    }
}

void UIParentApplicationTerminateApps()
{
#if defined(ANDROID) && defined(NATIVE_APP)
    if ([_CAAnimatorNAConditionLock condition] == _CAAnimatorConditionLockHasWork) {
        [_CAAnimatorNAConditionLock lockWithCondition:_CAAnimatorConditionLockHasNoWork];
    }
#endif
    //DLog(@"_currentChildApplicationProxy: %@", _currentChildApplicationProxy);
    if (!_currentChildApplicationProxy) {
        return;
    }
    if (_currentChildApplicationProxy->_running) {
        IOPipeWriteMessage(ChildPipeMessageTerminateApp, YES);
    }
    for (UIChildApplicationProxy *childAppProxy in _openedChildApplicationProxies) {
        //DLog(@"childAppProxy: %@", childAppProxy);
        if (childAppProxy != _currentChildApplicationProxy || !_currentChildApplicationProxy->_running) {
            [childAppProxy terminate];
        }
    }
    if (_currentChildApplicationProxy->_running) {
        BOOL done = NO;
        _startTime = CACurrentMediaTime();
        while (!done) {
            int message = IOPipeReadMessage();
            switch (message) {
                case ParentPipeMessageEndOfMessage:
                    DLog(@"ParentPipeMessageEndOfMessage");
                    break;
                case ParentPipeMessageTerminateApp:
                    DLog(@"ParentPipeMessageTerminateApp");
                    done = YES;
                    break;
                default:
                    break;
            }
            if (CACurrentMediaTime() - _startTime > _kTerminateChildTimeOut) {
                DLog(@"CACurrentMediaTime() - _startTime > _kTerminateChildTimeOut");
                done = YES;
                [_currentChildApplicationProxy terminate];
            }
        }
    }
}
