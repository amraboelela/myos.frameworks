
LDLIBS=-lCoreFoundation -lFoundation

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lIOKit_native -lOpenGLES_native -lCoreGraphics_native -lCoreText_native
else ifeq ($(APP_TYPE),ParentApp)
    LDLIBS+=-lIOKit_parent -lOpenGLES_parent -lCoreGraphics_parent -lCoreText_parent
else
    LDLIBS+=-lIOKit -lOpenGLES -lCoreGraphics -lCoreText
endif

ifeq ($(BASE_OS),android)
    ifeq ($(APP_TYPE),NativeApp)
        LDLIBS+=-lEGL -lGLESv1_CM
    endif
endif

OBJECTS = \
    CAAnimation \
    CAGradientLayer \
    CAReplicatorLayer \
    CATiledLayer \
    CAValueFunction \
    CALayer \
    CALayer-CFunctions \
    CALayer+PresentationLayer \
    CARenderLayer \
    CALayerObserver \
    CAScrollLayer \
    CATransaction \
    CARenderer \
    CADisplayLink \
    CAMediaTiming \
    CAShapeLayer \
    CATransform3D \
    CAEAGLLayer \
    CAMediaTimingFunction \
    CATextLayer \
    CATransformLayer \
    CABackingStore \
    CAAnimator \
    CATransactionGroup \
    CACompositor \
    CAGeometry \

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
