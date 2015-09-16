/*
 Copyright © 2015 myOS Group.
 
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

@class UIApplicationIcon, UIChildApplicationProxy;

extern NSMutableDictionary *_allChildApplicationProxiesDictionary;
extern UIChildApplicationProxy *_currentChildApplicationProxy;
extern NSMutableArray *_openedChildApplicationProxies;

@interface UIChildApplicationProxy : NSObject {
@package
    NSString *_bundleName;
    NSMutableDictionary *_data;
    BOOL _opened;
    BOOL _running;
    int _score;
    pid_t _pid;
    int _pipeRead;
    int _pipeWrite;
    int _animationPipeRead;
    int _animationPipeWrite;
    UIApplicationIcon *_applicationIcon;
    UIApplicationIcon *_homeIcon;
}

@property (nonatomic, retain) NSString *bundleName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *category;
@property (nonatomic) int score;
@property (nonatomic, readonly) UIImageView *defaultScreenView;
@property (nonatomic, readonly) UIApplicationIcon *homeIcon;
@property BOOL running;

- (id)initWithBundleName:bundleName;
- (BOOL)isCurrent;
- (void)startApp;
- (void)setAsCurrent:(BOOL)withSignal;
- (void)gotoBackground;
- (void)terminate;
- (void)singleTapped;
- (void)showMenu;
- (void)closeApp;
- (void)deleteApp;

@end
