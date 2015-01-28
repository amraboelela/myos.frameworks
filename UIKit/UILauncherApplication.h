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

#import <Foundation/Foundation.h>

typedef enum {
    UILauncherApplicationScreenDirectionFromRight,
    UILauncherApplicationScreenDirectionFromLeft,
    UILauncherApplicationScreenDirectionToRight,
    UILauncherApplicationScreenDirectionToLeft,
}  UILauncherApplicationScreenDirection;

@interface UILauncherApplication : NSObject {
@package
    //BOOL _isActive;
}

+ (UILauncherApplication *)sharedMLApplication;
- (void)presentAppDone;

@end

void UILauncherApplicationInitialize();
void UILauncherApplicationLauncherViewDidAdded();
void UILauncherApplicationSetChildAppIsRunning(BOOL isRunning);
//void UILauncherApplicationLog(NSString *longString);
void UILauncherApplicationHandleMessages();
//void UILauncherApplicationRunApp(UIChildApplication *maApp);
void UILauncherApplicationPresentAppScreen(UIChildApplication *maApp, BOOL coldStart);
void UILauncherApplicationMoveCurrentAppToTop();
void UILauncherApplicationTerminateApps();
void UILauncherApplicationGoBack();
void UILauncherApplicationShowLauncher();
