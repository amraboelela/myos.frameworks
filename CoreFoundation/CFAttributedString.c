/* CFAttributedString.c
   
   Copyright (C) 2012 Free Software Foundation, Inc.
   
   Written by: Stefan Bidigaray
   Date: April, 2012
   
   This file is part of the GNUstep CoreBase Library.
   
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

#import <CoreFoundation/CoreFoundation-private.h>

static CFTypeID _kCFAttributedStringTypeID = 0;
static CFDictionaryRef _kCFAttributedStringBlankAttribute = NULL;
static CFMutableBagRef _kCFAttributedStringCache = NULL;
static GSMutex _kCFAttributedStringCacheLock;
static GSMutex _kCFAttributedStringBlankAttributeLock;

typedef struct
{
  CFIndex         index;
  CFDictionaryRef attrib;
} Attr;

struct __CFAttributedString
{
  CFRuntimeBase parent;
  CFStringRef   _string;
  Attr         *_attribs;
  CFIndex       _attribCount;
};

struct __CFMutableAttributedString
{
  CFRuntimeBase parent;
  CFMutableStringRef _string;
  Attr         *_attribs;
  CFIndex       _attribCount;
  CFIndex       _attribCap;
  CFIndex       _isEditing;
};

enum
{
  _kCFAttributedStringIsInline =  (1<<0),
  _kCFAttributedStringIsMutable = (1<<1)
};

CF_INLINE Boolean
CFAttributedStringIsInline (CFAttributedStringRef str)
{
  return ((CFRuntimeBase *)str)->_flags.info & _kCFAttributedStringIsInline ?
    true : false;
}

CF_INLINE Boolean
CFAttributedStringIsMutable (CFAttributedStringRef str)
{
  return ((CFRuntimeBase *)str)->_flags.info & _kCFAttributedStringIsMutable ?
    true : false;
}

CF_INLINE void
CFAttributedStringSetInline (CFAttributedStringRef str)
{
  ((CFRuntimeBase *)str)->_flags.info |= _kCFAttributedStringIsInline;
}

CF_INLINE void
CFAttributedStringSetMutable (CFAttributedStringRef str)
{
  ((CFRuntimeBase *)str)->_flags.info |= _kCFAttributedStringIsMutable;
}

/*static CFDictionaryRef
CFAttributedStringCacheAttribute (CFDictionaryRef attribs)
{
  CFDictionaryRef cachedAttr = NULL;
  
  GSMutexLock (&_kCFAttributedStringCacheLock);
  
  if (_kCFAttributedStringCache == NULL)
    {
      _kCFAttributedStringCache =
        CFBagCreateMutable (kCFAllocatorSystemDefault, 0, &kCFTypeBagCallBacks);
    }
  else
    {
      cachedAttr = CFBagGetValue (_kCFAttributedStringCache, attribs);
    }
  
  if (cachedAttr == NULL)
    {
      CFDictionaryRef insert;
      
      insert = CFDictionaryCreateCopy (NULL, attribs);
      CFBagAddValue (_kCFAttributedStringCache, insert);
      cachedAttr = insert;
      CFRelease (insert);
    }
  
  GSMutexUnlock (&_kCFAttributedStringCacheLock);
  
  return cachedAttr;
}

static void
CFAttributedStringUncacheAttribute (CFDictionaryRef attribs)
{
    GSMutexLock (&_kCFAttributedStringCacheLock);
    
    CFBagRemoveValue (_kCFAttributedStringCache, attribs);
    
    GSMutexUnlock (&_kCFAttributedStringCacheLock);
}

static CFDictionaryRef
CFAttributedStringGetBlankAttribute (void)
{
  if (_kCFAttributedStringBlankAttribute == NULL)
    {
      GSMutexLock (&_kCFAttributedStringBlankAttributeLock);
      if (_kCFAttributedStringBlankAttribute == NULL)
        {
          _kCFAttributedStringBlankAttribute = CFDictionaryCreate (NULL,
            NULL, NULL, 0,
            &kCFCopyStringDictionaryKeyCallBacks,
            &kCFTypeDictionaryValueCallBacks);
          Cache the blank attribute in case anyone wants to use it.
          CFAttributedStringCacheAttribute (_kCFAttributedStringBlankAttribute);
          CFRelease (_kCFAttributedStringBlankAttribute);
        }
      GSMutexUnlock (&_kCFAttributedStringBlankAttributeLock);
    }
  
  return CFAttributedStringCacheAttribute (_kCFAttributedStringBlankAttribute);
}*/

