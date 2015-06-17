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

static void *const UINavigationItemContext = "UINavigationItemContext";
static NSSet *_keyPaths = nil;

#pragma mark - Static functions

@implementation UINavigationItem

@synthesize title=_title;
@synthesize rightBarButtonItem=_rightBarButtonItem;
@synthesize titleView=_titleView;
@synthesize hidesBackButton=_hidesBackButton;
@synthesize leftBarButtonItem=_leftBarButtonItem;
@synthesize backBarButtonItem=_backBarButtonItem;
@synthesize prompt=_prompt;

#pragma mark - Life cycle

- (id)initWithTitle:(NSString *)theTitle
{
    if ((self=[super init])) {
        self.title = theTitle;
    }
    //DLog(@"self: %@", self);
    return self;
}

- (void)dealloc
{
    // removes automatic observation
    _UINavigationItemSetNavigationBar(self, nil);
    
    [_backBarButtonItem release];
    [_leftBarButtonItem release];
    [_rightBarButtonItem release];
    [_title release];
    [_titleView release];
    [_prompt release];
    [super dealloc];
}

#pragma mark - Accessors

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item
{
    [self setLeftBarButtonItem:item animated:NO];
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item
{
    //DLog(@"item: %@", item);
    [self setRightBarButtonItem:item animated:NO];
}

- (void)setHidesBackButton:(BOOL)hidesBackButton
{
    [self setHidesBackButton:hidesBackButton animated:NO];
}

- (UIBarButtonItem *)backBarButtonItem
{
    if (_backBarButtonItem) {
        return _backBarButtonItem;
    } else {
        return [[[UIBarButtonItem alloc] initWithTitle:(self.title ?: @"Back") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; title: %@; backBarButtonItem: %@; leftBarButtonItem: %@, rightBarButtonItem: %@>", [self className], self, _title, _backBarButtonItem, _leftBarButtonItem, _rightBarButtonItem];
}

#pragma mark - Delegates

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //DLog(@"keyPath: %@", keyPath);
    if (context != UINavigationItemContext) {
        if ([[self superclass] instancesRespondToSelector:_cmd])
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    _UINavigationBarUpdateNavigationItem(self->_navigationBar, self, NO);
    //DLog();
    //[self->_navigationBar _updateNavigationItem:self animated:NO];
}

#pragma mark - Public methods

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    if (item != _leftBarButtonItem) {
        [self willChangeValueForKey: @"leftBarButtonItem"];
        [_leftBarButtonItem release];
        _leftBarButtonItem = [item retain];
        [self didChangeValueForKey: @"leftBarButtonItem"];
    }
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    if (item != _rightBarButtonItem) {
        //[self willChangeValueForKey: @"rightBarButtonItem"];
        [_rightBarButtonItem release];
        _rightBarButtonItem = [item retain];
        //[self didChangeValueForKey: @"rightBarButtonItem"];
    }
}

- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated
{
    [self willChangeValueForKey: @"hidesBackButton"];
    _hidesBackButton = hidesBackButton;
    [self didChangeValueForKey: @"hidesBackButton"];
}

@end

#pragma mark - Public functions

void _UINavigationItemInitialize()
{
    _keyPaths = [[NSSet alloc] initWithObjects:@"title", @"prompt", @"backBarButtonItem", @"leftBarButtonItem", @"rightBarButtonItem", @"titleView", @"hidesBackButton", nil];
    //DLog(@"_keyPaths: %@", _keyPaths);
}

void _UINavigationItemSetNavigationBar(UINavigationItem *navigationItem, UINavigationBar *navigationBar)
{
    //DLog(@"navigationItem: %@", navigationItem);
    if (!navigationItem) {
        return;
    }
    // weak reference
    if (navigationItem->_navigationBar == navigationBar) {
        return;
    }
    //DLog();
    if (navigationItem->_navigationBar != nil && navigationBar == nil) {
        // remove observation
        for (NSString *keyPath in _keyPaths) {
            [navigationItem removeObserver:navigationItem forKeyPath:keyPath];
        }
        //DLog();
    } else if (navigationBar != nil) {
        // observe property changes to notify UI element
        //DLog(@"_keyPaths: %@", _keyPaths);
        for (NSString *keyPath in _keyPaths) {
            [navigationItem addObserver:navigationItem forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:UINavigationItemContext];
        }
        //DLog();
    }
    //DLog();
    navigationItem->_navigationBar = navigationBar;
}
