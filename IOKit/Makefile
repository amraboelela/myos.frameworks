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
    IOWindow.o \
    IOPipe.o \
    NSFileHandle+IOKit.o \
    NSFileManager+IOKit.o \

ifeq ($(APP_TYPE),NativeApp)
    LIB_NAME=NAIOKit
    LDLIBS+=-lNACoreGraphics
else
    LIB_NAME=IOKit
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
