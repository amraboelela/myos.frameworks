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
#import <UIKit/UIKit-private.h>
#import <IOKit/IOKit.h>
//#import <OpenGLES/EAGL-private.h>
//#import <CoreGraphics/CoreGraphics-private.h>

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
    IOPipeSetPipes(kMainPipeRead, kMainPipeWrite);
    
    MAPipeMessage message = IOPipeReadMessage();
    //DLog(@"message: %d", message);
#ifdef ANDROID
    _processName = @"ProcessName";
    if (message == MAPipeMessageCharString) {
        _processName = [IOPipeReadCharString() retain];
        DLog(@"processName: %@", _processName);
        [[NSProcessInfo processInfo] setProcessName:_processName];
        [[NSBundle mainBundle] reInitialize];
        _CGDataProviderSetChildAppName(_processName);
    } else {
        NSLog(@"Error can't get process name");
    }
#else
    if (message == MAPipeMessageInt) {
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
    //DLog();
    switch (message) {
        case MAPipeMessageEndOfMessage:
            //DLog(@"MAPipeMessageEndOfMessage");
            break;
        case MAPipeMessageEventActionDown:
        case MAPipeMessageEventActionMoved:
        case MAPipeMessageEventActionUp: {
            DLog(@"MAPipeMessageEventAction*");
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
            DLog(@"MAPipeMessageWillEnterBackground");
            _UIApplicationEnterBackground();
            pause();
            //DLog(@"Free memory: %ld KB", CFGetFreeMemory());
            _UIApplicationEnterForeground();
            break;
            /*case MAPipeMessageHello:
             DLog(@"MAPipeMessageHello");
             break;*/
        case MAPipeMessageTerminateApp:
            DLog(@"MAPipeMessageTerminateApp");
            IOPipeWriteMessage(MLPipeMessageTerminateApp, YES);
            _UIApplicationTerminate();
            //return MAPipeMessageTerminateApp;
        default:
            break;
    }
    return 0;
}

void UIChildApplicationClosePipes()
{
    close(kMainPipeRead);
    close(kMainPipeWrite);
}