static CFComparisonResult
CFAttributedStringCompareAttribute (const void *v1, const void *v2, void *ctxt)
{
  Attr *attr1 = (Attr*)v1;
  Attr *attr2 = (Attr*)v2;
  
  return attr1->index < attr2->index ? kCFCompareLessThan :
    (attr1->index == attr2->index ? kCFCompareEqualTo : kCFCompareGreaterThan);
}

static CFIndex
CFAttributedStringArrayGetIndex (CFAttributedStringRef str, CFIndex loc,
                                 CFRange *effRange)
{
  /* This function does exactly the same things as
   * CFAttributedStringGetAttributes() but does not check if str is
   * an ObjC object and returns an index instead of a CFDictionaryRef.
   */
  CFIndex idx;
  Attr attr;
  
  attr.index = loc;
  idx = GSBSearch (str->_attribs, &attr, CFRangeMake(0, str->_attribCount),
                   sizeof(Attr), CFAttributedStringCompareAttribute, NULL);
  
  if (effRange)
    {
      CFIndex start;
      CFIndex end;
      
      start = str->_attribs[idx].index;
      effRange->location = start;
      
      if (idx < str->_attribCount - 1)
        end = str->_attribs[idx + 1].index;
      else
        end = CFStringGetLength(str->_string);
      
      effRange->length = end - start;
    }
  
  return idx;
}

static void
CFAttributedStringFinalize (CFTypeRef cf)
{
    CFIndex idx;
    CFAttributedStringRef str = (CFAttributedStringRef)cf;
    printf("CFAttributedStringFinalize str->_string: %@\n", str->_string);
    printf("CFAttributedStringFinalize str->_string: %p\n", str->_string);
    CFRelease(str->_string);
    printf("CFAttributedStringFinalize 2\n");
    printf("CFAttributedStringFinalize str->_attribCount: %d\n", str->_attribCount);
    for (idx = 0; idx < str->_attribCount; ++idx) {
        printf("CFAttributedStringFinalize idx: %d\n", idx);
        printf("CFAttributedStringFinalize str->_attribs[idx].attrib: %p\n", str->_attribs[idx].attrib);
        printf("CFAttributedStringFinalize CFGetRetainCount(str->_attribs[idx].attrib): %d\n", CFGetRetainCount(str->_attribs[idx].attrib));
        printf("CFAttributedStringFinalize CFGetTypeID(str->_attribs[idx].attrib): %d\n", CFGetTypeID(str->_attribs[idx].attrib));
        printf("CFAttributedStringFinalize str->_attribs[idx].attrib: %@\n", str->_attribs[idx].attrib);
        CFRelease(str->_attribs[idx].attrib);// CFAttributedStringUncacheAttribute (str->_attribs[idx].attrib);
        printf("CFAttributedStringFinalize 2 idx: %d\n", idx);
    }
    printf("CFAttributedStringFinalize 3\n");
    if (!CFAttributedStringIsInline(str)) {
        CFAllocatorDeallocate (CFGetAllocator(str), str->_attribs);
    }
    printf("CFAttributedStringFinalize 4\n");
}

