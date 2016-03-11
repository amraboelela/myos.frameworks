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

#import "EAGLTexture.h"
#import <CoreGraphics/CoreGraphics-private.h>

@implementation EAGLTexture

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        //DLog(@"init - glGenTextures");
        //glGenTextures(1, &_textureID);
        _numberOfTextures = 0;
        _textureIDs = NULL;
        //DLog(@"init - glGenTextures _textureID: %d", _textureID);
    }
    return self;
}

- (void)dealloc
{
    if (_numberOfTextures>0) {
        glDeleteTextures(_numberOfTextures, _textureIDs);
        free(_textureIDs);
    }
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; _numberOfTextures: %d; _textureIDs:%p>", [self className], self, _textureIDs];
}

@end

#pragma mark - Public functions

void _EAGLTextureLoad(EAGLTexture *texture, NSArray *images)
{
    //DLog();
    if (texture->_numberOfTextures != images.count) {
        _EAGLTextureUnload(texture);
        texture->_numberOfTextures = images.count;
        texture->_textureIDs = malloc(texture->_numberOfTextures * sizeof(GLuint));
        glGenTextures(texture->_numberOfTextures, texture->_textureIDs);
    }
    //DLog(@"glGetError: %d", glGetError());
    //DLog(@"image: %@", image);
    for (int i=0; i<texture->_numberOfTextures; i++) {
        CGImageRef image = [images objectAtIndex:i];
        size_t width = CGImageGetWidth(image);
        size_t height = CGImageGetHeight(image);
        //DLog(@"width: %d, height: %d", width, height);
        CGDataProviderRef provider = CGImageGetDataProvider(image);
        glBindTexture(GL_TEXTURE_2D, texture->_textureIDs[i]);
        const uint8_t *pixels = (const uint8_t *)[provider bytePointer];
        //DLog(@"glGetError: %d", glGetError());
        //DLog(@"width:%d, height:%d, textureID:%d", width, height, texture->_textureIDs[i]);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    //DLog(@"glGetError: %d", glGetError());
}

void _EAGLTextureUnload(EAGLTexture *texture)
{
    if (texture->_numberOfTextures > 0) {
        //DLog(@"texture->_numberOfTextures: %d", texture->_numberOfTextures);
        //DLog(@"textureID:%d", texture->_textureIDs[0]);
        glDeleteTextures(texture->_numberOfTextures, texture->_textureIDs);
        texture->_numberOfTextures = 0;
        free(texture->_textureIDs);
        texture->_textureIDs = NULL;
    }
}

BOOL _EAGLTextureUnloaded(EAGLTexture *texture)
{
    return (texture->_numberOfTextures == 0);
}
