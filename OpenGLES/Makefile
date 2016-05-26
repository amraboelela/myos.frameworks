
LDLIBS=-lCoreFoundation -lFoundation
OBJECTS = \
    EAGL \
    EAGLTexture \

ifeq ($(BASE_OS),android)
    ifeq ($(APP_TYPE),NativeApp)
        LDLIBS+=-lEGL
        OBJECTS+=EAGLParent.o
    else
        OBJECTS+=EAGLChild.o
    endif
endif

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lEGL -lIOKit_native -lCoreGraphics_native
else ifeq ($(APP_TYPE),ParentApp)
    LDLIBS+=-lIOKit_parent -lCoreGraphics_parent
else
    LDLIBS+=-lIOKit -lCoreGraphics
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