static Boolean
CFAttributedStringEqual (CFTypeRef cf1, CFTypeRef cf2)
{
  CFAttributedStringRef str1 = (CFAttributedStringRef)cf1;
  CFAttributedStringRef str2 = (CFAttributedStringRef)cf2;
  
  if (CFEqual (str1->_string, str2->_string)
      && str1->_attribCount == str2->_attribCount)
    {
      CFIndex idx;
      
      for (idx = 0 ; idx < str1->_attribCount ; ++idx)
        if (!CFEqual (str1->_attribs[idx].attrib, str2->_attribs[idx].attrib))
          return false;
      
      return true;
    }
  
  return false;
}

static CFHashCode
CFAttributedStringHash (CFTypeRef cf)
{
  CFHashCode hash;
  CFAttributedStringRef str = (CFAttributedStringRef)cf;
  
  hash = CFHash (str->_string);
  hash += str->_attribCount;
  
  return hash;
}

CFRuntimeClass CFAttributedStringClass =
{
  0,
  "CFAttributedString",
  NULL,
  (CFTypeRef (*)(CFAllocatorRef, CFTypeRef))CFAttributedStringCreateCopy,
  CFAttributedStringFinalize,
  CFAttributedStringEqual,
  CFAttributedStringHash,
  NULL,
  NULL
};

void CFAttributedStringInitialize (void)
{
  _kCFAttributedStringTypeID =
    _CFRuntimeRegisterClass (&CFAttributedStringClass);
  GSMutexInitialize (&_kCFAttributedStringCacheLock);
  GSMutexInitialize (&_kCFAttributedStringBlankAttributeLock);
}



CFTypeID
CFAttributedStringGetTypeID (void)
{
  return _kCFAttributedStringTypeID;
}

#define CFATTRIBUTESTRING_SIZE sizeof(CFRuntimeClass) \
  - sizeof(struct __CFAttributedString)

static CFAttributedStringRef
CFAttributedStringCreateInlined (CFAllocatorRef alloc, CFStringRef str,
                                 CFIndex count, Attr *attribs)
{
    struct __CFAttributedString *new;
    //printf("CFAttributedStringCreateInlined 1\n");
    //printf("CFAttributedStringCreateInlined str: %@\n", str);
    new = (struct __CFAttributedString *)_CFRuntimeCreateInstance (alloc,
                                                                   _kCFAttributedStringTypeID,
                                                                   CFATTRIBUTESTRING_SIZE + (sizeof(Attr) * count), 0);
    if (new)
    {
        CFIndex idx;
        
        new->_string = CFStringCreateCopy (alloc, str);
        printf("CFAttributedStringCreateInlined new->_string: %@\n", new->_string);
        printf("CFAttributedStringCreateInlined new->_string: %p\n", new->_string);
        new->_attribCount = 1;
        new->_attribs = (Attr*)&new[1];
        
        for (idx = 0 ; idx < count ; ++idx)
        {
            new->_attribs[idx].index = attribs[idx].attrib.index;
            printf("CFAttributedStringCreateInlined attribs[idx].attrib: %p\n", attribs[idx].attrib);
            printf("CFAttributedStringCreateInlined CFGetRetainCount(attribs[idx].attrib): %d\n", CFGetRetainCount(attribs[idx].attrib));
            printf("CFAttributedStringCreateInlined CFGetTypeID(attribs[idx].attrib): %d\n", CFGetTypeID(attribs[idx].attrib));
            printf("CFAttributedStringCreateInlined attribs[idx].attrib: %@\n", attribs[idx].attrib);
            new->_attribs[idx].attrib = CFRetain(attribs[idx].attrib);// CFAttributedStringCacheAttribute (attribs[idx].attrib);
        }
        
        CFAttributedStringSetInline (new);
    }
    
    return new;
}

CFAttributedStringRef
CFAttributedStringCreate (CFAllocatorRef alloc, CFStringRef str,
                          CFDictionaryRef attribs)
{
  Attr attrib;
  
  attrib.index = 0;
  attrib.attrib = attribs;
  return CFAttributedStringCreateInlined (alloc, str, 1, &attrib);
}

