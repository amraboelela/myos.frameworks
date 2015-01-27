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

#import <CoreAnimation/CoreAnimation-private.h>

NSString *CAPointDescription(CAPoint p)
{
    return [NSString stringWithFormat:@"p.x: %0.1f p.y: %0.1f p.z: %0.1f", p.x, p.y, p.z];
}

CAPoint CAPointMake(CGFloat x, CGFloat y, CGFloat z)
{
    return (CAPoint) {
        x,y,z
    };
}

CAPoint CAPointMakeCGPoint(CGPoint p)
{
    return CAPointMake(p.x, p.y, 0);
}

CGPoint CAPointGetCGPoint(CAPoint p)
{
    return CGPointMake(p.x, p.y);
}

CAPoint CAPointSubtract(CAPoint p1, CAPoint p2)
{
    return (CAPoint) {
        p1.x - p2.x, p1.y - p2.y, p1.z - p2.z
    };
}
/*
CAPoint CAPointMakePoint(CAPoint p1, CAPoint p2)
{
    return (CAPoint) {
        p1.x - p2.x, p1.y - p2.y, p1.z - p2.z
    };
}*/

CAPoint CAPointAdd(CAPoint p1, CAPoint p2)
{
    return (CAPoint) {
        p1.x + p2.x, p1.y + p2.y, p1.z + p2.z
    };
}

CAPoint CAPointTransform(CAPoint p, CATransform3D t)
{
    CAPoint result;
    result.x = p.x*t.m11 + p.y*t.m21 + p.z*t.m31 + t.m41;
    result.y = p.x*t.m12 + p.y*t.m22 + p.z*t.m32 + t.m42;
    result.z = p.x*t.m13 + p.y*t.m23 + p.z*t.m33 + t.m43;
    return result;
}

