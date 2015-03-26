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

LDLIBS=-lCoreFoundation -lFoundation
OBJECTS = \
    EAGL.o \
    EAGLTexture.o \

ifeq ($(TARGET),NativeApp)
    LIB_NAME=NAOpenGLES
    LDLIBS+=-lEGL -lNAIOKit -lNACoreGraphics
    OBJECTS+=EAGLParent.o
else
    LIB_NAME=OpenGLES
    LDLIBS+=-lIOKit -lCoreGraphics
    OBJECTS+=EAGLChild.o
endif

ifeq ($(BASE_OS),android)
    CFLAGS=-I$(ANDROID_SOURCE_PATH)/development/tools/emulator/opengl/host/include/libOpenglRender
    ifeq ($(TARGET),NativeApp)
        LDLIBS+=-lEGL -lGLESv1_CM -lGLESv1_enc
    else
        SLIBS=MAEGL MAGLESv1_enc
        #MAEGL MAOpenglSystemCommon MARenderControl_enc MAGLESv1_enc MAOpenglCodecCommon
    endif
endif

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
