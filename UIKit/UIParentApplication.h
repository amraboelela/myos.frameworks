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

#import <UIKit/UIKit.h>

#define ParentApplicationPipeRead           30
#define ParentApplicationPipeWrite          51

@class UIChildApplicationProxy;

@interface UIParentApplication : NSObject {
@package
    //BOOL _isActive;
}

+ (UIParentApplication *)sharedParentApplication;
- (void)presentAppDone;

@end

//void UIParentApplicationInitialize();
//void UIParentApplicationLauncherViewDidAdded();
void UIParentApplicationSetChildAppIsRunning(BOOL isRunning);
void UIParentApplicationHandleMessages();
//void UIChildApplicationProxyRunApp(UIChildApplicationProxy *childAppProxy, BOOL coldStart);
void UIParentApplicationMoveCurrentAppToTop();
void UIParentApplicationTerminateApps();
void UIParentApplicationGoBack();
void UIParentApplicationShowLauncher();
