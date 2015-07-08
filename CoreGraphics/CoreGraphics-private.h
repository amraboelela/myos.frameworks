/*
 Copyright © 2014-2015 myOS Group.
 
 This file is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This file is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 Contributor(s):
 Amr Aboelela <amraboelela@gmail.com>
 */

#define _MaximumNumberOfGlyphs      258

#import <CoreGraphics/CoreGraphics.h>
#import <CoreGraphics/CairoFontX11-private.h>
#import <CoreGraphics/CGColorSpace-private.h>
#import <CoreGraphics/CGDataProvider-private.h>
#import <CoreGraphics/CGImageDestination-private.h>
#import <CoreGraphics/CGBitmapContext-private.h>
#import <CoreGraphics/CGContext-private.h>
#import <CoreGraphics/CGFont-private.h>
#import <CoreGraphics/CGImageSource-private.h>
#import <CoreGraphics/CGColor-private.h>
#import <CoreGraphics/CGDataConsumer-private.h>
#import <CoreGraphics/CGGradient-private.h>
#import <CoreGraphics/CGGeometry-private.h>
#import <CoreGraphics/CGImage-private.h>
#import <cairo/cairo.h>

#ifdef ANDROID
#import <rd_app_glue.h>
void _CoreGraphicsInitialize(struct android_app *app);

extern struct android_app *_app;
#endif
