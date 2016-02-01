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

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
typedef enum {
    UIParentApplicationScreenDirectionFromRight,
    UIParentApplicationScreenDirectionFromLeft,
    UIParentApplicationScreenDirectionToRight,
    UIParentApplicationScreenDirectionToLeft,
}  UIParentApplicationScreenDirection;
*/

@interface UINativeApplication : NSObject {
@package
    //BOOL _isActive;
}

+ (UINativeApplication *)sharedNativeApplication;
//- (void)presentAppDone;

@end

//void UIParentApplicationInitialize();
//void UIParentApplicationLauncherViewDidAdded();
//void UIParentApplicationSetChildAppIsRunning(BOOL isRunning);
void UINativeApplicationHandleMessages();
//void UIParentApplicationPresentAppScreen(UIChildApplicationProxy *childAppProxy, BOOL coldStart);
//void UIParentApplicationMoveCurrentAppToTop();
//void UIParentApplicationTerminateApps();
//void UIParentApplicationGoBack();
//void UIParentApplicationShowLauncher();