CFAttributedStringRef
CFAttributedStringCreateCopy (CFAllocatorRef alloc, CFAttributedStringRef str)
{
  if (CF_IS_OBJC(_kCFAttributedStringTypeID, str))
    {
      CFIndex len = CFAttributedStringGetLength (str);
      return CFAttributedStringCreateWithSubstring (alloc, str,
                                                    CFRangeMake (0, len));
    }
  return CFAttributedStringCreateInlined (alloc, str->_string,
                                          str->_attribCount, str->_attribs);
}

CFAttributedStringRef
CFAttributedStringCreateWithSubstring (CFAllocatorRef alloc,
                                       CFAttributedStringRef str,
                                       CFRange range)
{
  CFAttributedStringRef new;
  CFMutableAttributedStringRef tmp;
  CFRange r;
  CFIndex cur;
  printf("CFAttributedStringCreateWithSubstring 1\n");  
  //printf("CFAttributedStringCreateWithSubstring range.location: %d\n", range.location);  
  //printf("CFAttributedStringCreateWithSubstring range.length: %d\n", range.length);  
  tmp = CFAttributedStringCreateMutable (alloc, range.length);
  
  /* We do not need to protect this with beging and end editing because
   * we will be adding attributes in the order they appear.  Using
   * the being/end editing functions would actually slow things down.
   */
  CFAttributedStringReplaceString (tmp, range,
                                   CFAttributedStringGetString (str));
  
  cur = range.location;
  //printf("CFAttributedStringCreateWithSubstring 3.1\n");  
  do
    {
      CFDictionaryRef attribs;
      
      attribs = CFAttributedStringGetAttributes (str, cur, &r);
      CFAttributedStringSetAttributes (tmp, r, attribs, true);
      
      cur = r.location + r.length;
    } while (cur < range.length);
  
  new = CFAttributedStringCreateCopy (alloc, tmp);
  CFRelease (tmp);
  
  return new;
}

CFIndex
CFAttributedStringGetLength (CFAttributedStringRef str)
{
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, CFIndex, str, "length");
  
  return CFStringGetLength (str->_string);
}

CFStringRef
CFAttributedStringGetString (CFAttributedStringRef str)
{
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, CFStringRef, str,
                         "string");
  
  return str->_string;
}

CFTypeRef
CFAttributedStringGetAttribute (CFAttributedStringRef str, CFIndex loc,
                                CFStringRef attrName, CFRange *effRange)
{
  CFDictionaryRef attribs;
  
  attribs = CFAttributedStringGetAttributes (str, loc, effRange);
  return CFDictionaryGetValue (attribs, attrName);
}

CFDictionaryRef
CFAttributedStringGetAttributes (CFAttributedStringRef str, CFIndex loc,
                                 CFRange *effRange)
{
  CFIndex idx;
  
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, CFDictionaryRef, str,
                         "attributesAtIndex:effectiveRange:", loc, effRange);
  
  idx = CFAttributedStringArrayGetIndex (str, loc, effRange);
  
  return str->_attribs[idx].attrib;
}

CFTypeRef
CFAttributedStringGetAttributeAndLongestEffectiveRange (
  CFAttributedStringRef str, CFIndex loc, CFStringRef attrName,
  CFRange inRange, CFRange *longestEffRange)
{
  return NULL; /* FIXME */
}

