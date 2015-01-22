/* GSURLPrivate
   Copyright (C) 2006 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   
   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02111 USA.
*/ 

#ifndef __GSURLPrivate_h_
#define __GSURLPrivate_h_

/*
 * Headers needed by many URL loading classes
 */
#import "common.h"
#import "NSArray.h"
#import "NSAutoreleasePool.h"
#import "NSData.h"
#import "NSDictionary.h"
#import "NSEnumerator.h"
#import "NSException.h"
#import "NSHTTPCookie.h"
#import "NSHTTPCookieStorage.h"
#import "NSLock.h"
#import "NSStream.h"
#import "NSString.h"
#import "NSURL.h"
#import "NSURLAuthenticationChallenge.h"
#import "NSURLCache.h"
#import "NSURLConnection.h"
#import "NSURLCredential.h"
#import "NSURLCredentialStorage.h"
#import "NSURLDownload.h"
#import "NSURLError.h"
#import "NSURLProtectionSpace.h"
#import "NSURLProtocol.h"
#import "NSURLRequest.h"
#import "NSURLResponse.h"

/*
 * Private accessors for URL loading classes
 */

@interface	NSURLRequest (Private)
- (id) _propertyForKey: (NSString*)key;
- (void) _setProperty: (id)value forKey: (NSString*)key;
@end


@interface	NSURLResponse (Private)
- (void) _setHeaders: (id)headers;
- (void) _setStatusCode: (NSInteger)code text: (NSString*)text;
- (void) _setValue: (NSString *)value forHTTPHeaderField: (NSString *)field;
- (NSString*) _valueForHTTPHeaderField: (NSString*)field;
@end


@interface      NSURLProtocol (Private)
+ (Class) _classToHandleRequest:(NSURLRequest *)request;
@end

/*
 * Internal class for handling HTTP authentication
 */
@class	GSLazyLock;
@interface GSHTTPAuthentication : NSObject
{
  GSLazyLock		*_lock;
  NSURLCredential	*_credential;
  NSURLProtectionSpace	*_space;
  NSString		*_nonce;
  NSString		*_opaque;
  NSString		*_qop;
  int			_nc;
}
/*
 *  Return the object for the specified credential/protection space.
 */
+ (GSHTTPAuthentication *) authenticationWithCredential:
  (NSURLCredential*)credential
  inProtectionSpace: (NSURLProtectionSpace*)space;

/*
 * Create/return the protection space involved in the specified authentication
 * header returned in a response to a request sent to the URL.
 */
+ (NSURLProtectionSpace*) protectionSpaceForAuthentication: (NSString*)auth
						requestURL: (NSURL*)URL;

/*
 * Return the protection space for the specified URL (if known).
 */
+ (NSURLProtectionSpace *) protectionSpaceForURL: (NSURL*)URL;

+ (void) setProtectionSpace: (NSURLProtectionSpace *)space
		 forDomains: (NSArray*)domains
		    baseURL: (NSURL*)base;

/*
 * Generate next authorisation header for the specified authentication
 * header, method, and path.
 */
- (NSString*) authorizationForAuthentication: (NSString*)authentication
				      method: (NSString*)method
					path: (NSString*)path;
- (NSURLCredential *) credential;
- (id) initWithCredential: (NSURLCredential*)credential
        inProtectionSpace: (NSURLProtectionSpace*)space;
- (NSURLProtectionSpace *) space;
@end

#endif

