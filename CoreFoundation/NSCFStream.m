/* NSCFStream.m
   
   Copyright (C) 2010 Free Software Foundation, Inc.
   
   Written by: Stefan Bidigaray
   Date: January, 2010
   Modified by: Amr Aboelela <amraboelela@gmail.com>
   Date: Apr 2016
 
   This file is part of GNUstep CoreBase Library.
   
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

#import <Foundation/Foundation-private.h>
//#import <Foundation/NSHost.h>
//#import <Foundation/NSURL.h>

#include "CoreFoundation/CFStream.h"

void
_CFStreamClose (CFTypeRef stream)
{
  [(NSStream *)stream close];
}

CFErrorRef
_CFStreamCopyError (CFTypeRef stream)
{
  return (CFErrorRef)CFRetain([(NSStream *)stream streamError]);
}

CFTypeRef
_CFStreamCopyProperty (CFTypeRef stream, CFStringRef propertyName)
{
  return CFRetain([(NSStream *)stream propertyForKey: (NSString *)propertyName]);
}

Boolean
_CFStreamSetProperty (CFTypeRef stream, CFStringRef propertyName,
                      CFTypeRef propertyValue)
{
  return (Boolean)[(NSStream *)stream setProperty: (id)propertyValue
                                           forKey: (NSString *)propertyName];
}

CFStreamError
_CFStreamGetError (CFTypeRef stream)
{
  // FIXME
  return (CFStreamError){0, 0};
}

CFStreamStatus
_CFStreamGetStatus (CFTypeRef stream)
{
  return [(NSStream *)stream streamStatus];
}

Boolean
_CFStreamOpen (CFTypeRef stream)
{
  [(NSStream *)stream open];
  return (_CFStreamGetStatus (stream) == kCFStreamStatusOpen ? TRUE : FALSE);
}

void
_CFStreamScheduleInRunLoop (CFTypeRef stream, CFRunLoopRef runLoop,
                              CFStringRef runLoopMode)
{
  [(NSStream *)stream scheduleInRunLoop: (NSRunLoop *)runLoop
                                forMode: (NSString *)runLoopMode];
}

void
_CFStreamUnscheduleFromRunLoop (CFTypeRef stream, CFRunLoopRef runLoop,
                               CFStringRef runLoopMode)
{
  [(NSStream *)stream removeFromRunLoop: (NSRunLoop *)runLoop
                                forMode: (NSString *)runLoopMode];
}



void
NSCFStreamCreateBoundPair (CFAllocatorRef alloc, CFReadStreamRef *readStream,
                         CFWriteStreamRef *writeStream, CFIndex transferBufferSize)
{
  // FIXME
}

/*void
CFStreamCreatePairWithPeerSocketSignature (CFAllocatorRef alloc,
                                           const CFSocketSignature *signature,
                                           CFReadStreamRef *readStream,
                                           CFWriteStreamRef *writeStream)
{
  // FIXME
}
*/

void
CFStreamCreatePairWithSocket (CFAllocatorRef alloc, CFSocketNativeHandle sock,
                              CFReadStreamRef *readStream,
                              CFWriteStreamRef *writeStream)
{
    [NSStream getStreamsWithSocket:sock inputStream:(NSInputStream **)readStream outputStream:(NSOutputStream **)writeStream];
}

void
NSCFStreamCreatePairWithSocketToHost (CFAllocatorRef alloc, CFStringRef host,
                                    UInt32 port, CFReadStreamRef *readStream,
                                    CFWriteStreamRef *writeStream)
{
    [NSStream getStreamsToHost:[NSHost hostWithName:(NSString *)host]
                          port:(NSUInteger)port
                   inputStream:(NSInputStream **)readStream
                  outputStream:(NSOutputStream **)writeStream];
}



Boolean
NSCFWriteStreamCanAcceptBytes (CFWriteStreamRef stream)
{
  return (Boolean)[(NSOutputStream *)stream hasSpaceAvailable];
}

void
NSCFWriteStreamClose (CFWriteStreamRef stream)
{
  _CFStreamClose (stream);
}

CFErrorRef
NSCFWriteStreamCopyError (CFWriteStreamRef stream)
{
  return _CFStreamCopyError (stream);
}

CFTypeRef
NSCFWriteStreamCopyProperty (CFWriteStreamRef stream, CFStringRef propertyName)
{
  return _CFStreamCopyProperty (stream, propertyName);
}

CFWriteStreamRef
NSCFWriteStreamCreateWithAllocatedBuffers (CFAllocatorRef alloc,
                                         CFAllocatorRef bufferAllocator)
{
  // FIXME: ???
  return NULL;
}

CFWriteStreamRef
NSCFWriteStreamCreateWithBuffer (CFAllocatorRef alloc, UInt8 *buffer,
                               CFIndex bufferCapacity)
{
  return (CFWriteStreamRef)[[NSOutputStream alloc]
                             initToBuffer: buffer
                                 capacity: (NSUInteger)bufferCapacity];
}

CFWriteStreamRef
NSCFWriteStreamCreateWithFile (CFAllocatorRef alloc, CFURLRef fileURL)
{
  // FIXME: there's nothing in -base to set the append option at a later time.
  return (CFWriteStreamRef)[[NSOutputStream alloc]
                             initToFileAtPath: [(NSURL *)fileURL absoluteString]
                                       append: NO];
}

