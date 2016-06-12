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

int _testCount = 0;
int _failureCount = 0;
NSTimeInterval _totalTime = 0;

@implementation XCTestCase

- (void)runTest
{
    Class clz = [self class];
    NSString *className = NSStringFromClass(clz);
    NSLog(@"Test Suite '%@' started.", className);
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    _testCount = 0;
    _failureCount = 0;
    _totalTime = 0;
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = [NSString stringWithFormat:@"%s", sel_getName(method_getName(method))];
        if ([methodName rangeOfString:@"test"].location == 0) {
            _testCount++;
            NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
            [self setUp];
            NSLog(@"Test Case '%@' started.", methodName);
            int prevFailureCount = _failureCount;
            SEL selector = NSSelectorFromString(methodName);
            [self performSelector:selector];
            _totalTime += [NSDate timeIntervalSinceReferenceDate] - currentTime;
            [self tearDown];
            if (_failureCount > prevFailureCount) {
                NSLog(@"Test Case '%@' failed (%0.3f seconds).", methodName, [NSDate timeIntervalSinceReferenceDate] - currentTime);
            } else {
                NSLog(@"Test Case '%@' passed (%0.3f seconds).", methodName, [NSDate timeIntervalSinceReferenceDate] - currentTime);
            }
        }
    }
    if (_failureCount > 0) {
        NSLog(@"Test Suite '%@' failed.", className);
    } else {
        NSLog(@"Test Suite '%@' passed.", className);
    }
    NSLog(@"     Executed %d test%@, with %d failure%@ in %0.3f seconds", _testCount, (_testCount > 1)?@"s":@"",  _failureCount, (_failureCount > 1)?@"s":@"", _totalTime);
    free(methods);
}

@end

#pragma mark - Private functions

