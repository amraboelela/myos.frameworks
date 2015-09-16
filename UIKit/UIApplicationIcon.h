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

#import <UIKit/UIKit.h>

#define _kImageSize             68
#define _kIconWidth             80
#define _kIconHeight            87
#define _kIconControlMargin     3

typedef enum {
    UIApplicationIconModeNormal,
    UIApplicationIconModeClose,
    UIApplicationIconModeDelete
} UIApplicationIconMode;

@class UIChildApplicationProxy;

@interface UIApplicationIcon : UIView {
@package
    UIImageView *_iconImage;
    UIChildApplicationProxy *_application;
    UILabel *_iconLabel;
    UIApplicationIconMode _mode;
    UIScrollView *_parentScrollView;
    UITapGestureRecognizer *_singleTap;
    UILongPressGestureRecognizer *_longPress;
}

@property (nonatomic, assign) UIScrollView *parentScrollView;

- (id)initWithApplication:(UIChildApplicationProxy *)application;

@end

