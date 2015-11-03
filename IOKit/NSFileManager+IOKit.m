/*
 Copyright © 2015 myOS Group.
 
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

#import <IOKit/IOKit.h>

static NSString *_myappsPath = nil;

#pragma mark - Public functions

NSString *_NSFileManagerMyAppsPath()
{
    if (!_myappsPath) {
#ifdef ANDROID
        _myappsPath = @"/data/data/com.myos.myapps";
#else
        _myappsPath = IOPipeRunCommand(@"echo ${MYOS_PATH}", YES);
        _myappsPath = [_myappsPath substringToIndex:_myappsPath.length-1];
        _myappsPath = [NSString stringWithFormat:@"%@/myapps", _myappsPath];
#endif
    }
    return _myappsPath;
}

NSString *_NSFileManagerSetMyAppsPath(NSString *myappsPath)
{
    _myappsPath = myappsPath;
}