CFDictionaryRef
CFAttributedStringGetAttributesAndLongestEffectiveRange (
  CFAttributedStringRef aStr, CFIndex loc, CFRange inRange,
  CFRange *longestEffectiveRange)
{
    CF_OBJC_FUNCDISPATCHV(_kCFAttributedStringTypeID, CFAttributedStringRef, aStr, "attributesAtIndex:longestEffectiveRange:inRange");
    printf("CFAttributedStringGetAttributesAndLongestEffectiveRange 1\n");
    
    
    CFDictionaryRef attrDictionary;
    CFDictionaryRef tmpDictionary;
    CFRange	tmpRange;
    //IMP		getImp;
    
    if (CFRangeMaxRange(inRange) > CFAttributedStringGetLength(aStr)) {
        //[NSException raise: NSRangeException
        //            format: @"RangeError in method -attributesAtIndex:longestEffectiveRange:inRange: in class NSAttributedString"];
        return nil;
    }
    //getImp = [self methodForSelector: getSel];
    attrDictionary = CFAttributedStringGetAttributes(aStr, loc, longestEffectiveRange);//(*getImp)(self, getSel, index, aRange);
    if (longestEffectiveRange == 0) {
        return attrDictionary;
    }
    while (longestEffectiveRange->location > inRange.location) {
        //Check extend range backwards
        tmpDictionary = CFAttributedStringGetAttributes(aStr, longestEffectiveRange->location-1, &tmpRange);//(*getImp)(self, getSel, aRange->location-1, &tmpRange);
        if (CFDictionaryEqual(tmpDictionary, attrDictionary)) {
            longestEffectiveRange->length = CFRangeMaxRange(*longestEffectiveRange) - tmpRange.location;
            longestEffectiveRange->location = tmpRange.location;
        } else {
            break;
        }
    }
    while (CFRangeMaxRange(*longestEffectiveRange) < CFRangeMaxRange(inRange)) {
        //Check extend range forwards
        tmpDictionary = CFAttributedStringGetAttributes(aStr, CFRangeMaxRange(*longestEffectiveRange), &tmpRange);//(*getImp)(self, getSel, CFRangeMaxRange(*aRange), &tmpRange);
        if (CFDictionaryEqual(tmpDictionary, attrDictionary)) {
            longestEffectiveRange->length = CFRangeMaxRange(tmpRange) - longestEffectiveRange->location;
        } else {
            break;
        }
    }
    *longestEffectiveRange = CFRangeIntersection(*longestEffectiveRange,inRange);//Clip to rangeLimit
    return attrDictionary;
    
    
   /* 
    if (longestEffectiveRange != NULL) {
        longestEffectiveRange->location = inRange.location;
        longestEffectiveRange->length = 0;
    }
    CFIndex strSize = CFStringGetLength(aStr->_string);
    if (loc >= strSize) {
        return NULL;
    }
    CFDictionaryRef attributes = CFDictionaryGetValue(aStr->attributes,&loc);
    if (attributes == NULL) {
        return NULL;
    }
    if (longestEffectiveRange != NULL)  {
        CFIndex i;
        CFIndex len = loc + inRange.length;
        for (i = loc + 1 ; i < len; ++i) {
            CFDictionaryRef temp   =  CFDictionaryGetValue(aStr->attributes,&i)  ;
            if (temp == NULL) {
                break;
            } else if (!CFEqual(attributes,temp)) {
                break;
            }
        }
        longestEffectiveRange->length = i - loc;
    }
    return attributes;*/
    //return nil;
}

static void
InsertAttributesAtIndex (CFMutableAttributedStringRef str, CFIndex idx,
                         CFIndex strIdx, CFDictionaryRef attrib)
{
    struct __CFMutableAttributedString *working;
    CFAllocatorRef alloc;
    const Attr *stop;
    Attr *prev;
    Attr *cur;
    
    working = (struct __CFMutableAttributedString *)str;
    alloc = CFGetAllocator (working);
    if (working->_attribCount == working->_attribCap)
    {
        /* Grow */
        working->_attribs = CFAllocatorReallocate (alloc,
                                                   working->_attribs,
                                                   (working->_attribCap << 1),
                                                   0);
    }
    
    /* Move things to the right */
    stop = &working->_attribs[idx];
    cur = &working->_attribs[working->_attribCount];
    prev = cur - 1;
    while (cur > stop)
        *cur-- = *prev--;
    working->_attribCount += 1;
    
    /* Insert the new attribute */
    cur->index = strIdx;
    cur->attrib = CFRetain(attrib);//CFAttributedStringCacheAttribute (attrib);
}

