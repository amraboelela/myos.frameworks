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

#import "UIApplicationIcon.h"
#import <UIKit/UIKit-private.h>

#define _kLabelHeight       20

#pragma mark - Static functions

@implementation UIApplicationIcon

#pragma mark - Life cycle

- (id)initWithApplication:(UIMAApplication *)application
{
    self = [super initWithFrame:CGRectMake(0,0,_kIconWidth,_kIconHeight)];
    if (self) {
        _application = application;
        //DLog(@"imageName: %@", _imageName);
        NSString *imagePath = [NSString stringWithFormat:@"/data/data/com.myos.myapps/apps/%@.app/Icon.png", application->_name];
        //DLog(@"imagePath: %@", imagePath);
        //UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        _iconImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
        //DLog(@"_iconImage: %@", _iconImage);
        _iconImage.frame = CGRectMake((_kIconWidth - _kImageSize) / 2.0, 5, _kImageSize, _kImageSize);
        [self addSubview:_iconImage];
        
        _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,_kImageSize+3,_kIconWidth,_kLabelHeight)];
        _iconLabel.textColor = [UIColor whiteColor];
        _iconLabel.textAlignment = UITextAlignmentCenter;
        _iconLabel.font = [UIFont systemFontOfSize:10];
        _iconLabel.text = application->_name;
        _iconLabel.adjustsFontSizeToFitWidth = YES;
        //DLog(@"_iconLabel.frame 1: %@", NSStringFromCGRect(_iconLabel.frame));
        [_iconLabel sizeToFit];
        CGRect frame = _iconLabel.frame;
        //DLog(@"_iconLabel.frame 2: %@", NSStringFromCGRect(_iconLabel.frame));
        frame.origin.x = 0;
        frame.origin.y += (_kLabelHeight - frame.size.height) / 2.0;
        frame.size.width = _kIconWidth;
        _iconLabel.frame = frame;
        //DLog(@"_iconLabel.frame 3: %@", NSStringFromCGRect(_iconLabel.frame));
        [self addSubview:_iconLabel];
        
        // Single tap gesture
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
        [self addGestureRecognizer:_singleTap];
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        [self addGestureRecognizer:_longPress];
        [_singleTap requireGestureRecognizerToFail:_longPress];
        //_mode = UIApplicationIconModeNormal;
    }
    return self;
}

- (void)dealloc
{
    [_iconImage release];
    [_iconLabel release];
    [_singleTap release];
    [_longPress release];
    [super dealloc];
}

#pragma mark - Accessors

- (UIScrollView *)parentScrollView
{
    return _parentScrollView;
}

- (void)setParentScrollView:(UIScrollView *)scrollView
{
    //DLog(@"scrollView: %@", scrollView);
    _parentScrollView = scrollView;
    [_singleTap requireGestureRecognizerToFail:_parentScrollView.panGestureRecognizer];
    [_longPress requireGestureRecognizerToFail:_parentScrollView.panGestureRecognizer];
}

#pragma mark - Actions

- (void)singleTapped:(id)sender
{
    //DLog();
    //if (_mode == UIApplicationIconModeNormal) {
    [_application singleTapped];
    //} else {
    //    _UIApplicationIconResetToNormalMode(self);
    //}
}

- (void)longPressed:(id)sender
{
    DLog();
    [_application showMenu];
    /*if (_mode == UIApplicationIconModeNormal) {
        if (_application->_opened) {
            _mode = UIApplicationIconModeClose;
            _closeControl.hidden = NO;
        } else {
            _mode = UIApplicationIconModeDelete;
            _deleteControl.hidden = NO;
        }
        _menuControl.hidden = NO;
        //_anchorControl.hidden = NO;
    } else {
        _UIApplicationIconResetToNormalMode(self);
    }*/
}
/*
- (void)iconControlClicked:(UIIconControl *)iconControl
{
    DLog(@"iconControl: %@", iconControl);
    switch (iconControl->_type) {
        case UIIconControlTypeClose:
            [_application closeApp];
            _UIApplicationIconResetToNormalMode(self);
            break;
        case UIIconControlTypeDelete:
            [_application deleteApp];
            _UIApplicationIconResetToNormalMode(self);
            break;
        case UIIconControlTypeMenu:
            [_application showMenu];
            _UIApplicationIconResetToNormalMode(self);
            break;
        case UIIconControlTypeAnchor:
            //[_application anchorClicked];
            _application.anchored = !_application.anchored;
            [iconControl setNeedsDisplay];
            break;
        default:
            break;
    }
}*/

#pragma mark - Public methods

@end
