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

LIB_NAME=CoreText
LDLIBS= -lCoreFoundation -lFoundation

ifeq ($(TARGET),NativeApp)
    LIB_NAME=NACoreText
    LDLIBS+=-lNACoreGraphics
else
    LIB_NAME=CoreText
    LDLIBS+=-lCoreGraphics
endif

OBJECTS = \
	CTFontCollection.o \
	CTFontDescriptor-myos.o \
	CTFont-myos.o \
	CTFontTraits.o \
	CTFrame.o \
	CTFramesetter.o \
	CTGlyphInfo.o \
	CTLine-myos.o \
	OPFontconfigFontDescriptor-myos.o \
	OPFontDescriptor-myos.o \
	OPFont-myos.o \
	CTParagraphStyle.o \
	CTRun-myos.o \
	CTStringAttributes.o \
	CTTextTab.o \
	CTTypesetter-myos.o \
	OPSimpleLayoutEngine-myos.o \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
