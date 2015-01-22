/** CGImage (private)
 
 <abstract>C Interface to graphics drawing library</abstract>
 
 Copyright <copy>(C) 2014 Free Software Foundation, Inc.</copy>
 
 Author: Amr Aboelela <amraboelela@gmail.com>
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import <CoreGraphics/CGImage.h>
#import <cairo/cairo.h>

@interface CGImage : NSObject {
@public
    bool ismask;
    size_t width;
    size_t height;
    size_t bitsPerComponent;
    size_t bitsPerPixel;
    size_t bytesPerRow;
    CGDataProviderRef dp;
    CGFloat *decode;
    bool shouldInterpolate;
    /* alphaInfo is always AlphaNone for mask */
    CGBitmapInfo bitmapInfo;
    /* cspace and intent are only set for image */
    CGColorSpaceRef cspace;
    CGColorRenderingIntent intent;
    /* used for CGImageCreateWithImageInRect */
    CGRect crop;
    cairo_surface_t *surf;
}

- (id)initWithWidth:(size_t)aWidth
             height:(size_t)aHeight
   bitsPerComponent:(size_t)aBitsPerComponent
       bitsPerPixel:(size_t)aBitsPerPixel
        bytesPerRow:(size_t)aBytesPerRow
         colorSpace:(CGColorSpaceRef)aColorspace
         bitmapInfo:(CGBitmapInfo)aBitmapInfo
           provider:(CGDataProviderRef)aProvider
             decode:(const CGFloat *)aDecode
  shouldInterpolate:(bool)anInterpolate
             intent:(CGColorRenderingIntent)anIntent;

@end


