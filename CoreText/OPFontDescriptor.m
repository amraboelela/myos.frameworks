/** <title>OPFontDescriptor</title>

   <abstract>The font descriptor class</abstract>

   Copyright (C) 2007-2015 Free Software Foundation, Inc.

   Author: H. Nikolaus Schaller <hns@computer.org>
   Date: 2006
   Extracted from OPFont: Fred Kiefer <fredkiefer@gmx.de>
   Date August 2007
   Modified by: Amr Aboelela <amraboelela@gmail.com>
   Date: Mar 2015

   This file is part of the GNUstep GUI Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/ 

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <CoreGraphics/CoreGraphics-private.h>

#import "CTFontDescriptor.h"
#import "OPFontDescriptor.h"


@implementation OPFontDescriptor

+ (Class)fontDescriptorClass
{
  return NSClassFromString(@"OPFontDescriptor");//(@"OPFontconfigFontDescriptor");
}

+ (id)fontDescriptorWithFontAttributes: (NSDictionary *)attributes
{
  return AUTORELEASE([[[self fontDescriptorClass] alloc] initWithFontAttributes: attributes]);
}

+ (id)fontDescriptorWithName: (NSString *)name
		       matrix: (NSAffineTransform *)matrix
{
  return [self fontDescriptorWithFontAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:
      name, OPFontNameAttribute,
      matrix, OPFontMatrixAttribute,
      nil]];
}

+ (id) fontDescriptorWithName: (NSString *)name size: (CGFloat)size
{
  return [self fontDescriptorWithFontAttributes:
    [NSDictionary dictionaryWithObjectsAndKeys:
      name, OPFontNameAttribute,
      [NSString stringWithFormat: @"%f", size], kCTFontSizeAttribute,
      nil]];
}

- (NSDictionary *) fontAttributes
{
  return _attributes;
}

- (OPFontDescriptor *) fontDescriptorByAddingAttributes:
  (NSDictionary *)attributes
{
  NSMutableDictionary *m = [_attributes mutableCopy];
  OPFontDescriptor *new;

  [m addEntriesFromDictionary: attributes];

  new = [isa fontDescriptorWithFontAttributes: m];
  RELEASE(m);

  return new;
}

- (OPFontDescriptor *) fontDescriptorWithFace: (NSString *)face
{
  return [self fontDescriptorByAddingAttributes:
    [NSDictionary dictionaryWithObject: face forKey: OPFontFaceAttribute]];
}

- (OPFontDescriptor *) fontDescriptorWithFamily: (NSString *)family
{
  return [self fontDescriptorByAddingAttributes:
    [NSDictionary dictionaryWithObject: family forKey: OPFontFamilyAttribute]];
}

- (OPFontDescriptor *) fontDescriptorWithMatrix: (NSAffineTransform *)matrix
{
  return [self fontDescriptorByAddingAttributes:
    [NSDictionary dictionaryWithObject: matrix forKey: OPFontMatrixAttribute]];
}

- (OPFontDescriptor *) fontDescriptorWithSize: (CGFloat)size
{
  return [self fontDescriptorByAddingAttributes:
    [NSDictionary dictionaryWithObject: [NSString stringWithFormat:@"%f", size]
				forKey: kCTFontSizeAttribute]];
}

- (OPFontDescriptor *) fontDescriptorWithSymbolicTraits:
  (OPFontSymbolicTraits)symbolicTraits
{
  NSDictionary *traits;

  traits = [_attributes objectForKey: OPFontTraitsAttribute];
  if (traits == nil)
    {
      traits = [NSDictionary dictionaryWithObject: 
			       [NSNumber numberWithUnsignedInt: symbolicTraits]
			     forKey: OPFontSymbolicTrait];
    }
  else
    {
      traits = AUTORELEASE([traits mutableCopy]);
      [(NSMutableDictionary*)traits setObject: 
			       [NSNumber numberWithUnsignedInt: symbolicTraits]
			     forKey: OPFontSymbolicTrait];
    }

  return [self fontDescriptorByAddingAttributes:
		 [NSDictionary dictionaryWithObject: traits
			       forKey: OPFontTraitsAttribute]];
}

- (id) initWithFontAttributes: (NSDictionary *)attributes
{
    if ((self = [super init]) != nil)
    {
        if (attributes) {
            _attributes = [attributes copy];
            // fill the rest of attributes given the font
            NSString * fontName = [attributes objectForKey:kCTFontNameAttribute];
            
            if (fontName != nil)
            {
                FcPattern *pat = opal_FcPatternCacheLookup([fontName UTF8String]);
                cairo_font_face_t *unscaled;
                if(pat) {
                    unscaled = cairo_ft_font_face_create_for_pattern(pat);
                } else {
                    [self release];
                    return NULL;
                }
                cairo_matrix_t ident;
                cairo_matrix_init_identity(&ident);
                cairo_font_options_t *opts = cairo_font_options_create();
                cairo_font_options_set_hint_metrics(opts, CAIRO_HINT_METRICS_OFF);
                cairo_font_options_set_hint_style(opts, CAIRO_HINT_STYLE_NONE);
                //DLog(@"4");
                self->cairofont = cairo_scaled_font_create(unscaled, &ident, &ident, opts);
                //DLog(@"5");
                cairo_font_options_destroy(opts);
                //DLog(@"6");
            }
        } else
            _attributes = [NSDictionary new];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)aCoder
{
	if ([aCoder allowsKeyedCoding])
  {
    [aCoder encodeObject: _attributes forKey: @"NSAttributes"];
  }
  else
  {
    [aCoder encodeObject: _attributes];
  }
}

- (id) initWithCoder: (NSCoder *)aDecoder
{
  if ([aDecoder allowsKeyedCoding])
  {
    _attributes = RETAIN([aDecoder decodeObjectForKey: @"NSAttributes"]);
  }
  else
  {
    [aDecoder decodeValueOfObjCType: @encode(id) at: &_attributes];
  }
  return self;
}
	
- (void) dealloc;
{
  RELEASE(_attributes);
  [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; fontAttributes: %@>", [self className], self, _attributes];
}

- (id) copyWithZone: (NSZone *)z
{
  OPFontDescriptor *f = [isa allocWithZone: z];

  if (f != nil)
  {
    f->_attributes = [_attributes copyWithZone: z];
  }
  return f;
}

/**
 * Override in subclass
 */
