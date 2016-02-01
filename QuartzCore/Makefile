
LDLIBS=-lCoreFoundation -lFoundation

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lEGL -lIOKit_native -lOpenGLES_native -lCoreGraphics_native -lCoreText_native
else
    LDLIBS+=-lIOKit -lOpenGLES -lCoreGraphics -lCoreText
endif

ifeq ($(BASE_OS),android)
    ifeq ($(APP_TYPE),NativeApp)
        LDLIBS+=-lGLESv1_CM
    endif
endif

OBJECTS = \
    CAAnimation.o \
    CAGradientLayer.o \
    CAReplicatorLayer.o \
    CATiledLayer.o \
    CAValueFunction.o \
    CALayer.o \
    CALayer-CFunctions.o \
    CALayer+PresentationLayer.o \
    CARenderLayer.o \
    CALayerObserver.o \
    CAScrollLayer.o \
    CATransaction.o \
    CARenderer.o \
    CADisplayLink.o \
    CAMediaTiming.o \
    CAShapeLayer.o \
    CATransform3D.o \
    CAEAGLLayer.o \
    CAMediaTimingFunction.o \
    CATextLayer.o \
    CATransformLayer.o \
    CABackingStore.o \
    CAAnimator.o \
    CATransactionGroup.o \
    CACompositor.o \
    CAGeometry.o \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
