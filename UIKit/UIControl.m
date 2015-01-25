/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit-private.h>

@implementation UIControl

@synthesize tracking=_tracking;
@synthesize touchInside=_touchInside;
@synthesize selected=_selected;
@synthesize enabled=_enabled;
@synthesize highlighted=_highlighted;
@synthesize contentHorizontalAlignment=_contentHorizontalAlignment;
@synthesize contentVerticalAlignment=_contentVerticalAlignment;

#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _registeredActions = [[NSMutableArray alloc] init];
        self.enabled = YES;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    return self;
}

- (void)dealloc
{
    [_registeredActions release];
    [super dealloc];
}

#pragma mark - Accessors

- (void)setEnabled:(BOOL)newEnabled
{
    if (newEnabled != _enabled) {
        _enabled = newEnabled;
        self.userInteractionEnabled = _enabled;
        [self _stateDidChange];
        //_UIControlStateDidChange(self);
    }
}

- (void)setHighlighted:(BOOL)newHighlighted
{
    if (newHighlighted != _highlighted) {
        _highlighted = newHighlighted;
        //_UIControlStateDidChange(self);
        [self _stateDidChange];
    }
}

- (void)setSelected:(BOOL)newSelected
{
    if (newSelected != _selected) {
        _selected = newSelected;
        [self _stateDidChange];
        //_UIControlStateDidChange(self);
    }
}

- (UIControlState)state
{
    UIControlState state = UIControlStateNormal;
    if (_highlighted) {
      state |= UIControlStateHighlighted;
    }
    if (!_enabled) {
        state |= UIControlStateDisabled;
    }
    if (_selected) {
        state |= UIControlStateSelected;
    }
    return state;
}

- (NSSet *)allTargets
{
    return [NSSet setWithArray:[_registeredActions valueForKey:@"target"]];
}

- (UIControlEvents)allControlEvents
{
    UIControlEvents allEvents = 0;
    
    for (UIControlAction *controlAction in _registeredActions) {
        allEvents |= controlAction.controlEvents;
    }
    
    return allEvents;
}

#pragma mark - Overriden methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DLog(@"self: %@", self);
    UITouch *touch = [touches anyObject];
    _touchInside = YES;
    _tracking = [self beginTrackingWithTouch:touch withEvent:event];
    self.highlighted = YES;
    if (_tracking) {
        UIControlEvents currentEvents = UIControlEventTouchDown;
        if (touch.tapCount > 1) {
            currentEvents |= UIControlEventTouchDownRepeat;
        }
        [self _sendActionsForControlEvents:currentEvents withEvent:event];
        //_UIControlSendActionsForControlEvents(self, currentEvents, event);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DLog(@"self: %@", self);
    UITouch *touch = [touches anyObject];
    const BOOL wasTouchInside = _touchInside;
    _touchInside = [self pointInside:[touch locationInView:self] withEvent:event];

    self.highlighted = _touchInside;
    if (_tracking) {
        _tracking = [self continueTrackingWithTouch:touch withEvent:event];
        if (_tracking) {
            UIControlEvents currentEvents = ((_touchInside)? UIControlEventTouchDragInside : UIControlEventTouchDragOutside);
            if (!wasTouchInside && _touchInside) {
                currentEvents |= UIControlEventTouchDragEnter;
            } else if (wasTouchInside && !_touchInside) {
                currentEvents |= UIControlEventTouchDragExit;
            }
            [self _sendActionsForControlEvents:currentEvents withEvent:event];
            //_UIControlSendActionsForControlEvents(self, currentEvents, event);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //DLog(@"self: %@", self);
    UITouch *touch = [touches anyObject];
    _touchInside = [self pointInside:[touch locationInView:self] withEvent:event];
    self.highlighted = NO;
    if (_tracking) {
        [self endTrackingWithTouch:touch withEvent:event];
        [self _sendActionsForControlEvents:((_touchInside)? UIControlEventTouchUpInside : UIControlEventTouchUpOutside) withEvent:event];
    }
    _tracking = NO;
    _touchInside = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;

    if (_tracking) {
        [self cancelTrackingWithEvent:event];
        [self _sendActionsForControlEvents:UIControlEventTouchCancel withEvent:event];
        //_UIControlSendActionsForControlEvents(self, UIControlEventTouchCancel, event);
    }
    _touchInside = NO;
    _tracking = NO;
}

#pragma mark - Public methods

- (void)_stateDidChange
{
    [self _updateContent];
}

- (void)_sendActionsForControlEvents:(UIControlEvents)controlEvents withEvent:(UIEvent *)event
{
    //DLog();
    for (UIControlAction *controlAction in _registeredActions) {
        //DLog(@"controlAction: %@", controlAction);
        //DLog(@"controlEvents: %d", controlEvents);
        //DLog(@"controlAction.controlEvents: %d", controlAction.controlEvents);
        if (controlAction.controlEvents & controlEvents) {
            //DLog(@"controlAction.controlEvents & controlEvents");
            [self sendAction:controlAction.action to:controlAction.target forEvent:event];
        }
    }
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents
{
    [self _sendActionsForControlEvents:controlEvents withEvent:nil];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:action to:target from:self forEvent:event];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    UIControlAction *controlAction = [[UIControlAction alloc] init];
    controlAction.target = target;
    controlAction.action = action;
    controlAction.controlEvents = controlEvents;
    [_registeredActions addObject:controlAction];
    [controlAction release];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    NSMutableArray *discard = [[NSMutableArray alloc] init];
    
    for (UIControlAction *controlAction in _registeredActions) {
        if (controlAction.target == target && (action == NULL || controlAction.controlEvents == controlEvents)) {
            [discard addObject:controlAction];
        }
    }
    [_registeredActions removeObjectsInArray:discard];
    [discard release];
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    for (UIControlAction *controlAction in _registeredActions) {
        if ((target == nil || controlAction.target == target) && (controlAction.controlEvents & controlEvent) ) {
            [actions addObject:NSStringFromSelector(controlAction.action)];
        }
    }
    
    if ([actions count] == 0) {
        [actions release];
        return nil;
    } else {
        return [actions autorelease];
    }
}

@end