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

typedef enum {
    EAGLParentMessageEndOfMessage,
    EAGLParentMessageChildIsReady,
    EAGLParentMessageGenTexture,
    EAGLParentMessageLoadImage,
    EAGLParentMessageDraw,
    EAGLParentMessageSwapBuffers,
    EAGLParentMessageDeleteTexture,
} EAGLParentMessage;

void EAGLParentSetChildAppIsRunning(BOOL isRunning);
void EAGLParentHandleMessages();
void EAGLParentSetPipes(int pipeRead, int pipeWrite);
void EAGLParentGenTexture();
void EAGLParentLoadImage();
void EAGLParentDraw();
void EAGLParentDeleteTexture();
