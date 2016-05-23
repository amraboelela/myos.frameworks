
#LIB_NAME=CoreFoundation
LDLIBS=-lobjc

ifeq ($(BASE_OS),android)
else
    CFLAGS+=-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -pthread -Wall -DGSWARN -DGSDIAGNOSE -Wno-import \
        -g -O2 -DBUILDING_SELF
    LDLIBS+=-licui18n -licuuc -licudata -fgnu-runtime -ldispatch -lFoundation
endif

OBJECTS = \
    CFArray \
    CFAttributedString \
    CFBag \
    CFBase \
    CFBinaryHeap \
    CFBitVector \
    CFCalendar \
    CFCharacterSet \
    CFData \
    CFDate \
    CFDateFormatter \
    CFDictionary \
    CFError \
    CFLocale \
    CFNumber \
    CFNumberFormatter \
    CFRunLoop \
    CFRuntime \
    CFSet \
    CFSocket \
    CFString \
    CFStringEncoding \
    CFStringFormat \
    CFStringUtilities \
    CFTimeZone \
    CFTree \
    CFURL \
    CFURLAccess \
    CFUUID \
    CFXMLNode \
    CFXMLParser \
    GSHashTable \
    NSCFArray \
    NSCFAttributedString \
    NSCFData \
    NSCFDictionary \
    NSCFError \
    NSCFSet \
    NSCFString \
    NSCFType \
    GSCArray \
    CFBundle \
    CFStream \
    NSCFStream \
    GSUnicode \
    GSFunctions \
    CFPropertyList \
    NSCFDate \
    NSCFLocale \
    NSCFTimeZone \
    NSCFInputStream \
    NSCFOutputStream \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
