/*
 * Copyright (c) 2013. All rights reserved.
 */

#import <IOKit/IOWindow.h>
#import <X11/Xlib.h>

@class UIEvent;

extern float _screenScaleFactor;

BOOL IOEventGetNextEvent(IOWindow * window, UIEvent *uievent);
BOOL IOEventCanDrawWindow(IOWindow * window);
