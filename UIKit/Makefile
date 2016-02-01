
CFLAGS+=-fblocks
LDLIBS= -lCoreFoundation -lFoundation

ifeq ($(BASE_OS),android)
    ifeq ($(APP_TYPE),NativeApp)
        LDLIBS+=-lEGL -lGLESv1_CM -lGLESv1_enc
    endif
endif


OBJECTS = \
    UIApplication.o \
    UIEvent.o \
    UIResponder.o \
    UITouch.o \
    UIGeometry.o \
    UIGraphics.o \
    UIScreen.o \
    UIImage.o \
    UIPhotosAlbum.o \
    UIColor.o \
    UIView.o \
    UIBackgroundTask.o \
    UIGestureRecognizer.o \
	UIWindow.o \
	UIButton.o \
	UIImageView.o \
	UIScreenMode.o \
	UIControl.o \
	UILabel.o \
	UIFont.o \
	UIViewLayoutManager.o \
	UIControlAction.o \
	UIInputController.o \
	UIAction.o \
	UIPanGestureRecognizer.o \
	UIRotationGestureRecognizer.o \
	UITapGestureRecognizer.o \
	UILongPressGestureRecognizer.o \
	UIPinchGestureRecognizer.o \
	UISwipeGestureRecognizer.o \
	UIViewBlockAnimationDelegate.o \
	UIViewAnimationGroup.o \
	UITextField.o \
	UIStringDrawing.o \
    UIViewController.o \
    UINavigationItem.o \
    UINavigationController.o \
    UISplitViewController.o \
    UINavigationBar.o \
    UIToolbar.o \
    UITabBarController.o \
    UIBarButtonItem.o \
    UIToolbarButton.o \
    UITabBar.o \
    UIBarItem.o \
    NSArray+UIKit.o \
    UIPageControl.o \
    UIScrollView.o \
    UIScroller.o \
    UIScrollViewAnimation.o \
    UIScrollViewAnimationScroll.o \
    UIScrollViewAnimationDeceleration.o \
    UIBezierPath.o \
    UIIconControl.o \
    UIApplicationIcon.o \
    UIActivityIndicatorView.o \
    UIDevice.o \

ifeq ($(APP_TYPE),NativeApp)
    LDLIBS+=-lIOKit_native -lOpenGLES_native -lQuartzCore_native -lCoreGraphics_native -lCoreText_native
    OBJECTS+= \
        UINativeApplication.o \
        UIParentApplicationProxy.o \

else ifeq ($(APP_TYPE),ParentApp)
    LDLIBS+=-lIOKit_parent -lOpenGLES_parent -lQuartzCore_parent -lCoreGraphics_parent -lCoreText_parent
    OBJECTS+= \
        UIParentApplication.o \
        UIChildApplicationProxy.o \
        
else
    LDLIBS=-lIOKit -lOpenGLES -lQuartzCore -lCoreGraphics -lCoreText
    OBJECTS+= \
        UIChildApplication.o \
        
endif

include ${MYOS_PATH}/sdk/$(BASE_OS)/makefile-shared
