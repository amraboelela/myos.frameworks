/* NSCFSet.m
   
   Copyright (C) 2012-2015 Free Software Foundation, Inc.
   
   Written by: Ahmed Elmorsy <ahmedelmorsy89@gmail.com>
   Date: August, 2012
   Rewritten by: Lubos Dolezel
   Date: March, 2013
   Modified by: Amr Aboelela <amraboelela@gmail.com>
   Date: April, 2015
   
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

#import <Foundation/NSSet.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <GNUstepBase/NSDebug+GNUstepBase.h>
#import <CoreFoundation/NSCFType.h>
#import <CoreFoundation/CFSet.h>
#import <CoreFoundation/CFArray.h>
#import <CoreFoundation/GSHashTable.h>

@interface NSCFSet : NSMutableSet
NSCFTYPE_VARS
@end

@interface NSSet (CoreBaseAdditions)
- (CFTypeID) _cfTypeID;

- (id) _cfGetValue: (id) value;
- (void) _cfGetValues: (id[]) values;
@end

@interface NSMutableSet (CoreBaseAdditions)
- (void) _cfReplaceValue: (id) value;
- (void) _cfSetValue: (id) value;
@end

@interface NSCFSetEnumerator : NSEnumerator {
    CFArrayRef set;
    unsigned  pos;
}

- (id)initWithSet: (NSCFSet*)aSet;
@end

@implementation NSCFSet

+ (void) load
{
    NSCFInitialize ();
}

+ (void) initialize
{
    GSObjCAddClassBehavior (self, [NSCFType class]);
}

- (id) initWithObjects: (const id[])objects
                 count: (NSUInteger)count
{
    RELEASE(self);
    
    self = (NSCFSet*) CFSetCreate(NULL, (const void**)objects, count,
                                  &kCFTypeSetCallBacks);
    
    return self;
}

- (NSUInteger) count
{
    return CFSetGetCount(self);
}

- (id) member: (id)anObject
{
    id retval;
    
    if (CFSetGetValueIfPresent((CFSetRef)self, anObject,
                               (const void **)&retval))
    {
        return retval;
    }
    else
    {
        return NULL;
    }
}

- (NSArray *)allObjects
{
    //DLog();
    NSUInteger count = CFSetGetCount(self);
    const void** values = malloc(count * sizeof(void*));
    CFSetGetValues(self, values);
    NSArray *result = CFArrayCreate(NULL, values, count, NULL);
    free(values);
    return AUTORELEASE(result);
}

/**
 *  Return an arbitrary object from set, or nil if this is empty set.
 */
- (id)anyObject
{
    if ([self count] == 0)
        return nil;
    else
    {
        id e = [self objectEnumerator];
        return [e nextObject];
    }
}

- (BOOL) containsObject: (id)anObject
{
    return CFSetContainsValue(self, (const void*)anObject);
}

/**
 * Returns an enumerator describing the array sequentially
 * from the first to the last element.<br/>
 * If you use a mutable subclass of NSArray,
 * you should not modify the array during enumeration.
 */
- (NSEnumerator *)objectEnumerator
{
    DLog(@"objectEnumerator");
    id  e;
    e = [NSCFSetEnumerator allocWithZone: NSDefaultMallocZone()];
    e = [e initWithSet: self];
    return AUTORELEASE(e);
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id[])stackbuf
                                    count:(NSUInteger)len
{
    //DLog(@"state: %p", state);
    //DLog(@"len: %d", len);
    NSUInteger size = GSHashTableGetCount((GSHashTableRef)self);// [self count];
    //DLog(@"size: %d", size);
    NSInteger count;
    
    /* This is cached in the caller at the start and compared at each
     * iteration.   If it changes during the iteration then
     * objc_enumerationMutation() will be called, throwing an exception.
     */
    state->mutationsPtr = (unsigned long *)self;
    count = MIN(len, size - state->state);
    //DLog(@"count: %d", count);
    /* If a mutation has occurred then it's possible that we are being asked to
     * get objects from after the end of the array.  Don't pass negative values
     * to memcpy.
     */
    if (count > 0) {
        int p = state->state;
        //int i;
        const void **values = malloc(size * sizeof(void*));
        //CFSetGetValues(self, values);
        GSHashTableGetKeysAndValues((GSHashTableRef)self, values, NULL);
        for (int i = 0; i < count; i++, p++) {
            stackbuf[i] = (id)values[p];
        }
        state->state += count;
        free(values);
    } else {
        count = 0;
    }
    state->itemsPtr = stackbuf;
    return count;
}

- (void)dealloc
{
    CFRelease(self);
    [super dealloc];
}

//mutable functions
- (void)addObject: (id)anObject
{
    CFSetAddValue(self, anObject);
}

- (void)removeObject: (id)anObject
{
    CFSetRemoveValue(self, anObject);
}

- (void)removeAllObjects
{
    CFSetRemoveAllValues(self);
}

- (void)addObjectsFromArray: (NSArray*)array
{
    unsigned  i, c = [array count];
    for (i = 0; i < c; i++) {
        [self addObject: [array objectAtIndex: i]];
    }
}

@end

@implementation NSCFSetEnumerator

- (id)initWithSet:(NSCFSet *)aSet
{
    self = [super init];
    if (self != nil) {
        //DLog();
        const void** values;
        int length = CFSetGetCount(aSet);
        DLog(@"length: %d", length);
        values = malloc(length * sizeof(const void*));
        CFSetGetValues(aSet, values);
        set = CFArrayCreate(NULL, values, length, NULL);
        IF_NO_GC(RETAIN(set));
        pos = 0;
    }
    return self;
}

/**
 * Returns the next object in the enumeration or nil if there are no more
 * objects.<br />
 * NB. modifying a mutable array during an enumeration can break things ...
 * don't do it.
 */
- (id)nextObject
{
    if (pos >= CFArrayGetCount(set)) {
        return nil;
    }
    DLog(@"CFArrayGetValueAtIndex(set, pos): %p", CFArrayGetValueAtIndex(set, pos));
    return CFArrayGetValueAtIndex(set, pos++);
}

- (void)dealloc
{
    RELEASE(set);
    [super dealloc];
}

@end

@implementation NSSet (CoreBaseAdditions)
- (CFTypeID) _cfTypeID
{
  return CFSetGetTypeID();
}

- (id) _cfGetValue: (id) value
{
  NSEnumerator *enuM = [self objectEnumerator];
  id elem;
  
  while ((elem = [enuM nextObject]))
    {
      if ([elem isEqual: value])
        return elem;
    }
    
  return NULL;
}

- (void) _cfGetValues: (id[]) values
{
  NSArray *array = [self allObjects];
  [array getObjects: values
              range: NSMakeRange(0, [self count])];
}

@end

@implementation NSMutableSet (CoreBaseAdditions)
- (void) _cfReplaceValue: (id) value
{
    if ([self containsObject: value])
    {
        [self removeObject: value];
        [self addObject: value];
    }
}

- (void) _cfSetValue: (id) value
{
    [self removeObject: value];
    [self addObject: value];
}
@end
