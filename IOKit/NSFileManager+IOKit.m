/*
 Copyright © 2015-2016 myOS Group.
 
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

static NSString *_myOSPath = nil;
static NSString *_myAppsPath = nil;

#pragma mark - Public functions

NSString *_NSFileManagerMyOSPath()
{
    if (!_myOSPath) {
        _myOSPath = IOPipeRunCommand(@"echo ${MYOS_PATH}", YES);
        _myOSPath = [[_myOSPath substringToIndex:_myOSPath.length-1] retain];
        //DLog(@"_myOSPath: %@", _myOSPath);
    }
    return _myOSPath;
}

NSString *_NSFileManagerMyAppsPath()
{
    if (!_myAppsPath) {
#ifdef ANDROID
        _myAppsPath = @"/data/data/com.myos.myapps";
#else
        //_myAppsPath = IOPipeRunCommand(@"echo ${MYOS_PATH}", YES);
        //_myAppsPath = [_myAppsPath substringToIndex:_myAppsPath.length-1];
        _myAppsPath = [[NSString stringWithFormat:@"%@/myapps/targets/myApps/myApps.app", _NSFileManagerMyOSPath()] retain];
        //DLog(@"_myAppsPath: %@", _myAppsPath);
#endif
    }
    return _myAppsPath;
}

NSString *_NSFileManagerSetMyAppsPath(NSString *myAppsPath)
{
    _myAppsPath = myAppsPath;
    //DLog(@"_myAppsPath: %@", _myAppsPath);
}
