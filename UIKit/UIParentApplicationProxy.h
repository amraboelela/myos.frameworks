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

#import <UIKit/UIImageView.h>
#import <UIKit/UIChildApplication.h>

@class UIApplicationIcon, UIParentApplicationProxy;

@interface UIParentApplicationProxy : NSObject {
@package
    NSString *_bundleName;
    NSString *_bundlePath;
    pid_t _pid;
    int _pipeRead;
    int _pipeWrite;
}

@property (nonatomic, retain) NSString *bundleName;
@property (nonatomic, retain) NSString *bundlePath;

- (id)initWithBundleName:(NSString *)bundleName andPath:(NSString *)path;
- (void)startApp;
//- (void)gotoBackground;
- (void)terminate;

@end
