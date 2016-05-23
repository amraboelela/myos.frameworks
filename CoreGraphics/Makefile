
LDLIBS=-lCoreFoundation -lFoundation -lcairo

ifeq ($(BASE_OS),android)
    LDLIBS+=-lpng -llcms -lpixman -lz -lfontconfig -lexpat -lfreetype
endif

OBJECTS = \
    CGAffineTransform \
    CGBitmapContext \
    CGColor \
    CGColorSpace \
    CGContext \
    CGDataConsumer \
    CGDataProvider \
    CGEvent \
    CGFont \
    CGFunction \
    CGGeometry \
    CGGradient \
    CGImage \
    CGImageDestination \
    CGImageSource \
    CGLayer \
    CGPDFArray \
    CGPDFContentStream \
    CGPDFContext \
    CGPDFDictionary \
    CGPDFDocument \
    CGPDFObject \
    CGPDFOperatorTable \
    CGPDFPage \
    CGPDFScanner \
    CGPDFStream \
    CGPDFString \
    CGPSConverter \
    CGPath \
    CGPattern \
    CGShading \
    CairoFont \
    OPColorSpaceIndexed \
    OPColorSpaceLCMS \
    OPColorTransformLCMS \
    OPImageConversion \
    OPPath \
    OPPostScriptContext \
    OPPremultiplyAlpha \
    OPSVGContext \
    CairoFontX11 \
    CoreGraphics \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
