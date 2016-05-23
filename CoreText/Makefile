
LDLIBS= -lCoreFoundation -lFoundation

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lCoreGraphics_native
else ifeq ($(APP_TYPE),ParentApp)
    LDLIBS+=-lCoreGraphics_parent
else
    LDLIBS+=-lCoreGraphics
endif

OBJECTS = \
	CTFontCollection \
	CTFontDescriptor \
	CTFont \
	CTFontTraits \
	CTFrame \
	CTFramesetter \
	CTGlyphInfo \
	CTLine \
	OPFontconfigFontDescriptor \
	OPFontDescriptor \
	OPFont \
	CTParagraphStyle \
	CTRun \
	CTStringAttributes \
	CTTextTab \
	CTTypesetter \
	OPSimpleLayoutEngine \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
