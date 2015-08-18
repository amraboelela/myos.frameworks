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

#import <QuartzCore/QuartzCore-private.h>

@implementation CATransactionGroup

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        _values = CFDictionaryCreateMutable(kCFAllocatorDefault, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //DLog();
        //float fNumber = 0.25;
        //CFNumberRef number = [NSNumber numberWithFloat:0.25]; //CFNumberCreate(NULL, kCFNumberFloatType, &fNumber);//[NSNumber numberWithFloat:0.25];
        //DLog(@"number: %@", number);
        //DLog(@"CFRetain(number): %@", CFRetain(number));
        //DLog(@"[number retainCount]: %d", [number retainCount]);
        //DLog(@"_values: %@", _values);
        //GSHashTableSetValue(_values, kCATransactionAnimationDuration, number);
        CFDictionarySetValue(_values, kCATransactionAnimationDuration, [NSNumber numberWithFloat:0.25]);
        //DLog();
        CFDictionarySetValue(_values, kCATransactionDisableActions, [NSNumber numberWithBool:NO]);
        //DLog(@"_values: %@", _values);
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_values);
    [super dealloc];
}

@end
