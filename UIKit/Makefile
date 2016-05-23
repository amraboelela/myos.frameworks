
CFLAGS+=-fblocks
LDLIBS= -lCoreFoundation -lFoundation

ifeq ($(BASE_OS),android)
    ifeq ($(APP_TYPE),NativeApp)
        LDLIBS+=-lEGL -lGLESv1_CM -lGLESv1_enc
    endif
endif


OBJECTS = \
    UIApplication \
    UIEvent \
    UIResponder \
    UITouch \
    UIGeometry \
    UIGraphics \
    UIScreen \
    UIImage \
    UIPhotosAlbum \
    UIColor \
    UIView \
    UIBackgroundTask \
    UIGestureRecognizer \
	UIWindow \
	UIButton \
	UIImageView \
	UIScreenMode \
	UIControl \
	UILabel \
	UIFont \
	UIViewLayoutManager \
	UIControlAction \
	UIInputController \
	UIAction \
	UIPanGestureRecognizer \
	UIRotationGestureRecognizer \
	UITapGestureRecognizer \
	UILongPressGestureRecognizer \
	UIPinchGestureRecognizer \
	UISwipeGestureRecognizer \
	UIViewBlockAnimationDelegate \
	UIViewAnimationGroup \
	UITextField \
	UIStringDrawing \
    UIViewController \
    UINavigationItem \
    UINavigationController \
    UISplitViewController \
    UINavigationBar \
    UIToolbar \
    UITabBarController \
    UIBarButtonItem \
    UIToolbarButton \
    UITabBar \
    UIBarItem \
    NSArray+UIKit \
    UIPageControl \
    UIScrollView \
    UIScroller \
    UIScrollViewAnimation \
    UIScrollViewAnimationScroll \
    UIScrollViewAnimationDeceleration \
    UIBezierPath \
    UIIconControl \
    UIApplicationIcon \
    UIActivityIndicatorView \
    UIDevice \

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lIOKit_native -lOpenGLES_native -lQuartzCore_native -lCoreGraphics_native -lCoreText_native
    OBJECTS+= \
        UINativeApplication \
        UIParentApplicationProxy \

else ifeq ($(APP_TYPE),ParentApp)
    LDLIBS+=-lIOKit_parent -lOpenGLES_parent -lQuartzCore_parent -lCoreGraphics_parent -lCoreText_parent
    OBJECTS+= \
        UIParentApplication \
        UIChildApplicationProxy \
        
else
    LDLIBS=-lIOKit -lOpenGLES -lQuartzCore -lCoreGraphics -lCoreText
    OBJECTS+= \
        UIChildApplication \
        
endif

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
