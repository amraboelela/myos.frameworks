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

#ifdef ANDROID
#import <GLES/gl.h>
#else
#import <GL/gl.h>
#endif

typedef enum {
    EAGLChildApplicationMessageEndOfMessage,
    EAGLChildApplicationMessageGenTexture,
} EAGLChildApplicationMessage;

#define _kEAGLChildApplicationPipeRead   110
#define _kEAGLChildApplicationPipeWrite  121

#ifdef __cplusplus
extern "C" {
#endif
    int EAGLChildApplicationGenTexture();
    void EAGLChildApplicationLoadImage(int textureID, int width, int height, const GLvoid *pixels);
    void EAGLChildApplicationDraw(int textureID, const GLvoid *texCoords, const GLvoid *vertices, GLfloat opacity);
    void EAGLChildApplicationSwapBuffers();
    void EAGLChildApplicationDeleteTexture();
#ifdef __cplusplus
}
#endif
