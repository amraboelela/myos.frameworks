/*
 Copyright © 2014 myOS Group.
 
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
    UIMLApplicationScreenDirectionFromRight,
    UIMLApplicationScreenDirectionFromLeft,
    UIMLApplicationScreenDirectionToRight,
    UIMLApplicationScreenDirectionToLeft,
}  UIMLApplicationScreenDirection;

@interface UIMLApplication : NSObject {
@package
    //BOOL _isActive;
}

+ (UIMLApplication *)sharedMLApplication;
- (void)presentAppDone;

@end

void UIMLApplicationInitialize();
void UIMLApplicationLauncherViewDidAdded();
void UIMLApplicationSetChildAppIsRunning(BOOL isRunning);
//void UIMLApplicationLog(NSString *longString);
void UIMLApplicationHandleMessages();
//void UIMLApplicationRunApp(UIMAApplication *maApp);
void UIMLApplicationPresentAppScreen(UIMAApplication *maApp, BOOL coldStart);
void UIMLApplicationMoveCurrentAppToTop();
void UIMLApplicationTerminateApps();
void UIMLApplicationGoBack();
void UIMLApplicationShowLauncher();
