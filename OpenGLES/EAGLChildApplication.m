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

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL-private.h>
#import <IOKit/IOKit.h>
#import <CoreAnimation/CoreAnimation.h>

#define _kTimeoutLimit 5.0

#pragma mark - Shared functions

int EAGLChildApplicationGenTexture()
{
    //DLog();
    IOPipeWriteMessageWithPipe(EAGLParentMessageGenTexture, YES, _kEAGLChildApplicationPipeWrite);
    NSTimeInterval startTime = EAGLCurrentTime();
    int message;
    while (YES) {
        usleep(1000);
        message = IOPipeReadMessageWithPipe(_kEAGLChildApplicationPipeRead);
        switch (message) {
            case EAGLChildApplicationMessageEndOfMessage: {
                //DLog(@"MAPipeMessageEndOfMessage");
                break;
            }
            case EAGLChildApplicationMessageGenTexture:
                //DLog(@"EAGLChildApplicationMessageGenTexture");
                return IOPipeReadIntWithPipe(_kEAGLChildApplicationPipeRead);
            default:
                DLog(@"message: %d", message);
                break;
                //return -1;
        }
        if (EAGLCurrentTime() - startTime > _kTimeoutLimit) {
            DLog(@"EAGLCurrentTime() - startTime > _kTimeoutLimit");
            return 0;
        }
    }
}

void EAGLChildApplicationLoadImage(int textureID, int width, int height, const GLvoid *pixels)
{
    //DLog(@"pixels: %p", pixels);
    IOPipeWriteMessageWithPipe(EAGLParentMessageLoadImage, NO, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteIntWithPipe(textureID, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteIntWithPipe(width, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteIntWithPipe(height, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteDataWithPipe(pixels, width*height*4, _kEAGLChildApplicationPipeWrite);
}

void EAGLChildApplicationDraw(int textureID, const GLvoid *texCoords, const GLvoid *vertices, GLfloat opacity)
{
    //DLog();
    IOPipeWriteMessageWithPipe(EAGLParentMessageDraw, NO, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteIntWithPipe(textureID, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteDataWithPipe(texCoords, sizeof(GLfloat)*8, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteDataWithPipe(vertices, sizeof(GLfloat)*8, _kEAGLChildApplicationPipeWrite);
    IOPipeWriteFloatWithPipe(opacity, _kEAGLChildApplicationPipeWrite);
    //DLog(@"opacity: %f", opacity);
}

void EAGLChildApplicationSwapBuffers()
{
    //DLog();
    IOPipeWriteMessageWithPipe(EAGLParentMessageSwapBuffers, YES, _kEAGLChildApplicationPipeWrite);
}

void EAGLChildApplicationDeleteTexture()
{
    DLog();
}
