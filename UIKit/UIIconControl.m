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

#import <UIKit/UIKit-private.h>

#define _kAnchorCirleRadius     2

#pragma mark - Static functions

@implementation UIIconControl

#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _type = UIIconControlTypeClose;
        self.contentScaleFactor = _UIScreenMainScreen()->_scale;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andType:(UIIconControlType)type
{
    if ((self = [self initWithFrame:frame])) {
        _type = type;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; type: %d>", [self className], self, _type];
}

#pragma mark - Overridden methods
 
- (void)drawRect:(CGRect)rect
{
    //DLog(@"_applicationIcon: %@", _applicationIcon);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    switch (_type) {
        case UIIconControlTypeClose:
            CGContextSetRGBFillColor(context, 0.9, 0.9, 0.0, 1.0);
            break;
        case UIIconControlTypeDelete:
            CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
            break;
        case UIIconControlTypeMenu:
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
            //CGContextSetLineWidth(context, 2);
            break;
        /*case UIIconControlTypeAnchor: {
            //CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 1.0);
            //DLog(@"_applicationIcon->_application: %@", _applicationIcon->_application);
            if (_applicationIcon->_application.anchored) {
                CGContextSetRGBStrokeColor(context, 231.0 / 255.0, 127.0 / 255.0, 0.0 / 255.0, 1.0);
            } else {
                CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
            }
            break;
        }*/
        default:
            break;
    }
    
    switch (_type) {
        case UIIconControlTypeClose:
        case UIIconControlTypeDelete:
            CGContextAddArc(context, rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0,
                            rect.size.width / 2.0, 0, 2.0 * PI, YES);
            CGContextDrawPath(context, kCGPathFill);
            
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
            CGContextMoveToPoint(context, rect.origin.x + rect.size.width * 0.65, rect.origin.y + rect.size.height * 0.35);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * 0.35, rect.origin.y + rect.size.height * 0.65);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, rect.origin.x + rect.size.width * 0.35, rect.origin.y + rect.size.height * 0.35);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * 0.65, rect.origin.y + rect.size.height * 0.65);
            CGContextStrokePath(context);
            break;
        case UIIconControlTypeMenu: {
            //DLog(@"rect: %@", NSStringFromCGRect(rect));
            float y = 1.0;//rect.size.height * 0.1;
            for (int i=0; i<3; i++) {
                //CGContextMoveToPoint(context, 0, y);
                //CGContextAddLineToPoint(context, rect.size.width, y);
                //CGContextStrokePath(context);
                
                [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(1,y,rect.size.width-2,2) cornerRadius:0.5] fill];
                y += rect.size.height * 1.0 / 3.0;
            }
            break;
        }
        case UIIconControlTypeAnchor:
            CGContextAddArc(context, rect.size.width * 0.5, _kAnchorCirleRadius+1, _kAnchorCirleRadius, 0, 2.0 * PI, YES);
            CGContextStrokePath(context);
            //CGContextDrawPath(context, kCGPathFill);
            
            CGContextMoveToPoint(context, rect.size.width * 0.5, _kAnchorCirleRadius * 2);
            CGContextAddLineToPoint(context, rect.size.width * 0.5, rect.size.height);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, rect.size.width * 0.5 - _kAnchorCirleRadius - 1.0, rect.size.height * 0.42);
            CGContextAddLineToPoint(context, rect.size.width * 0.5 + _kAnchorCirleRadius + 1.0, rect.size.height * 0.42);
            CGContextStrokePath(context);
            
            // Draw the down arrow
            CGContextMoveToPoint(context, rect.size.width * 0.5, rect.size.height * 0.9);
            CGContextAddLineToPoint(context, rect.size.width * 0.3, rect.size.height * 0.6);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, rect.size.width * 0.5, rect.size.height * 0.9);
            CGContextAddLineToPoint(context, rect.size.width * 0.7, rect.size.height * 0.6);
            CGContextStrokePath(context);
            break;
        default:
            break;
    }
    
    CGContextRestoreGState(context);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
