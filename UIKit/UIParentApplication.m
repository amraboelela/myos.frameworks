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
#import <QuartzCore/QuartzCore-private.h>
#import <CoreFoundation/CoreFoundation-private.h>

#define _kTerminateChildTimeOut         2.0

static BOOL _childAppRunning = NO;
static UIParentApplication *_mlApp = nil;
static CFTimeInterval _startTime;
//static UIApplication *_uiApplication = nil;
static UIParentApplication *_UIParentApplication = nil;
//static UIChildApplicationProxy *_UIChildApplicationProxy = nil;
static UIView *_launcherView = nil;
static UIView *_childAppView = nil;
static long _freeMemory = NSIntegerMax;
static int _freeMemoryCount = 0;

#pragma mark - Static functions

@implementation UIParentApplication

#pragma mark - Life cycle
/*
- (id)init
{
    if ((self=[super init])) {
        _uiApplication = [UIApplication sharedApplication];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}*/

#pragma mark - Class methods

+ (UIParentApplication *)sharedMLApplication
{
    if (!_mlApp) {
        _mlApp = [[UIParentApplication alloc] init];
    }
    return _mlApp;
}

#pragma mark - Accessors

#pragma mark - Delegates

@end

#pragma mark - Public functions

/*
void UIParentApplicationInitialize()
{
    //DLog(@"UIParentApplicationInitialize");
    _uiApplication = [UIApplication sharedApplication];
    //_UIChildApplicationProxy = [[UIChildApplicationProxy alloc] init];
    //CFArrayAppendValue(_openedChildApplicationProxies, _launcherApp);
    //_openedApplicationsDictionary = [[NSMutableDictionary alloc] init];
}

void UIParentApplicationLauncherViewDidAdded()
{
    //UIParentApplication *mlApplication = [UIParentApplication sharedMLApplication];
    _launcherView = [[_uiApplication->_keyWindow subviews] objectAtIndex:0];
    _childAppView = [[UIView alloc] initWithFrame:_launcherView.frame];
    //_childAppView.backgroundColor = [UIColor redColor];
    [_uiApplication->_keyWindow insertSubview:_childAppView atIndex:0];
    //DLog(@"_launcherView: %@", _launcherView);
    //DLog(@"_childAppView: %@", _childAppView);
}*/

void UIParentApplicationSetChildAppIsRunning(BOOL isRunning)
{
    _startTime = CACurrentMediaTime();
    //DLog(@"_startTime: %f", _startTime);
    _childAppRunning = isRunning;
#if defined(ANDROID) && defined(NATIVE_APP)
    EAGLParentSetChildAppIsRunning(isRunning);
#endif
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

void UIParentApplicationPresentAppScreen(UIChildApplicationProxy *childAppProxy, BOOL coldStart)
{
    _launcherView.hidden = YES;
    _UIApplicationEnterBackground();
    if (coldStart) {
        //UIParentApplicationCheckMemory();
        [_childAppView addSubview:childAppProxy.defaultScreenView];
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
        [childAppProxy startApp];
    } else {
        [childAppProxy setAsCurrent:YES];
    }
#if defined(ANDROID) && defined(NATIVE_APP)
    [_CAAnimatorNAConditionLock unlockWithCondition:_CAAnimatorConditionLockHasWork];
#endif
}

void UIParentApplicationHandleMessages()
{
#ifdef NATIVE_APP
    if (!_childAppRunning) {
        return;
    }
    //DLog();
    int message = IOPipeReadMessage();
    switch (message) {
        case MLPipeMessageEndOfMessage:
            //DLog(@"MLPipeMessageEndOfMessage");
            break;
        case MLPipeMessageChildIsReady:
            //DLog(@"MLPipeMessageChildIsReady");
            IOPipeWriteInt(0x4000001);
            break;
        case MLPipeMessageTerminateApp:
            DLog(@"MLPipeMessageTerminateApp");
            //[[[_application->_keyWindow subviews] lastObject] removeFromSuperview];
            break;
        default:
            break;
    }
#endif
}

void UIParentApplicationShowLauncher()
{
    //DLog();
    /*if ([[_childAppView subviews] count] > 0) {
        //DLog(@"[[_childAppView subviews] count] > 0");
        [[[_childAppView subviews] objectAtIndex:0] removeFromSuperview];
    }*/
    [_currentChildApplicationProxy gotoBackground];
    //_UIApplicationEnterForeground();
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
    _childAppView.hidden = NO;
    if (!_launcherView.hidden) {
        if (CFArrayGetCount(_openedChildApplicationProxies) == 0) {
            DLog(@"CFArrayGetCount(_openedChildApplicationProxies) == 0");
            return;
        } else {
            //DLog(@"_currentChildApplicationProxy: %@", _currentChildApplicationProxy);
            UIParentApplicationPresentAppScreen(_currentChildApplicationProxy, NO);
        }
    } else {
        _childAppView.hidden = NO;
        if (CFArrayGetCount(_openedChildApplicationProxies) == 1) {
            return;
        }
        [_currentChildApplicationProxy gotoBackground];
        int currentAppIndex = _CFArrayGetIndexOfValue(_openedChildApplicationProxies, _currentChildApplicationProxy);
        //DLog(@"currentAppIndex: %d", currentAppIndex);
        UIChildApplicationProxy *_UIChildApplicationProxy;
        if (currentAppIndex == 0) {
            _UIChildApplicationProxy = _CFArrayGetLastValue(_openedChildApplicationProxies);
        } else {
            _UIChildApplicationProxy = CFArrayGetValueAtIndex(_openedChildApplicationProxies, currentAppIndex-1);
            //DLog(@"_UIChildApplication: %@", _UIChildApplication);
        }
        [_UIChildApplicationProxy setAsCurrent:YES];
    }
}

void UIParentApplicationMoveCurrentAppToTop()
{
    //DLog(@"_currentChildApplicationProxy: %@", _currentChildApplicationProxy);
    if (!_launcherView.hidden) {
        return;
    }
    //_currentChildApplicationProxy->_needsScreenCapture = YES;
    /*if (currentAppIndex == CFArrayGetCount(_openedChildApplicationProxies) - 1) {
        return;
    }*/
    _currentChildApplicationProxy->_score++;
    //}
    _CFArrayMoveValueToTop(_openedChildApplicationProxies, _currentChildApplicationProxy);
    //DLog(@"_openedChildApplicationProxies: %@", _openedChildApplicationProxies);
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
        IOPipeWriteMessage(MAPipeMessageTerminateApp, YES);
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
                case MLPipeMessageEndOfMessage:
                    DLog(@"MLPipeMessageEndOfMessage");
                    break;
                case MLPipeMessageTerminateApp:
                    DLog(@"MLPipeMessageTerminateApp");
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
