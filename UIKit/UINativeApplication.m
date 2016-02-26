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

//#import <fcntl.h>
#import <UIKit/UINativeApplication.h>
#import <IOKit/IOKit.h>


static BOOL _parentAppRunning = NO;
//static UIParentApplication *_mlApp = nil;
#ifdef DEBUG
static CFTimeInterval _startTime;
#endif
//static UIApplication *_uiApplication = nil;

#pragma mark - Static functions

@implementation UINativeApplication

#pragma mark - Life cycle

#pragma mark - Class methods

/*
+ (UINativeApplication *)sharedNativeApplication
{
    if (!_mlApp) {
        _mlApp = [[UIParentApplication alloc] init];
    }
    return _mlApp;
}*/

#pragma mark - Accessors

#pragma mark - Delegates

@end

#pragma mark - Public functions

void UINativeApplicationSetParentAppIsRunning(BOOL isRunning)
{
#ifdef DEBUG
    _startTime = CACurrentMediaTime();
    DLog(@"_startTime: %f", _startTime);
#endif
    _parentAppRunning = isRunning;
}

/*
void UINativeApplicationRunParentApp(UIParentApplicationProxy *parentAppProxy)
{
    [parentAppProxy startApp];
}*/

void UINativeApplicationHandleMessages()
{
    //DLog();
//#ifdef NATIVE_APP
    if (!_parentAppRunning) {
        return;
    }
    //DLog();
    int message = IOPipeReadMessage();
    switch (message) {
        case NativePipeMessageEndOfMessage:
            //DLog(@"NativePipeMessageEndOfMessage");
            break;
        case NativePipeMessageParentIsReady:
            //DLog(@"NativePipeMessageParentIsReady");
            //IOPipeWriteInt(0x4000001);
            break;
        /*case ParentPipeMessageMoveApplicationToTop:
            UIParentApplicationMoveCurrentAppToTop();
            break;
        case ParentPipeMessageTerminateApp:
            DLog(@"ParentPipeMessageTerminateApp");
            //[[[_application->_keyWindow subviews] lastObject] removeFromSuperview];
            break;*/
        default:
            break;
    }
//#endif
}
