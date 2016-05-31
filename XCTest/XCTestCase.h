/*
 Copyright © 2016 myOS Group.
 
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

#import <XCTest/XCAbstractTest.h>

@interface XCTestCase : XCTest

@end

extern int _failureCount;

#define XCTAssertEqualObjects(object1, object2, message) \
    if (![object1 isEqualTo:object2]) { \
        _failureCount++; \
        DLog(@"error: %@", message); \
    } \


#define XCTAssertNil(object1, message) \
    if (object1 != nil) { \
        _failureCount++; \
        DLog(@"error: %@", message); \
    } \
