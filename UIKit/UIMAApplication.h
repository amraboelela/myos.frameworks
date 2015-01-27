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

#import <UIKit/UIImageView.h>

#define kMainPipeRead           10
#define kMainPipeWrite          21

@class UIApplicationIcon, UIMAApplication;

extern NSMutableDictionary *_allApplicationsDictionary;
extern UIMAApplication *_currentMAApplication;
extern NSMutableArray *_openedApplications;

@interface UIMAApplication : NSObject {
@package
    NSString *_name;
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
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic) int score;
@property (nonatomic) int pageNumber;
@property (nonatomic) int xLocation;
@property (nonatomic) int yLocation;
@property (nonatomic) BOOL anchored;
@property (nonatomic, readonly) UIImageView *defaultScreenView;
@property BOOL running;

- (id)initWithAppName:name;
- (void)swapLocationWithApp:(UIMAApplication *)anotherApp;
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

//void UIMAApplicationTakeScreenCaptureIfNeeded(UIMAApplication *app);
void UIMAApplicationSaveData(UIMAApplication *app);
void UIMAApplicationClosePipes();
