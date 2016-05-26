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

@implementation XCTest

- (void)setup
{
    
}

- (void)runTest
{
    [self setup];
    //DLog(@"To Do : run the tests");
    
    Class clz = [self class];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString *methodName = [NSString stringWithFormat:@"%s", sel_getName(method_getName(method))];
        if ([methodName rangeOfString:@"test"].location == 0) {
            DLog(@"Test case %@ started", methodName);
            NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
            SEL selector = NSSelectorFromString(methodName);
            [self performSelector:selector];
            DLog(@"Test case %@ passed (%0.3f seconds)", methodName, [NSDate timeIntervalSinceReferenceDate] - currentTime);
        }
    }
    
    free(methods);
    
    
    [self tearDown];
}

- (void)tearDown
{
    
}

@end