static void
ReplaceAttributesAtIndex (CFMutableAttributedStringRef str, CFIndex idx,
                          CFDictionaryRef repl)
{
    CFRelease(str->_attribs[idx].attrib);//CFAttributedStringUncacheAttribute (str->_attribs[idx].attrib);
    str->_attribs[idx].attrib = CFRetain(str->_attribs[idx].attrib);//CFAttributedStringCacheAttribute (str->_attribs[idx].attrib);
}

static void
SetAttributesAtIndex (CFMutableAttributedStringRef str, CFIndex idx,
                      CFDictionaryRef repl)
{
    CFMutableDictionaryRef dict;
    CFIndex count;
    CFIndex i;
    const void **keys;
    const void ** values;
    
    dict = CFDictionaryCreateMutableCopy (NULL, 0, str->_attribs[idx].attrib);
    count = CFDictionaryGetCount (repl);
    keys = CFAllocatorAllocate (NULL, count * sizeof(void*) * 2, 0);
    values = keys + count;
    CFDictionaryGetKeysAndValues (repl, keys, values);
    for (i = 0 ; i < count ; ++i)
        CFDictionarySetValue (dict, keys[i], values[i]);
    
    CFRelease(str->_attribs[idx].attrib);// CFAttributedStringUncacheAttribute (str->_attribs[idx].attrib);
    str->_attribs[idx].attrib = CFRetain(dict);//CFAttributedStringCacheAttribute (dict);
    
    CFAllocatorDeallocate (NULL, keys);
    CFRelease (dict);
}

static void
RemoveAttributesAtIndex (CFMutableAttributedStringRef str, CFRange range)
{
    if (range.length > 0)
    {
        struct __CFMutableAttributedString *working;
        CFAllocatorRef alloc;
        const Attr *stop;
        Attr *next;
        Attr *cur;
        
        working = (struct __CFMutableAttributedString *)str;
        alloc = CFGetAllocator (working);
        /* Move things to the left */
        cur = &working->_attribs[range.location];
        stop = cur + range.length;
        while (cur < stop)
        {
            CFRelease(cur->attrib);
            cur++;
        }
        
        cur = &working->_attribs[range.location];
        next = cur + range.length;
        stop = cur + (working->_attribCount - (range.location + range.length) - 1);
        while (cur < stop)
            *cur++ = *next++;
        working->_attribCount -= range.length;
        
        if (working->_attribCount < (working->_attribCap >> 2)
            && working->_attribCount > 9)
        {
            /* Shrink */
            working->_attribs = CFAllocatorReallocate (alloc,
                                                       working->_attribs,
                                                       (working->_attribCap >> 1),
                                                       0);
        }
    }
}

static void
CFAttributedStringCoalesce (CFMutableAttributedStringRef str, CFRange range)
{
  struct __CFMutableAttributedString *working;
  
  working = (struct __CFMutableAttributedString *)str;
  
  if (working->_isEditing == 0)
    {
      CFIndex cur;
      CFIndex end;
      Attr *array;
      
      array = working->_attribs;
      if (range.location > 0)
        {
          if (array[range.location - 1].attrib == array[range.location].attrib)
            {
              RemoveAttributesAtIndex (str, CFRangeMake (range.location, 1));
              range.length -= 1;
            }
        }
      
      cur = range.location;
      end = range.location + range.length;
      
      while (cur < end)
        {
          if (array[cur - 1].attrib == array[cur].attrib)
            {
              RemoveAttributesAtIndex (str, CFRangeMake (cur, 1));
              end -= 1;
            }
          cur++;
        }
    }
}

#define CFMUTABLEATTRIBUTESTRING_SIZE sizeof(CFRuntimeClass) \
  - sizeof(struct __CFMutableAttributedString)

