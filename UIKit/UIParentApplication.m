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
//#define _kGobackTimeLimit               1.0

static BOOL _childAppRunning = NO;
static UIParentApplication *_mlApp = nil;
static CFTimeInterval _startTime;
//static CFTimeInterval _lastGobackTime = 0;
static UIApplication *_uiApplication = nil;
static UIParentApplication *_UIParentApplication = nil;
static UIChildApplication *_UIChildApplication = nil;
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

void UIParentApplicationInitialize()
{
    //DLog(@"UIParentApplicationInitialize");
    _uiApplication = [UIApplication sharedApplication];
    _UIChildApplication = [[UIChildApplication alloc] init];
    //CFArrayAppendValue(_openedApplications, _launcherApp);
    //_openedApplicationsDictionary = [[NSMutableDictionary alloc] init];
}

void UIParentApplicationLauncherViewDidAdded()
{
    //UIParentApplication *mlApplication = [UIParentApplication sharedMLApplication];
    //DLog();
    _launcherView = [[_uiApplication->_keyWindow subviews] objectAtIndex:0];
    _childAppView = [[UIView alloc] initWithFrame:_launcherView.frame];
    //_childAppView.backgroundColor = [UIColor redColor];
    [_uiApplication->_keyWindow insertSubview:_childAppView atIndex:0];
    //DLog(@"_launcherView: %@", _launcherView);
    //DLog(@"_childAppView: %@", _childAppView);
}

void UIParentApplicationSetChildAppIsRunning(BOOL isRunning)
{
    _startTime = CACurrentMediaTime();
    //DLog(@"_startTime: %f", _startTime);
    _childAppRunning = isRunning;
#ifdef NATIVE_APP
    EAGLParentSetChildAppIsRunning(isRunning);
#endif
}

void UIParentApplicationTerminateSomeApps()
{
    //DLog(@"_openedApplications 1: %@", _openedApplications);
    //NSMutableArray *openedApplications = CFArrayCreateCopy(kCFAllocatorDefault, _openedApplications);
    _freeMemoryCount++;
    int count = _openedApplications.count;
    for (int i=0; i<=count; i++) {
        UIChildApplication *childApp = CFArrayGetValueAtIndex(_openedApplications, 0);
        if (childApp != _currentChildApplication) {
        //DLog(@"Terminating app: %@", childApp);
            [childApp terminate];
            CFArrayRemoveValueAtIndex(_openedApplications, 0);
        } else {
            return;
        }
    }
}

void UIParentApplicationPresentAppScreen(UIChildApplication *childApp, BOOL coldStart)
{
    //DLog(@"uiApplication: %@", uiApplication);
    //_UIChildApplication = childApp;
    //[_uiApplication->_keyWindow bringSubviewToFront:_childAppView];
    _launcherView.hidden = YES;
    _UIApplicationEnterBackground();
    if (coldStart) {
        //UIParentApplicationCheckMemory();
        [_childAppView addSubview:childApp.defaultScreenView];
        long freeMemory = CFGetFreeMemory();
        //DLog(@"%@ Free memory: %ld KB", childApp->_bundleName, freeMemory);
        if (freeMemory > _freeMemory && (_freeMemoryCount % 2 == 0) ||
            freeMemory < 5000 && (_freeMemoryCount % 2 == 1)) {
            DLog(@"Low memory");
            UIParentApplicationTerminateSomeApps();
            freeMemory = CFGetFreeMemory();
            DLog(@"%@ Free memory 2: %ld KB", childApp->_bundleName, freeMemory);
        }
        _freeMemory = freeMemory;
        [childApp startApp];
    } else {
        [childApp setAsCurrent:YES];
    }
#ifdef NATIVE_APP
    [_CAAnimatorNAConditionLock unlockWithCondition:_CAAnimatorConditionLockHasWork];
#endif
}

void UIParentApplicationHandleMessages()
{
#ifdef NATIVE_APP
    if (!_childAppRunning) {
        //DLog();
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
    if ([[_childAppView subviews] count] > 0) {
        //DLog(@"[[_childAppView subviews] count] > 0");
        [[[_childAppView subviews] objectAtIndex:0] removeFromSuperview];
    }
    [_currentChildApplication gotoBackground];
    _UIApplicationEnterForeground();
    _launcherView.hidden = NO;
    //DLog();
    //[_uiApplication->_keyWindow bringSubviewToFront:_launcherView];
#ifdef NATIVE_APP
    if ([_CAAnimatorNAConditionLock condition] == _CAAnimatorConditionLockHasWork) {
        [_CAAnimatorNAConditionLock lockWithCondition:_CAAnimatorConditionLockHasNoWork];
    }
#endif
}

void UIParentApplicationGoBack()
{
    _childAppView.hidden = NO;
    if (!_launcherView.hidden) {
        if (CFArrayGetCount(_openedApplications) == 0) {
            DLog(@"CFArrayGetCount(_openedApplications) == 0");
            return;
        } else {
            //DLog(@"_currentChildApplication: %@", _currentChildApplication);
            UIParentApplicationPresentAppScreen(_currentChildApplication, NO);
        }
    } else {
        _childAppView.hidden = NO;
        if (CFArrayGetCount(_openedApplications) == 1) {
            return;
        }
        [_currentChildApplication gotoBackground];
        int currentAppIndex = _CFArrayGetIndexOfValue(_openedApplications, _currentChildApplication);
        //DLog(@"currentAppIndex: %d", currentAppIndex);
        if (currentAppIndex == 0) {
            _UIChildApplication = _CFArrayGetLastValue(_openedApplications);
        } else {
            _UIChildApplication = CFArrayGetValueAtIndex(_openedApplications, currentAppIndex-1);
            //DLog(@"_UIChildApplication: %@", _UIChildApplication);
        }
        [_UIChildApplication setAsCurrent:YES];
    }
}

void UIParentApplicationMoveCurrentAppToTop()
{
    //DLog(@"_currentChildApplication: %@", _currentChildApplication);
    if (!_launcherView.hidden) {
        return;
    }
    //_currentChildApplication->_needsScreenCapture = YES;
    /*if (currentAppIndex == CFArrayGetCount(_openedApplications) - 1) {
        return;
    }*/
    _currentChildApplication->_score++;
    //}
    _CFArrayMoveValueToTop(_openedApplications, _currentChildApplication);
    //DLog(@"_openedApplications: %@", _openedApplications);
}

void UIParentApplicationTerminateApps()
{
#ifdef NATIVE_APP
    if ([_CAAnimatorNAConditionLock condition] == _CAAnimatorConditionLockHasWork) {
        [_CAAnimatorNAConditionLock lockWithCondition:_CAAnimatorConditionLockHasNoWork];
    }
#endif
    //DLog(@"_currentChildApplication: %@", _currentChildApplication);
    if (!_currentChildApplication) {
        return;
    }
    if (_currentChildApplication->_running) {
        IOPipeWriteMessage(MAPipeMessageTerminateApp, YES);
    }
    for (UIChildApplication *childApp in _openedApplications) {
        //DLog(@"childApp: %@", childApp);
        if (childApp != _currentChildApplication || !_currentChildApplication->_running) {
            [childApp terminate];
        }
    }
    if (_currentChildApplication->_running) {
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
                [_currentChildApplication terminate];
            }
        }
    }
}
