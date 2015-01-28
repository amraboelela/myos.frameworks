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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLTexture.h>

#ifdef ANDROID
#import <GLES/gl.h>
#import <OpenGLES/EAGLML.h>
#import <OpenGLES/EAGLMA.h>
#endif

extern BOOL _EAGLSwappingBuffers;

EAGLContext *_EAGLGetCurrentContext();
void _EAGLSetup();
void _EAGLSetSwapInterval(int interval);
void _EAGLClear();
void _EAGLFlush();
void _EAGLSwapBuffers();
NSTimeInterval EAGLCurrentTime();
