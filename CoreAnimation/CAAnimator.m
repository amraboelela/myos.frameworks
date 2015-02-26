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

#import <CoreAnimation/CoreAnimation-private.h>
#import <OpenGLES/EAGL-private.h>
#import <CoreGraphics/CoreGraphics-private.h>

#define _kResetTimeInterval 1.0

NSConditionLock *_CAAnimatorConditionLock = nil;

#ifdef NATIVE_APP
NSConditionLock *_CAAnimatorNAConditionLock = nil;
#endif

CGImageRef _CAAnimatorScreenCapture = nil;

static int _CAAnimatorFrameCount = 0;
static BOOL _treeHasPendingAnimations = NO;
static BOOL _treeHadPendingAnimations = NO;
static BOOL _eaglContextIsReady = NO;
static CADisplayLink *_displayLink;

static NSTimeInterval previousTimestamp;
static NSTimeInterval beforeLockTime;
 
#pragma mark - Static functions

static void _CAAnimatorApplyAnimationsWithRoot(CALayer *layer)
{
    //DLog(@"layer: %@", layer);
    _CALayerApplyAnimations(layer);
    if (!_treeHasPendingAnimations) {
        if ([layer->_animations count]) {
            _treeHasPendingAnimations = YES;
            //DLog(@"_treeHasPendingAnimations: %d", _treeHasPendingAnimations);
        }
    }
    for (CALayer *sublayer in layer->_sublayers) {
        _CAAnimatorApplyAnimationsWithRoot(sublayer);
    }
}

static void _CAAnimatorApplyAnimations()
{
    //DLog();
    _treeHasPendingAnimations=NO;
    _CAAnimatorApplyAnimationsWithRoot(_CALayerRootLayer()->_presentationLayer);
    _CARendererDisplayLayers(NO);
}

static void reportFPS(BOOL withCondition)
{
    //NSTimeInterval currentTime = CACurrentMediaTime();
    if (CACurrentMediaTime() - beforeLockTime > _kResetTimeInterval || !withCondition) {
        float fps = _CAAnimatorFrameCount * 1.0 / (CACurrentMediaTime() - previousTimestamp);
        if (_CAAnimatorFrameCount>1) {
            //DLog(@"_CAAnimatorFrameCount: %d, fps: %0.0f", _CAAnimatorFrameCount, fps);
        }
        _CAAnimatorFrameCount = 0;
        previousTimestamp = CACurrentMediaTime();
    }
}

// CAAnimator uses CACompositor to composite Render Tree for each frame.
@implementation CAAnimator

+ (void)run
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [_CAAnimatorConditionLock lockWhenCondition:_CAAnimatorConditionLockStartup];
    DLog(@"Animation Thread: %@", [NSThread currentThread]);
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    //DLog(@"context: %@", context);
    [EAGLContext setCurrentContext:context];
    [context release];
    _EAGLSetup();
    //DLog();
    _EAGLClear();
    _EAGLSwapBuffers();
    //DLog();
    [_CAAnimatorConditionLock unlockWithCondition:_CAAnimatorConditionLockHasNoWork];
    //DLog();
    _eaglContextIsReady = YES;
    BOOL vSyncEnabled = context->_vSyncEnabled;
    
    _displayLink = [[CADisplayLink alloc] initWithTarget:self selector:@selector(display)];
    //_displayLink.frameInterval = 1;
    return;
    while (true) {
        NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
        //DLog(@"run");
        NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:0.01];
        [[NSRunLoop currentRunLoop] runUntilDate:limit];
        [limit release];
#ifdef NATIVE_APP
        //DLog(@"NATIVE_APP");
        if ([_CAAnimatorNAConditionLock tryLockWhenCondition:_CAAnimatorConditionLockHasWork]) {
            DLog();
            EAGLParentHandleMessages();
            [_CAAnimatorNAConditionLock unlock];
            DLog();
        }
#endif
        [pool2 release];
    }
    [pool release];
}

+ (void)display
{
    //DLog();
#ifdef NATIVE_APP
    if ([_CAAnimatorConditionLock condition] != _CAAnimatorConditionLockHasWork) {
        //beforeLockTime = CACurrentMediaTime();
        return;
    }
    //DLog();
    if (![_CAAnimatorConditionLock tryLock]) {
        //DLog(@"[_CAAnimatorConditionLock condition]: %d", [_CAAnimatorConditionLock condition]);
        // Instead of blocking the run loop or the animation thread, we will try to display later
        [[self class] performSelector:@selector(display) withObject:nil afterDelay:0.01];
        return;
    }
#else
    beforeLockTime = CACurrentMediaTime();
    //DLog();
    [_CAAnimatorConditionLock lockWhenCondition:_CAAnimatorConditionLockHasWork];
    //DLog();
#endif
    //DLog();
#ifdef DEBUG
    //_CAAnimatorFrameCount++;
#endif
    //currentTime = CACurrentMediaTime();
    //reportFPS(YES);
    //DLog();
    _CAAnimatorApplyAnimations();
    //DLog(@"_CARendererLoadRenderLayers");
    _CARendererLoadRenderLayers();
    //DLog(@"_CACompositorPrepareComposite");
    _CACompositorPrepareComposite();
    if (_treeHasPendingAnimations) {
        DLog(@"_treeHasPendingAnimations");
        if (!_treeHadPendingAnimations) {
            previousTimestamp = CACurrentMediaTime();
            _treeHadPendingAnimations = YES;
        }
        [_CAAnimatorConditionLock unlock];
        //DLog();
    } else {
        //DLog();
        if (_treeHadPendingAnimations) {
#ifdef DEBUG
            //reportFPS(NO);
#endif
            _treeHadPendingAnimations = NO;
        }
        [_CAAnimatorConditionLock unlockWithCondition:_CAAnimatorConditionLockHasNoWork];
    }
    //DLog();
    _CACompositorComposite();
    //DLog();
    _EAGLSwapBuffers();
}

@end

#pragma mark - Shared functions

void _CAAnimatorInitialize()
{
    _CAAnimatorConditionLock = [[NSConditionLock alloc] initWithCondition:_CAAnimatorConditionLockStartup];
#ifdef NATIVE_APP
    _CAAnimatorNAConditionLock = [[NSConditionLock alloc] initWithCondition:_CAAnimatorConditionLockStartup];
    [_CAAnimatorNAConditionLock lock];
#endif
    [NSThread detachNewThreadSelector:@selector(run)
                             toTarget:[CAAnimator class]
                           withObject:nil];
}
