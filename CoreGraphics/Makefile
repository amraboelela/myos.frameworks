
LDLIBS=-lCoreFoundation -lFoundation -lcairo

ifeq ($(BASE_OS),android)
    LDLIBS+=-lpng -llcms -lpixman -lz -lfontconfig -lexpat -lfreetype
endif

#ifeq ($(APP_TYPE),NativeApp)
#    LIB_NAME=NACoreGraphics
#else
#    LIB_NAME=CoreGraphics
#endif

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
    CairoFontX11.o \
    CoreGraphics.o \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
