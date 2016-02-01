
LDLIBS=-lCoreFoundation -lFoundation
OBJECTS = \
    EAGL.o \
    EAGLTexture.o \

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lEGL -lIOKit_native -lCoreGraphics_native
    OBJECTS+=EAGLParent.o
else
    LDLIBS+=-lIOKit -lCoreGraphics
    OBJECTS+=EAGLChild.o
endif

ifeq ($(BASE_OS),android)
    CFLAGS+=-I$(ANDROID_SOURCE_PATH)/development/tools/emulator/opengl/host/include/libOpenglRender
    ifeq ($(APP_TYPE),NativeApp)
        LDLIBS+=-lEGL -lGLESv1_CM -lGLESv1_enc
    else
        SLIBS=MAEGL MAGLESv1_enc
        #MAEGL MAOpenglSystemCommon MARenderControl_enc MAGLESv1_enc MAOpenglCodecCommon
    endif
endif

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
