
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := CoreFoundation
LOCAL_SRC_FILES := CFArray.c \
    CFAttributedString.c \
    CFBag.c \
    CFBase.c \
    CFBinaryHeap.c \
    CFBitVector.c \
    CFCalendar.c \
    CFCharacterSet.c \
    CFData.c \
    CFDate.c \
    CFDateFormatter.c \
    CFDictionary.c \
    CFError.c \
    CFLocale.c \
    CFNumber.c \
    CFNumberFormatter.c \
    CFRunLoop.c \
    CFRuntime.c \
    CFSet.c \
    CFSocket.c \
    CFString.c \
    CFStringEncoding.c \
    CFStringFormat.c \
    CFStringUtilities.c \
    CFTimeZone.c \
    CFTree.c \
    CFURL.c \
    CFURLAccess.c \
    CFUUID.c \
    CFXMLNode.c \
    CFXMLParser.c \
    GSHashTable.c \

LOCAL_CFLAGS := -I${MY_FRAMEWORKS_PATH}/frameworks -I${MY_FRAMEWORKS_PATH}/frameworks/include
LOCAL_LDFLAGS := -v -L${MY_FRAMEWORKS_PATH}/frameworks/libs
LOCAL_SHARED_LIBRARIES := objc icu
include $(BUILD_SHARED_LIBRARY)
