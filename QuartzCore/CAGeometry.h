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

#import <QuartzCore/CATransform3D.h>

typedef struct {
    CGFloat x;
    CGFloat y;
    CGFloat z;
} CAPoint;

NSString *CAPointDescription(CAPoint p);
CAPoint CAPointMake(CGFloat x, CGFloat y, CGFloat z);
CAPoint CAPointMakeCGPoint(CGPoint p);
CGPoint CAPointGetCGPoint(CAPoint p);
//CAPoint CAPointMakePoint(CAPoint p1, CAPoint p2);
CAPoint CAPointTransform(CAPoint p, CATransform3D t);
CAPoint CAPointSubtract(CAPoint p1, CAPoint p2);
CAPoint CAPointAdd(CAPoint p1, CAPoint p2);