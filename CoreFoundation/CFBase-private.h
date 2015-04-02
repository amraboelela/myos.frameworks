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

#import <CoreFoundation/CFBase.h>

#ifdef ANDROID

#import <android/log.h>

#ifndef RD_LOG
#define RD_LOG
#define printf(...) __android_log_print(ANDROID_LOG_DEBUG, "", __VA_ARGS__);
#define printfWithProcess(process, ...) __android_log_print(ANDROID_LOG_DEBUG, process, __VA_ARGS__);
#endif

#endif /* ANDROID */

CF_EXPORT long CFGetFreeMemory(); // in KB

CF_INLINE int CFRangeMaxRange(CFRange range)
{
    return range.location + range.length;
}

CF_INLINE CFRange CFRangeIntersection(CFRange aRange, CFRange bRange)
{
    CFRange range;
    
    if (NSMaxRange(aRange) < bRange.location || NSMaxRange(bRange) < aRange.location) {
        return CFRangeMake(0, 0);
    }
    range.location = MAX(aRange.location, bRange.location);
    range.length   = MIN(NSMaxRange(aRange), NSMaxRange(bRange))
    - range.location;
    return range;
}
