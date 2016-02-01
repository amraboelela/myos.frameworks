/*
 Copyright © 2014-2015 myOS Group.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 Contributor(s):
 Amr Aboelela <amraboelela@gmail.com>
 */

#import <cairo-xlib.h>
#import <IOKit/IOKit.h>
#import <UIKit/UIEvent.h>
#import <UIKit/UITouch-private.h>


float _screenScaleFactor;
static XEvent _xevent;

#define _KIOEventTimeDiffMax	0.27

UIEvent *IOEventUIEventFromXEvent(XEvent e);

BOOL IOEventGetNextEvent(IOWindow *window, UIEvent *uievent)
{
    if (XCheckWindowEvent(window->_display, window->_xwindow, ButtonPressMask | Button1MotionMask | ButtonReleaseMask | StructureNotifyMask, &_xevent)) {
        UITouch *touch = [[uievent allTouches] anyObject];
        CGPoint screenLocation = CGPointMake(_xevent.xbutton.x / _screenScaleFactor, _xevent.xbutton.y / _screenScaleFactor);
        NSTimeInterval timestamp = _xevent.xbutton.time / 1000.0;
        //DLog(@"timestamp: %f", timestamp);
        switch (_xevent.type) {
            case ButtonPress: {
                CGPoint delta = CGPointZero;
                int tapCount = 1;//touch.tapCount;
                NSTimeInterval timeDiff = fabs(touch.timestamp - timestamp);
                if (touch.phase == UITouchPhaseEnded && timeDiff < _KIOEventTimeDiffMax) {
                    tapCount = touch.tapCount+1;
                }
                _UITouchSetPhase(touch, UITouchPhaseBegan, screenLocation, tapCount, delta, timestamp);
                break;
            }
            case MotionNotify:
                _UITouchUpdatePhase(touch, UITouchPhaseMoved, screenLocation, timestamp);
                break;
            case ButtonRelease:
                _UITouchUpdatePhase(touch, UITouchPhaseEnded, screenLocation, timestamp);
#if defined(NATIVE_APP) || defined(PARENT_APP)
#else
                IOPipeWriteMessage(ParentPipeMessageMoveApplicationToTop, YES);
#endif
                break;
            case DestroyNotify:
                DLog(@"DestroyNotify");
                break;
        }
        //DLog(@"touch: %@", touch);
        return YES;
    } else {
        return NO;
    }
}

BOOL IOEventCanDrawWindow(IOWindow * window)
{
    //Display *d = window->_display;

    while( XCheckWindowEvent(window->_display, window->_xwindow, ExposureMask, &_xevent) ) {
             if (_xevent.xexpose.count == 0) {
                return YES;
                //CGContextSaveGState(ctx);
                //XClearWindow(d, win);
                //draw(ctx, cr);
                //CGContextRestoreGState(ctx);
            }
    }
    return NO;
}

UIEvent* IOEventUIEventFromXEvent(XEvent e)
{
    return [[[UIEvent alloc] initWithEventType:UIEventTypeTouches] autorelease];
}
