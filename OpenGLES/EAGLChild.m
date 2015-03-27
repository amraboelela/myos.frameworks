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
#import <QuartzCore/QuartzCore.h>

#define _kTimeoutLimit 5.0

#pragma mark - Shared functions

int EAGLChildGenTexture()
{
    //DLog();
    IOPipeWriteMessageWithPipe(EAGLParentMessageGenTexture, YES, _kEAGLChildPipeWrite);
    NSTimeInterval startTime = EAGLCurrentTime();
    int message;
    while (YES) {
        usleep(1000);
        message = IOPipeReadMessageWithPipe(_kEAGLChildPipeRead);
        switch (message) {
            case EAGLChildMessageEndOfMessage: {
                //DLog(@"MAPipeMessageEndOfMessage");
                break;
            }
            case EAGLChildMessageGenTexture:
                //DLog(@"EAGLChildMessageGenTexture");
                return IOPipeReadIntWithPipe(_kEAGLChildPipeRead);
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

void EAGLChildLoadImage(int textureID, int width, int height, const GLvoid *pixels)
{
    //DLog(@"pixels: %p", pixels);
    IOPipeWriteMessageWithPipe(EAGLParentMessageLoadImage, NO, _kEAGLChildPipeWrite);
    IOPipeWriteIntWithPipe(textureID, _kEAGLChildPipeWrite);
    IOPipeWriteIntWithPipe(width, _kEAGLChildPipeWrite);
    IOPipeWriteIntWithPipe(height, _kEAGLChildPipeWrite);
    IOPipeWriteDataWithPipe(pixels, width*height*4, _kEAGLChildPipeWrite);
}

void EAGLChildDraw(int textureID, const GLvoid *texCoords, const GLvoid *vertices, GLfloat opacity)
{
    //DLog();
    IOPipeWriteMessageWithPipe(EAGLParentMessageDraw, NO, _kEAGLChildPipeWrite);
    IOPipeWriteIntWithPipe(textureID, _kEAGLChildPipeWrite);
    IOPipeWriteDataWithPipe(texCoords, sizeof(GLfloat)*8, _kEAGLChildPipeWrite);
    IOPipeWriteDataWithPipe(vertices, sizeof(GLfloat)*8, _kEAGLChildPipeWrite);
    IOPipeWriteFloatWithPipe(opacity, _kEAGLChildPipeWrite);
    //DLog(@"opacity: %f", opacity);
}

void EAGLChildSwapBuffers()
{
    //DLog();
    IOPipeWriteMessageWithPipe(EAGLParentMessageSwapBuffers, YES, _kEAGLChildPipeWrite);
}

void EAGLChildDeleteTexture()
{
    DLog();
}
