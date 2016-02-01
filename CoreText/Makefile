
LDLIBS= -lCoreFoundation -lFoundation

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lCoreGraphics_native
else ifeq ($(APP_TYPE),ParentApp)
    LDLIBS+=-lCoreGraphics_parent
else
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