CFStreamError
NSCFWriteStreamGetError (CFWriteStreamRef stream)
{
  return _CFStreamGetError (stream);
}

CFStreamStatus
NSCFWriteStreamGetStatus (CFWriteStreamRef stream)
{
  return _CFStreamGetStatus (stream);
}

CFTypeID
NSCFWriteStreamGetTypeID (void)
{
  return (CFTypeID)[NSOutputStream class];
}

Boolean
NSCFWriteStreamOpen (CFWriteStreamRef stream)
{
  return _CFStreamOpen (stream);
}

void
NSCFWriteStreamScheduleWithRunLoop (CFWriteStreamRef stream,
                                  CFRunLoopRef runLoop,
                                  CFStringRef runLoopMode)
{
  _CFStreamScheduleInRunLoop (stream, runLoop, runLoopMode);
}

Boolean
NSCFWriteStreamSetClient (CFWriteStreamRef stream, CFOptionFlags streamEvents,
                        CFWriteStreamClientCallBack clientCB,
                        CFStreamClientContext *clientContext)
{
  // FIXME
  return FALSE;
}

Boolean
NSCFWriteStreamSetProperty (CFWriteStreamRef stream, CFStringRef propertyName,
                          CFTypeRef propertyValue)
{
  return _CFStreamSetProperty (stream, propertyName, propertyValue);
}

void
NSCFWriteStreamUnscheduleFromRunLoop (CFWriteStreamRef stream,
                                    CFRunLoopRef runLoop,
                                    CFStringRef runLoopMode)
{
  _CFStreamUnscheduleFromRunLoop (stream, runLoop, runLoopMode);
}

CFIndex
NSCFWriteStreamWrite (CFWriteStreamRef stream, const UInt8 *buffer,
                    CFIndex bufferLength)
{
  return (CFIndex)[(NSOutputStream *)stream write: buffer
                                        maxLength: (NSUInteger)bufferLength];
}



void
NSCFReadStreamClose (CFReadStreamRef stream)
{
  [(NSInputStream *)stream close];
}

CFErrorRef
NSCFReadStreamCopyError (CFReadStreamRef stream)
{
  return (CFErrorRef)[(NSInputStream *)stream streamError];
}

CFTypeRef
NSCFReadStreamCopyProperty (CFReadStreamRef stream, CFStringRef propertyName)
{
  return _CFStreamCopyProperty (stream, propertyName);
}

CFReadStreamRef
NSCFReadStreamCreateWithBytesNoCopy (CFAllocatorRef alloc, const UInt8 *bytes,
                                   CFIndex length, CFAllocatorRef bytesDeallocator)
{
  // FIXME
  return NULL;
}

CFReadStreamRef
NSCFReadStreamCreateWithFile (CFAllocatorRef alloc, CFURLRef fileURL)
{
  return (CFReadStreamRef)[[NSInputStream alloc]
                           initWithFileAtPath: [(NSURL *)fileURL absoluteString]];
}

const UInt8 *
NSCFReadStreamGetBuffer (CFReadStreamRef stream, CFIndex maxBytesToRead,
                       CFIndex *numBytesRead)
{
  // FIXME: docs are  bit confusing
  return NULL;
}

CFStreamError
NSCFReadStreamGetError (CFReadStreamRef stream)
{
  return _CFStreamGetError (stream);
}

CFStreamStatus
NSCFReadStreamGetStatus (CFReadStreamRef stream)
{
  return (CFStreamStatus)[(NSInputStream *)stream streamStatus];
}

CFTypeID
NSCFReadStreamGetTypeID (void)
{
  return (CFTypeID)[NSInputStream class];
}

Boolean
NSCFReadStreamHasBytesAvailable (CFReadStreamRef stream)
{
  return [(NSInputStream *)stream hasBytesAvailable];
}

Boolean
NSCFReadStreamOpen (CFReadStreamRef stream)
{
  return _CFStreamOpen (stream);
}

CFIndex
NSCFReadStreamRead (CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength)
{
  return (CFIndex)[(NSInputStream *)stream read: buffer
                                      maxLength: (NSUInteger)bufferLength];
}

void
NSCFReadStreamScheduleWithRunLoop (CFReadStreamRef stream, CFRunLoopRef runLoop,
                                 CFStringRef runLoopMode)
{
  _CFStreamScheduleInRunLoop (stream, runLoop, runLoopMode);
}

Boolean
NSCFReadStreamSetClient (CFReadStreamRef stream, CFOptionFlags streamEvents,
                       CFReadStreamClientCallBack clientCB,
                       CFStreamClientContext *clientContext)
{
  // FIXME
  return FALSE;
}

Boolean
NSCFReadStreamSetProperty (CFReadStreamRef stream, CFStringRef propertyName,
                         CFTypeRef propertyValue)
{
  return _CFStreamSetProperty (stream, propertyName, propertyValue);
}

void
NSCFReadStreamUnscheduleFromRunLoop (CFReadStreamRef stream, CFRunLoopRef runLoop,
                                   CFStringRef runLoopMode)
{
  _CFStreamUnscheduleFromRunLoop (stream, runLoop, runLoopMode);
}
