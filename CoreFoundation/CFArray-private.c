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

#import "CFRuntime.h"
//#include "CFArray.h"
#import "CFArray-private.h"
#import "CFBase.h"
#import "CFString.h"

#import <string.h>
//#include <assert.h>
#import <stdio.h>
#import <CoreFoundation/GSPrivate.h>

#import "GSCArray.h"
#import "GSObjCRuntime.h"

static CFTypeID _kCFArrayTypeID = 0;

struct __CFArray
{
    CFRuntimeBase _parent;
    const CFArrayCallBacks *_callBacks;
    const void **_contents;
    CFIndex _count;
};

CFIndex _CFArrayGetIndexOfValue(CFArrayRef array, const void *value)
{
    CFRange range = {0, CFArrayGetCount(array)};
    return CFArrayGetFirstIndexOfValue(array, range, value);
}

void _CFArrayRemoveValue(CFMutableArrayRef array, const void *value)
{
    CF_OBJC_FUNCDISPATCHV(_kCFArrayTypeID, void, array, "removeObject:", value);
    //loop on the array to delete values equal to the element
    CFIndex idx;
    const void **contents;
    CFArrayEqualCallBack equal = array->_callBacks->equal;
    contents = array->_contents;
    if (equal) {
        for (idx = 0; idx < array->_count ;++idx) {
            if (equal (value, contents[idx])) {
                CFArrayReplaceValues(array, CFRangeMake(idx, 1), NULL, 0);
            }
        }
    } else {
        for (idx = 0 ; idx < array->_count ;++idx) {
            if (value == contents[idx]) {
                CFArrayReplaceValues (array, CFRangeMake(idx, 1), NULL, 0);
            }
        }
    }
}

void _CFArrayMoveValueToTop(CFMutableArrayRef array, const void *value)
{
    CFRetain(value);
    _CFArrayRemoveValue(array, value);
    CFArrayAppendValue(array, value);
    CFRelease(value);
}

const void *_CFArrayGetLastValue(CFMutableArrayRef array)
{
    return (array->_contents)[array->_count-1];
}
