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

ifeq ($(APP_TYPE),NativeApp)
    LIB_NAME=NACoreText
    LDLIBS+=-lNACoreGraphics
else
    LIB_NAME=CoreText
    LDLIBS+=-lCoreGraphics
endif

OBJECTS = \
	CTFontCollection.o \
	CTFontDescriptor.o \
	CTFont.o \
	CTFontTraits.o \
	CTFrame.o \
	CTFramesetter.o \
	CTGlyphInfo.o \
	CTLine.o \
	OPFontconfigFontDescriptor.o \
	OPFontDescriptor.o \
	OPFont.o \
	CTParagraphStyle.o \
	CTRun.o \
	CTStringAttributes.o \
	CTTextTab.o \
	CTTypesetter.o \
	OPSimpleLayoutEngine.o \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
