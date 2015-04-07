#
# Copyright © 2014-2015 myOS Group.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# Contributor(s):
# Amr Aboelela <amraboelela@gmail.com>
#

LIB_NAME=CoreFoundation
LDLIBS=-lobjc

ifeq ($(BASE_OS),android)
else
    CFLAGS=-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -pthread -Wall -DGSWARN -DGSDIAGNOSE -Wno-import \
        -g -O2 -DBUILDING_SELF
    LDLIBS+=-licui18n -licuuc -licudata -fgnu-runtime -lFoundation
endif

OBJECTS = \
    CFArray.o \
    CFAttributedString.o \
    CFBag.o \
    CFBase.o \
    CFBinaryHeap.o \
    CFBitVector.o \
    CFCalendar.o \
    CFCharacterSet.o \
    CFData.o \
    CFDate.o \
    CFDateFormatter.o \
    CFDictionary.o \
    CFError.o \
    CFLocale.o \
    CFNumber.o \
    CFNumberFormatter.o \
    CFRunLoop.o \
    CFRuntime.o \
    CFSet.o \
    CFSocket.o \
    CFString.o \
    CFStringEncoding.o \
    CFStringFormat.o \
    CFStringUtilities.o \
    CFTimeZone.o \
    CFTree.o \
    CFURL.o \
    CFURLAccess.o \
    CFUUID.o \
    CFXMLNode.o \
    CFXMLParser.o \
    GSHashTable.o \
    NSCFArray.o \
    NSCFAttributedString.o \
    NSCFData.o \
    NSCFDictionary.o \
    NSCFError.o \
    NSCFSet.o \
    NSCFString.o \
    NSCFType.o \
    GSCArray.o \
    CFBundle.o \
    CFStream.o \
    GSUnicode.o \
    GSFunctions.o \
    CFArray-private.o \
    CFBase-private.o \
    CFPropertyList.o \
    NSCFDate.o \
    NSCFLocale.o \
    NSCFTimeZone.o \
    NSCFInputStream.o \
    NSCFOutputStream.o \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
