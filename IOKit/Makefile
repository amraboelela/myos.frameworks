
LDLIBS=-lCoreFoundation -lFoundation
OBJECTS = \
    IOWindow.o \
    IOPipe.o \
    NSFileHandle+IOKit.o \
    NSFileManager+IOKit.o \

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lCoreGraphics_native
else
    LDLIBS+=-lCoreGraphics
endif

ifeq ($(BASE_OS),android)
    ifeq ($(APP_TYPE),NativeApp)
    else
        SLIBS=MAKit
    endif
else
    OBJECTS+= \
        IOEvent.o \
        opal-x11.o \

endif

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
