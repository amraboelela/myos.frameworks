/*
 Copyright © 2014-2015 myOS Group.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 Contributor(s):
 Amr Aboelela <amraboelela@gmail.com>
 */

#import <QuartzCore/QuartzCore.h>

extern NSString *const kCAScrollNone;
extern NSString *const kCAScrollVertically;
extern NSString *const kCAScrollHorizontally;
extern NSString *const kCAScrollBoth;

@interface CAScrollLayer : CALayer {
@package
	NSString *scrollMode;
}

@property (copy) NSString *scrollMode;

- (void)scrollToPoint:(CGPoint)point;
- (void)scrollToRect:(CGRect)rect;

@end

@interface CALayer (CALayerScrolling)

- (void)scrollPoint:(CGPoint)point;
- (void)scrollRectToVisible:(CGRect)rect;
- (CGRect)visibleRect;

@end
