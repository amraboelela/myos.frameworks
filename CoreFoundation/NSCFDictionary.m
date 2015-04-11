/* NSCFDictionary.m
   
   Copyright (C) 2013-2015 Free Software Foundation, Inc.
   
   Written by: Lubos Dolezel
   Date: March, 2013
   Modified by: Amr Aboelela <amraboelela@gmail.com>
   Date: Apr 2015
 
   This file is part of GNUstep CoreBase Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/

#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>

#include "NSCFType.h"
#include "CoreFoundation/CFDictionary.h"

@interface NSCFDictionary : NSMutableDictionary
NSCFTYPE_VARS
@end

@interface NSCFDictionaryKeyEnumerator : NSEnumerator
{
    NSCFDictionary    *dictionary;
    CFArrayRef collection;
    unsigned pos;
}
- (id) initWithDictionary: (NSCFDictionary*)d;
@end

@interface NSCFDictionaryObjectEnumerator : NSCFDictionaryKeyEnumerator
@end

@interface NSDictionary (CoreBaseAdditions)
- (CFTypeID) _cfTypeID;

- (CFIndex) _cfCountOfValue: (id)value;
@end

@interface NSMutableDictionary (CoreBaseAdditions)
- (void) _cfSetValue: (id)key
                    : (id)value;

- (void) _cfReplaceValue: (id)key
                        : (id)value;
@end

@implementation NSCFDictionary
+ (void) load
{
  NSCFInitialize ();
}

+ (void) initialize
{
  GSObjCAddClassBehavior (self, [NSCFType class]);
}

- (id) initWithObjects: (const id[])objects
               forKeys: (const id<NSCopying>[])keys
                 count: (NSUInteger)count
{
  RELEASE(self);
  
  self = (NSCFDictionary*) CFDictionaryCreate(kCFAllocatorDefault,
    (const void **) keys, (const void **) objects, count,
    &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  
  return self;
}

- (id) initWithCapacity: (NSUInteger)numItems
{
  RELEASE(self);
  
  self = (NSCFDictionary*) CFDictionaryCreateMutable(kCFAllocatorDefault,
    numItems, &kCFTypeDictionaryKeyCallBacks,
    &kCFTypeDictionaryValueCallBacks);
  
  return self;
}

- (NSUInteger) count
{
  return (NSUInteger)CFDictionaryGetCount (self);
}

- (NSArray *)allKeys
{
  CFIndex keysCount = CFDictionaryGetCount(self);
  const void* keys[keysCount];
  CFDictionaryGetKeysAndValues(self, keys, NULL);
  return CFArrayCreate(NULL, keys, keysCount, NULL);
}

- (NSArray *)allKeysForObject:(id)anObject
{
  CFArrayRef keys = [self allKeys];
  CFMutableArrayRef result = CFArrayCreateMutable(NULL, 0, NULL);
  for (id key in keys) {
    if ([self valueForKey: key] == anObject) {
      CFArrayAppendValue(result, key);
    }
  }
  CFRelease(keys);
  return result;
}

- (NSArray *)allValues
{
  CFIndex valuesCount = CFDictionaryGetCount(self);
  const void* values[valuesCount];
  CFDictionaryGetKeysAndValues(self, NULL, values);
  return CFArrayCreate(NULL, values, valuesCount, NULL);
}

- (void)getObjects:(id __unsafe_unretained [])objects 
        andKeys:(id __unsafe_unretained [])keys
{
  CFDictionaryGetKeysAndValues(self, (const void **)keys, (const void **)objects);
}

- (id)objectForKeyedSubscript:(id)key
{
  return (id) CFDictionaryGetValue(self, (const void*) key);
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)anObject
{
  NSMutableArray* result = [[NSMutableArray alloc] initWithArray: keys];
  int i = 0;
  for (id key in keys) {
    if (! CFDictionaryGetValueIfPresent(self, (const void*) key
      , (const void**)[result objectAtIndex: i]))
    {
      [[result objectAtIndex:i] replaceObjectAtIndex:i withObject:anObject];
    }
    i++;
  }
  return result;
}

- (id)valueForKey:(NSString *)key
{
  return (id) CFDictionaryGetValue(self, (const void*) key);
}

- (NSEnumerator*) keyEnumerator
{
  CFIndex count;
  const void **keys;
  NSArray *array;
  
  count = CFDictionaryGetCount((CFDictionaryRef) self);
  keys = (const void**) malloc(sizeof(void*) * count);
  
  CFDictionaryGetKeysAndValues((CFDictionaryRef) self,
    keys, NULL);
  
  array = [NSArray arrayWithObjects: (const id*)keys
                              count: count];

  free((void*)keys);
  return [array objectEnumerator];
}

- (id) objectForKey: (id)aKey
{
  return (id) CFDictionaryGetValue((CFDictionaryRef) self, aKey);
}

- (NSEnumerator*) objectEnumerator
{
  CFIndex count;
  const void **values;
  NSArray *array;
  
  count = CFDictionaryGetCount((CFDictionaryRef) self);
  values = (const void**) malloc(sizeof(void*) * count);
  
  CFDictionaryGetKeysAndValues((CFDictionaryRef) self,
    NULL, values);
  
  array = [NSArray arrayWithObjects: (const id*)values
                              count: count];

  free((void*)values);
  return [array objectEnumerator];

}

- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState*)state
                                   objects: (__unsafe_unretained id[])stackbuf
                                     count: (NSUInteger)len
{
    if (state->state >= [self count]) {
        return 0;
    }
    state->mutationsPtr = (unsigned long *)self;
    NSEnumerator* enumerator = [self keyEnumerator];
    id setObject;
    int i = 0;
    while ((setObject = [enumerator nextObject]) != nil)
    {
        stackbuf[i++] = setObject;
    }
    state->state = i;
    state->itemsPtr = stackbuf;
    return i;
}


- (void) setObject: (id)anObject forKey: (id)aKey
{
  if (aKey == nil)
  {
    NSException *e;

    e = [NSException exceptionWithName: NSInvalidArgumentException
        reason: @"Tried to add nil key to dictionary"
      userInfo: self];
    [e raise];
  }
  if (anObject == nil)
  {
    NSException *e;
    NSString    *s;

    s = [NSString stringWithFormat:
      @"Tried to add nil value for key '%@' to dictionary", aKey];
    e = [NSException exceptionWithName: NSInvalidArgumentException
        reason: s
      userInfo: self];
    [e raise];
  }
  CFDictionarySetValue (self, (const void *) aKey, (const void *)anObject);
}

- (void) removeObjectForKey: (id)aKey
{
    if (aKey == nil)
    {
        NSLog(@"attempt to remove nil key from dictionary %@", self);
        return;
    }
    CFDictionaryRemoveValue(self, (const void *)aKey);
}

- (void) removeAllObjects
{
  CFDictionaryRemoveAllValues((CFMutableDictionaryRef) self);
}

- (NSString *)description
{
    return [super description];
}

@end

@implementation NSDictionary (CoreBaseAdditions)
- (CFTypeID) _cfTypeID
{
  return CFDictionaryGetTypeID();
}

- (CFIndex) _cfCountOfValue: (id)value
{
  CFIndex countOfValue = 0;
  CFIndex i;
  NSUInteger count;
  NSArray* array;
  
  // TODO: getObjects:andKeys: could be faster (less calls)
  
  array = [self allValues];
  count = [self count];
  
  for (i = 0; i < count; i++)
    {
      if ([[array objectAtIndex: i] isEqual: value])
        countOfValue++;
    }
  
  return countOfValue;
}

@end

@implementation NSMutableDictionary (CoreBaseAdditions)

- (void) _cfSetValue: (id)key
                    : (id)value
{
  [self removeObjectForKey: key];
  [self setObject: value
           forKey: key];
}

- (void) _cfReplaceValue: (id)key
                        : (id)value
{
  if ([self objectForKey: key] != NULL)
    {
      [self removeObjectForKey: key];
      [self setObject: value
               forKey: key];
    }
}

@end

@implementation NSCFDictionaryKeyEnumerator

- (id) initWithDictionary: (NSCFDictionary*)d
{
    self = [super init];
    if (self)
    {
        dictionary = (NSCFDictionary*)RETAIN(d);
        collection = [dictionary allKeys];
        pos = 0;
    }
    return self;
}

- (id) nextObject
{
    if (pos == [dictionary count])
    {
        return nil;
    }
    return CFArrayGetValueAtIndex(collection, pos++);
}

- (void) dealloc
{
    RELEASE(dictionary);
    CFRelease(collection);
    [super dealloc];
}

@end

@implementation NSCFDictionaryObjectEnumerator

- (id) initWithDictionary: (NSCFDictionary*)d
{
    self = [super init];
    if (self) {
        dictionary = (NSCFDictionary*)RETAIN(d);
        collection = [d allValues];
        pos = 0;
    }
    return self;
}

- (void) dealloc
{
    RELEASE(dictionary);
    CFRelease(collection);
    [super dealloc];
}

@end