CFMutableAttributedStringRef
CFAttributedStringCreateMutable (CFAllocatorRef alloc, CFIndex maxLength)
{
  struct __CFMutableAttributedString *new;
  
  new = (struct __CFMutableAttributedString*)_CFRuntimeCreateInstance (alloc,
    _kCFAttributedStringTypeID, CFMUTABLEATTRIBUTESTRING_SIZE, 0);
  if (new)
    {
      new->_string = CFStringCreateMutable (alloc, maxLength);
      /* Minimum size is 8 */
      new->_attribCap = 8;
      new->_attribs = (Attr*)CFAllocatorAllocate (alloc, sizeof(Attr) * 8, 0);
      new->_attribCount = 1;
      new->_attribs[0].index = 0;
      new->_attribs[0].attrib = CFDictionaryCreateMutable (alloc, 16, &kCFTypeDictionaryValueCallBacks,NULL);
      
      CFAttributedStringSetMutable ((CFAttributedStringRef)new);
    }
  
  return (CFMutableAttributedStringRef)new;
}

CFMutableAttributedStringRef
CFAttributedStringCreateMutableCopy (CFAllocatorRef alloc, CFIndex maxLength,
                                     CFAttributedStringRef str)
{
  CFMutableAttributedStringRef new;
  CFRange r;
  CFIndex idx;
  CFIndex cur;
  CFIndex strLen;
  
  new = CFAttributedStringCreateMutable (alloc, maxLength);
  
  strLen = CFAttributedStringGetLength (str);
  CFAttributedStringReplaceString (new, CFRangeMake (0, 0),
                                   CFAttributedStringGetString (str));
  RemoveAttributesAtIndex (new, CFRangeMake (0, 1));
  
  cur = 0;
  idx = 0;
  do
    {
      CFDictionaryRef attribs;
      
      attribs = CFAttributedStringGetAttributes (str, cur, &r);
      InsertAttributesAtIndex (new, idx, cur, attribs);
      
      cur = r.location + r.length;
      idx++;
    } while (cur < strLen);
  
  return new;
}

void
CFAttributedStringBeginEditing (CFMutableAttributedStringRef str)
{
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, void, str,
                         "beginEditing");
  
  ((struct __CFMutableAttributedString *)str)->_isEditing += 1;
}

void
CFAttributedStringEndEditing (CFMutableAttributedStringRef str)
{
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, void, str,
                         "endEditing");
  
  if ((((struct __CFMutableAttributedString *)str)->_isEditing -= 1) == 0)
    CFAttributedStringCoalesce (str, CFRangeMake (0, str->_attribCount));
}

CFMutableStringRef
CFAttributedStringGetMutableString (CFMutableAttributedStringRef str)
{
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, CFMutableStringRef, str,
                         "mutableString");
  
  return NULL; /* FIXME */
}

void
CFAttributedStringRemoveAttribute (CFMutableAttributedStringRef str,
                                   CFRange range, CFStringRef attrName)
{
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, void, str,
                         "removeAttribute:range:", attrName, range);
  
  if (!CFAttributedStringIsMutable(str))
    return;
  /* FIXME */
}

void
CFAttributedStringReplaceString (CFMutableAttributedStringRef str,
                                 CFRange range, CFStringRef repl)
{
  CFIndex idxS;
  CFIndex idxE;
  CFIndex cur;
  CFIndex moveAmount;
  
  printf("CFAttributedStringReplaceString str: %@\n", str);  
  printf("CFAttributedStringReplaceString repl: %@\n", repl);  
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, void, str,
                         "replaceCharactersInRange:withString:", range, repl);
  
  printf("CFAttributedStringReplaceString 2\n");  
  if (!CFAttributedStringIsMutable(str))
    return;
  
  printf("CFAttributedStringReplaceString repl: %p\n", repl);  
  printf("CFAttributedStringReplaceString range.location: %d\n", range.location);  
  printf("CFAttributedStringReplaceString range.length: %d\n", range.length);  
  CFStringReplace ((CFMutableStringRef)str->_string, range, repl);
  idxS = CFAttributedStringArrayGetIndex (str, range.location, NULL);
  idxE = CFAttributedStringArrayGetIndex (str,
                                          range.location + range.length,
                                          NULL);
  RemoveAttributesAtIndex (str, CFRangeMake (idxS, idxE - idxS));
  printf("CFAttributedStringReplaceString 5\n");  
  
  /* Need to move the attributes */
  moveAmount = CFStringGetLength (repl) - range.length;
  cur = idxS + 1;
  printf("CFAttributedStringReplaceString 6\n");  
  while (cur < str->_attribCount)
    str->_attribs[cur++].index += moveAmount;
  
  printf("CFAttributedStringReplaceString 7\n");  
  CFAttributedStringCoalesce (str, CFRangeMake (idxS, idxE - idxS));
}