- (NSArray *) matchingFontDescriptorsWithMandatoryKeys: (NSSet *)keys
{
  return nil;
}

- (OPFontDescriptor *) matchingFontDescriptorWithMandatoryKeys: (NSSet *)keys
{
  NSArray *found = [self matchingFontDescriptorsWithMandatoryKeys: keys];

  if (found && ([found count] > 0))
  {
    return [found objectAtIndex: 0];
  }
  else
  {
    return nil;
  }
}

- (NSAffineTransform *) matrix
{
  return [self objectForKey: OPFontMatrixAttribute];
}

/**
 * Override in subclass
 */
- (id) objectFromPlatformFontPatternForKey: (NSString *)attribute
{
  return nil;
}

/**
 * Override in subclass
 */
- (id) localizedObjectFromPlatformFontPatternForKey: (NSString*)key language: (NSString*)language
{
  return nil;
}

- (id) objectForKey: (NSString *)attribute
{
  id object = [_attributes objectForKey: attribute];

  if (nil == object)
  {
    return [self objectFromPlatformFontPatternForKey: attribute];
  }
  return object;
}

- (id) localizedObjectForKey: (NSString*)attribute language: (NSString*)language
{
  id object = [self localizedObjectFromPlatformFontPatternForKey: attribute language: language];

  if (nil == object)
  {
    return [self objectForKey: attribute];
  }
  return object;
}

- (CGFloat) pointSize
{
  // NOTE: 0 is returned if point size is not defined
  return [[self objectForKey: kCTFontSizeAttribute] doubleValue];
}

- (NSString *) postscriptName
{
  return [self objectForKey: kCTFontNameAttribute];
}

- (OPFontSymbolicTraits) symbolicTraits
{
  NSDictionary *traits = [self objectForKey: OPFontTraitsAttribute];
  if (traits == nil)
  {
    return 0;
  }
  else
  {
    return [[traits objectForKey: OPFontSymbolicTrait] unsignedIntValue];
  }
}

@end
