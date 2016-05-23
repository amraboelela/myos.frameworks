
LDLIBS=-lCoreFoundation -lFoundation
OBJECTS = \
    IOWindow \
    IOPipe \
    NSFileHandle+IOKit \
    NSFileManager+IOKit \

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lCoreGraphics_native
else ifeq ($(APP_TYPE),ParentApp)
    LDLIBS+=-lCoreGraphics_parent
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
        IOEvent \
        opal-x11 \

endif

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
