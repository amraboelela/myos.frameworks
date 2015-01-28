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

LDLIBS=-lCoreFoundation -lFoundation -lcairo

ifeq ($(BASE_OS),android)
    LDLIBS+=-lpng -llcms -lpixman -lz -lfontconfig -lexpat -lfreetype
endif

ifeq ($(TARGET),NativeApp)
    LIB_NAME=NACoreGraphics
else
    LIB_NAME=CoreGraphics
endif

OBJECTS = \
    CGAffineTransform.o \
    CGBitmapContext.o \
    CGColor.o \
    CGColorSpace.o \
    CGContext.o \
    CGDataConsumer.o \
    CGDataProvider.o \
    CGEvent.o \
    CGFont.o \
    CGFunction.o \
    CGGeometry.o \
    CGGradient.o \
    CGImage.o \
    CGImageDestination.o \
    CGImageSource.o \
    CGLayer.o \
    CGPDFArray.o \
    CGPDFContentStream.o \
    CGPDFContext.o \
    CGPDFDictionary.o \
    CGPDFDocument.o \
    CGPDFObject.o \
    CGPDFOperatorTable.o \
    CGPDFPage.o \
    CGPDFScanner.o \
    CGPDFStream.o \
    CGPDFString.o \
    CGPSConverter.o \
    CGPath.o \
    CGPattern.o \
    CGShading.o \
    CairoFont.o \
    OPColorSpaceIndexed.o \
    OPColorSpaceLCMS.o \
    OPColorTransformLCMS.o \
    OPImageConversion.o \
    OPPath.o \
    OPPostScriptContext.o \
    OPPremultiplyAlpha.o \
    OPSVGContext.o \
    StandardGlyphNames.o \
    CairoFontX11.o \
    CoreGraphics.o \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
