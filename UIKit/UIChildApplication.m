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
#import <sys/wait.h>
#import <UIKit/UIChildApplication.h>
#import <UIKit/UIKit-private.h>
#import <IOKit/IOKit.h>

UIApplication *_application = nil;

#pragma mark - Static functions

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
            _UIApplicationTerminate();
            break;
        default:
            break;
    }
}

#pragma mark - Public functions

void UIChildApplicationInitialize()
{
    IOPipeSetPipes(ChildApplicationPipeRead, ChildApplicationPipeWrite);
    
    ChildPipeMessage message = IOPipeReadMessage();
    //DLog(@"message: %d", message);
    NSString *processName = @"ProcessName";
    if (message == ChildPipeMessageCharString) {
        processName = [IOPipeReadCharString() retain];
        //DLog(@"processName: %@", processName);
#ifdef ANDROID
        [[NSProcessInfo processInfo] setProcessName:processName];
        [[NSBundle mainBundle] reInitialize];
#endif
        _CGDataProviderSetChildAppName(processName);
    } else {
        NSLog(@"Error can't get process name");
    }
    
    message = IOPipeReadMessage();
    if (message == ChildPipeMessageCharString) {
        NSString *myappsPath = [IOPipeReadCharString() retain];
        //DLog(@"myappsPath: %@", myappsPath);
        _NSFileManagerSetMyAppsPath(myappsPath);
    } else {
        NSLog(@"Error can't get MyAppsPath");
    }
    
    message = IOPipeReadMessage();
#ifndef ANDROID
    if (message == ChildPipeMessageInt) {
        int parentWindowID = IOPipeReadInt();
        //DLog(@"parentWindowID: 0x%lx", parentWindowID);
        IOWindowSetParentID(parentWindowID);
    } else {
        //DLog(@"message: %d", message);
        NSLog(@"Error can't get xWindow handle");
    }
#endif
    (void)signal(SIGALRM, UIChildApplicationSignal);
    (void)signal(SIGTERM, UIChildApplicationSignal);
}

void UIChildApplicationSetApplication(UIApplication *application)
{
    //DLog(@"application: %@", application);
    _application = application;
}

int UIChildApplicationHandleMessages()
{
    int message = IOPipeReadMessage();
    switch (message) {
        case ChildPipeMessageEndOfMessage:
            //DLog(@"ChildPipeMessageEndOfMessage");
            break;
        case ChildPipeMessageEventActionDown:
        case ChildPipeMessageEventActionMoved:
        case ChildPipeMessageEventActionUp: {
            //DLog(@"ChildPipeMessageEventAction*");
            UITouch *touch = [[_application->_currentEvent allTouches] anyObject];
            UIScreen *screen = _UIScreenMainScreen();
            float x = IOPipeReadFloat();
            float y = IOPipeReadFloat();
            //DLog(@"screenLocation: x:%0.0f, y:%0.0f", x, y);
            CGPoint screenLocation = CGPointMake(x, y);
            NSTimeInterval timestamp = CACurrentMediaTime();
            _application->_currentEvent->_timestamp = timestamp;
            switch (message) {
                case ChildPipeMessageEventActionDown: {
                    //DLog(@"ChildPipeMessageEventActionDown");
                    CGPoint delta = CGPointZero;
                    int tapCount = 1;
                    NSTimeInterval timeDiff = fabs(touch.timestamp - timestamp);
                    if (touch.phase == UITouchPhaseEnded && timeDiff < _kUIEventTimeDiffMax) {
                        tapCount = touch.tapCount+1;
                    }
                    _UITouchSetPhase(touch, UITouchPhaseBegan, screenLocation, tapCount, delta, timestamp);
                    break;
                }
                case ChildPipeMessageEventActionMoved:
                    //DLog(@"ChildPipeMessageEventActionMoved");
                    _UITouchUpdatePhase(touch, UITouchPhaseMoved, screenLocation, timestamp);
                    break;
                case ChildPipeMessageEventActionUp:
                    //DLog(@"screenLocation: x:%0.0f, y:%0.0f", x, y);
                    //DLog(@"ChildPipeMessageEventActionUp");
                    _UITouchUpdatePhase(touch, UITouchPhaseEnded, screenLocation, timestamp);
                    break;
                default:
                    break;
            }
            _UIApplicationSetCurrentEventTouchedView();
            break;
        }
        case ChildPipeMessageWillEnterBackground:
            //DLog(@"ChildPipeMessageWillEnterBackground");
            IOWindowHideWindow();
            _UIApplicationEnterBackground();
            pause();
            //DLog(@"Will enter foreground");
            //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
            _UIApplicationEnterForeground();
            break;
            /*case ChildPipeMessageHello:
             DLog(@"ChildPipeMessageHello");
             break;*/
        case ChildPipeMessageTerminateApp:
            //DLog(@"ChildPipeMessageTerminateApp");
            IOPipeWriteMessage(ParentPipeMessageTerminateApp, YES);
            _UIApplicationTerminate();
            //return ChildPipeMessageTerminateApp;
        default:
            break;
    }
    return 0;
}

void UIChildApplicationClosePipes()
{
    close(ChildApplicationPipeRead);
    close(ChildApplicationPipeWrite);
}
