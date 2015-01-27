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

#import <CoreGraphics/CoreGraphics.h>
#import <GLES/gl.h>

@interface EAGLTexture : NSObject
{
@public
    int _numberOfTextures;
    GLuint *_textureIDs;
}

@end

void _EAGLTextureLoad(EAGLTexture *texture, NSArray *images);
void _EAGLTextureUnload(EAGLTexture *texture);
BOOL _EAGLTextureUnloaded(EAGLTexture *texture);