void
CFAttributedStringReplaceAttributedString (CFMutableAttributedStringRef str,
                                           CFRange range,
                                           CFAttributedStringRef repl)
{
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, void, str,
                         "replaceCharactersInRange:withAttributeString:",
                         range, repl);
  
  if (!CFAttributedStringIsMutable(str))
    return;
}

void
CFAttributedStringSetAttribute (CFMutableAttributedStringRef str,
  CFRange range, CFStringRef attrName, CFTypeRef value)
{
  CFDictionaryRef attrib;
  
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, void, str,
                         "setAttribute:value:range:", attrName, value, range);
  
  if (!CFAttributedStringIsMutable(str))
    return;
  
  attrib = CFDictionaryCreate (NULL, (const void **)&attrName,
                               (const void **)&value, 1,
                               &kCFCopyStringDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
  CFAttributedStringSetAttributes (str, range, attrib, false);
  CFRelease (attrib);
}

void
CFAttributedStringSetAttributes (CFMutableAttributedStringRef str,
                                 CFRange range, CFDictionaryRef repl,
                                 Boolean clearOtherAttribs)
{
  CFIndex idxS;
  CFIndex idxE;
  CFIndex cur;
  CFRange rS;
  CFRange rE;
  CFIndex rangeMax;
  Attr *array;
  
  CF_OBJC_FUNCDISPATCHV (_kCFAttributedStringTypeID, void, str,
                         "setAttributes:range:", repl, range);
  
  if (!CFAttributedStringIsMutable(str))
    return;
  
  array = str->_attribs;
  rangeMax = range.location + range.length;
  idxS = CFAttributedStringArrayGetIndex (str, range.location, &rS);
  idxE = CFAttributedStringArrayGetIndex (str, rangeMax - 1, &rE);
  cur = idxS;
  
  /* Split the last attribute in 2 if new attribute does not fall in a
   * boundary and the new attributes are different from what's already there.
   */
  if (rE.location + rE.length > rangeMax
      && !CFEqual (array[idxE].attrib, repl))
    InsertAttributesAtIndex (str, idxE + 1, rangeMax, array[idxE].attrib);
  
  if (range.location == rS.location)
    {
      if (clearOtherAttribs)
        ReplaceAttributesAtIndex (str, cur, repl);
      else
        SetAttributesAtIndex (str, cur, repl);
    }
  else if (!CFEqual (array[idxS].attrib, repl))
    {
      /* Only insert a new attribute if the new attribute is different from
       * the existing attribute
       */
      cur += 1;
      idxE += 1;
      InsertAttributesAtIndex (str, cur, range.location, repl);
      if (!clearOtherAttribs)
        SetAttributesAtIndex (str, cur, array[idxS].attrib);
    }
  cur += 1;
  
  if (cur <= idxE)
    {
      if (clearOtherAttribs)
        {
          RemoveAttributesAtIndex (str, CFRangeMake (cur, idxE - cur + 1));
        }
      else
        {
          do
            {
              SetAttributesAtIndex (str, cur++, repl);
            } while (cur <= idxE);
        }
    }
  
  CFAttributedStringCoalesce (str, CFRangeMake (idxS, cur));
}

