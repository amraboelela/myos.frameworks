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

#import <XCTest/XCTestCase.h>

@implementation XCTestCase

- (void)runTest
{
    [self setup];
    
    Class clz = [self class];
    NSString *className = NSStringFromClass(clz);
    NSLog(@"Test Suite '%@' started.", className);
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    int count = 0;
    NSTimeInterval totalTime = 0;
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = [NSString stringWithFormat:@"%s", sel_getName(method_getName(method))];
        if ([methodName rangeOfString:@"test"].location == 0) {
            count++;
            NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
            //NSLog(@"currentTime: %0.0f", currentTime);
            NSLog(@"Test Case '%@' started.", methodName);
            SEL selector = NSSelectorFromString(methodName);
            [self performSelector:selector];
            totalTime += [NSDate timeIntervalSinceReferenceDate] - currentTime;
            NSLog(@"Test Case '%@' passed (%0.3f seconds).", methodName, [NSDate timeIntervalSinceReferenceDate] - currentTime);
        }
    }
    NSLog(@"Test Suite '%@' passed.", className);
    NSLog(@"     Executed %d tests, with 0 failures in %0.3f seconds", count, totalTime);
    free(methods);
    
    [self tearDown];
}

@end
