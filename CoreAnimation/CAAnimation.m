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
#import <CoreFoundation/CoreFoundation-private.h>
#import <CoreGraphics/CoreGraphics-private.h>

NSString *const kCAAnimationDiscrete = @"CAAnimationDiscrete";

/* transition types */
NSString *const kCATransitionMoveIn = @"CATransitionMoveIn";

/* transition subtypes */
NSString *const kCATransitionFromTop = @"CATransitionFromTop";
NSString *const kCATransitionFromBottom = @"CATransitionFromBotton";
NSString *const kCATransitionFromLeft = @"CATransitionFromLeft";
NSString *const kCATransitionFromRight = @"CATransitionFromRight";

static NSMutableArray *_animationGroups = nil;

#define _kSmallTimeMargin 0.1

#pragma mark - Static functions

static CFTimeInterval _CAAnimationGetProgressTime(CABasicAnimation *animation, CFTimeInterval time)
{
    CFTimeInterval localTime = (time - animation->_beginTime) * animation->_speed + animation->_timeOffset;
    CFTimeInterval activeTime = localTime - animation->_startTime;
    //DLog(@"activeTime: %0.2f", activeTime);
    if (activeTime < 0) {
        return activeTime;
    }
    int k = floor(activeTime/animation->_duration);
    CFTimeInterval progressTime = activeTime - k * animation->_duration;
    if (animation->_autoreverses && k % 2 == 1) {
        progressTime = animation->_duration - progressTime;
    }
    if (animation->_removedOnCompletion) {
        if (animation->_repeatCount > 0.0) {
            //DLog(@"animation->_repeatCount: %f", animation->_repeatCount);
            if (k > animation->_repeatCount) {
                animation->_remove = YES;
                int repeatCount = floor(animation->_repeatCount);
                //DLog(@"repeatCount: %d", repeatCount);
                if (animation->_autoreverses) {
                    //DLog(@"animation->_autoreverses: %d", animation->_autoreverses);
                    if (repeatCount % 2 == 1) {
                        progressTime = 0;
                    } else {
                        progressTime = animation->_duration;
                    }
                } else {
                    if (repeatCount % 2 == 1) {
                        progressTime = animation->_duration;
                    } else {
                        progressTime = 0;
                    }
                }
            }
        } else if (activeTime - animation->_duration > animation->_repeatDuration) {
            //DLog(@"animation->_repeatDuration: %0.1f", animation->_repeatDuration);
            animation->_remove = YES;
            if (k % 2 == 1) {
                progressTime = animation->_duration;
            } else {
                progressTime = 0;
            }
        }
    }
    DLog(@"progressTime: %0.1f", progressTime);
    return progressTime;
}

static float _CAAnimationGetProgress(CABasicAnimation *animation, CFTimeInterval progressTime)
{
    if (progressTime < 0) {
        return 0;
    }
    float timeRatio = progressTime / animation->_duration;
    DLog(@"timeRatio: %0.2f", timeRatio);
    return _CAMediaTimingFunctionApply(animation->_timingFunction, timeRatio);
}

static id _CAAnimationFloatProgressValue(CABasicAnimation *animation, float progress)
{
    DLog(@"animation: %@", animation);
    float fromValue = [animation->fromValue floatValue];
    float toValue = [animation->toValue floatValue];
    float result = fromValue + (toValue - fromValue) * progress;
    DLog(@"result: %0.1f", result);
    return [NSNumber numberWithFloat:result];
}

static id _CAAnimationPointProgressValue(CABasicAnimation *animation, float progress)
{
    //DLog();
    CGPoint fromPoint = [animation->fromValue CGPointValue];
    CGPoint toPoint = [animation->toValue CGPointValue];
    //DLog(@"toPoint: %@", NSStringFromPoint(NSPointFromCGPoint(toPoint)));

    float resultX = fromPoint.x + (toPoint.x - fromPoint.x) * progress;
    float resultY = fromPoint.y + (toPoint.y - fromPoint.y) * progress;
    CGPoint result = CGPointMake(resultX, resultY);
    //DLog(@"result: %@", NSStringFromPoint(NSPointFromCGPoint(result)));
    return [NSValue valueWithCGPoint:result];
    //return [NSValue valueWithBytes:&result objCType:@encode(CGPoint)];
}

static id _CAAnimationRectProgressValue(CABasicAnimation *animation, float progress)
{
    //DLog();
    CGRect fromRect = [animation->fromValue CGRectValue];
    CGRect toRect = [animation->toValue CGRectValue];
    float resultX = fromRect.origin.x + (toRect.origin.x - fromRect.origin.x) * progress;
    float resultY = fromRect.origin.y + (toRect.origin.y - fromRect.origin.y) * progress;
    float resultWidth =  fromRect.size.width + (toRect.size.width - fromRect.size.width) * progress;
    float resultHeight = fromRect.size.height + (toRect.size.height - fromRect.size.height) * progress;
    CGRect result = CGRectMake(resultX, resultY, resultWidth, resultHeight);
    //DLog(@"result: %@", CGRectDescription(result));
    return [NSValue valueWithCGRect:result];
}

static id _CAAnimationTransformProgressValue(CABasicAnimation *animation, float progress)
{
    //DLog();
    CATransform3D fromTransform = [animation->fromValue CATransform3DValue];
    CATransform3D toTransform = [animation->toValue CATransform3DValue];
    CGFloat m11 = fromTransform.m11 + (toTransform.m11 - fromTransform.m11) * progress;
    CGFloat m12 = fromTransform.m12 + (toTransform.m12 - fromTransform.m12) * progress;
    CGFloat m13 = fromTransform.m13 + (toTransform.m13 - fromTransform.m13) * progress;
    CGFloat m14 = fromTransform.m14 + (toTransform.m14 - fromTransform.m14) * progress;
    CGFloat m21 = fromTransform.m21 + (toTransform.m21 - fromTransform.m21) * progress;
    CGFloat m22 = fromTransform.m22 + (toTransform.m22 - fromTransform.m22) * progress;
    CGFloat m23 = fromTransform.m23 + (toTransform.m23 - fromTransform.m23) * progress;
    CGFloat m24 = fromTransform.m24 + (toTransform.m24 - fromTransform.m24) * progress;
    CGFloat m31 = fromTransform.m31 + (toTransform.m31 - fromTransform.m31) * progress;
    CGFloat m32 = fromTransform.m32 + (toTransform.m32 - fromTransform.m32) * progress;
    CGFloat m33 = fromTransform.m33 + (toTransform.m33 - fromTransform.m33) * progress;
    CGFloat m34 = toTransform.m34;
    CGFloat m41 = fromTransform.m41 + (toTransform.m41 - fromTransform.m41) * progress;
    CGFloat m42 = fromTransform.m42 + (toTransform.m42 - fromTransform.m42) * progress;
    CGFloat m43 = fromTransform.m43 + (toTransform.m43 - fromTransform.m43) * progress;
    CGFloat m44 = fromTransform.m44 + (toTransform.m44 - fromTransform.m44) * progress;
    
    CATransform3D result = (CATransform3D) {
                            m11, m12, m13, m14,
                            m21, m22, m23, m24,
                            m31, m32, m33, m34,
                            m41, m42, m43, m44 };
    //DLog(@"result: %@", CATransform3DDescription(result));
    return [NSValue valueWithCATransform3D:result];
}

static id _CAAnimationColorProgressValue(CABasicAnimation *animation, float progress)
{
    CGColorRef fromColor = animation->fromValue;
    CGColorRef toColor = animation->toValue;
    
    const CGFloat *fromComponents = CGColorGetComponents(fromColor);
    const CGFloat *toComponents = CGColorGetComponents(toColor);
    
    int numberOfComponents = CGColorGetNumberOfComponents(fromColor);
    float resultComponents[4] = {0,0,0,1};
    for (int i=0; i<numberOfComponents; i++) {
        resultComponents[i] =  fromComponents[i] + (toComponents[i] - fromComponents[i]) * progress;
    }
    return [(id)CGColorCreate(CGColorGetColorSpace(fromColor), resultComponents) autorelease];
}

@implementation CAAnimation

@synthesize delegate=_delegate;
@synthesize timingFunction=_timingFunction;
@synthesize removedOnCompletion=_removedOnCompletion;
@synthesize beginTime=_beginTime;
@synthesize timeOffset=_timeOffset;
@synthesize duration=_duration;
@synthesize repeatCount=_repeatCount;
@synthesize repeatDuration=_repeatDuration;
@synthesize autoreverses=_autoreverses;
@synthesize fillMode=_fillMode;
@synthesize speed=_speed;

#pragma mark - Life cycle

+ (id)animation
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        _beginTime = 0;
        _startTime = 0;
        //DLog(@"[CATransaction valueForKey:kCATransactionAnimationDuration]: %0.0f", [CATransaction valueForKey:kCATransactionAnimationDuration]);
        CFNumberGetValue([CATransaction valueForKey:kCATransactionAnimationDuration], kCFNumberDoubleType, &_duration);//(CFTimeInterval)[(NSNumber *)[CATransaction valueForKey:kCATransactionAnimationDuration] doubleValue];
        //DLog(@"_duration: %0.2f", _duration);
        _timingFunction = [CATransaction valueForKey:kCATransactionAnimationTimingFunction] ? :
                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [_timingFunction retain];
        _repeatCount = 0;
        _repeatDuration = 0;
        _autoreverses = NO;
        _removedOnCompletion = YES;
        _remove = NO;
        _fillMode = nil;
        _speed = 1;
        _timeOffset = 0;
        _beginFromCurrentState = NO;
        //DLog(@"self: %@", self);
    }
    return self;
}

- (void)dealloc
{
    [_delegate release];
    [_timingFunction release];
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)description
{
    //return [NSString stringWithFormat:@"<%@: %p; beginTime: %0.1f; duration: %0.1f>", [self className], self, beginTime, duration];
    return [NSString stringWithFormat:@"<%@: %p; beginTime: %0.1f; duration: %0.1f; _repeatCount: %0.1f; _beginFromCurrentState: %d>", [self className], self, _beginTime, _duration, _repeatCount, _beginFromCurrentState];
    //return [NSString stringWithFormat:@"<%@: %p; timingFunction: %@>", [self className], self, timingFunction];
}

#pragma mark - CAAction

- (void)runActionForKey:(NSString *)key object:(id)anObject arguments:(NSDictionary *)dict
{
    //DLog(@"key: %@", key);
    //DLog(@"anObject: %@", anObject);
    [(CALayer *)anObject addAnimation:self forKey:key];
}

#pragma mark - Public methods

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[self class] allocWithZone:zone];
    if (copy) {
        static NSString *keys[] = {@"delegate", @"removedOnCompletion", @"timingFunction", @"duration",
            @"speed", @"autoreverses", @"repeatCount"};
        for (int i=0; i<7; i++) {
            id value = [self valueForKey:keys[i]];
            if (value) {
                [copy setValue:value forKey:keys[i]];
            }
        }
    }
    return copy;
}

@end

@implementation CAPropertyAnimation

@synthesize keyPath;
@synthesize additive;
@synthesize cumulative;

#pragma mark - Life cycle

- (id)initWithKeyPath:(NSString *)aKeyPath
{
    //DLog();
    self = [super init];
    if (self) {
        keyPath = [aKeyPath copy];
    }
    return self;
}

+ (id)animationWithKeyPath:(NSString *)path
{
    //DLog();
    return [[[self alloc] initWithKeyPath:path] autorelease];
}

- (void)dealloc
{
    [keyPath release];
    [super dealloc];
}

#pragma mark - Public methods

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [super copyWithZone:zone];
    if (copy) {
        static NSString *keys[] = {@"additive", @"cumulative", @"keyPath"};
        for (int i=0; i<3; i++) {
            id value = [self valueForKey:keys[i]];
            if (value) {
                [copy setValue:value forKey:keys[i]];
            }
        }
    }
    return copy;
}

@end

@implementation CABasicAnimation

@synthesize fromValue;
@synthesize toValue;
@synthesize byValue;

#pragma mark - Life cycle

- (void)dealloc
{
    [fromValue release];
    [toValue release];
    [byValue release];
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)description
{
    //return [NSString stringWithFormat:@"<%@: %p; duration: %0.1f; fromValue: %@; toValue: %@>", [self className], self, duration, fromValue, toValue];
    //return [NSString stringWithFormat:@"<%@: %p; beginTime: %f>", [self className], self, _beginTime];
    //return [NSString stringWithFormat:@"<%@: %p; timingFunction: %@>", [self className], self, timingFunction];
    return [super description];
}

#pragma mark - Delegate

- (void)removeFromLayer:(CALayer *)layer
{
    //DLog(@"layer: %@", layer);
    if ([_delegate respondsToSelector:@selector(animationDidStop:finished:)]) {
        [_delegate animationDidStop:self finished:YES];
    }
    [layer removeAnimationForKey:keyPath];
    _CAAnimationGroupRemoveAnimation(_animationGroup, self);
}

@end

@implementation CAKeyframeAnimation

@synthesize calculationMode=_calculationMode;
@synthesize values=_values;

#pragma mark - Life cycle

- (void)dealloc
{
    [_calculationMode release];
    [_values release];
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; values: %@>", [self className], self, _values];
}

#pragma mark - Public methods

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [super copyWithZone:zone];
    if (copy) {
        [copy setCalculationMode:_calculationMode];
        [copy setValues:_values];
    }
    return copy;
}

@end

@implementation CATransition

@synthesize type;
@synthesize subtype;
@synthesize startProgress;
@synthesize endProgress;

#pragma mark - Life cycle

- (void)dealloc
{
    [type release];
    [subtype release];
    [super dealloc];
}

@end

@implementation CAAnimationGroup

@synthesize animations=_animations;

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        //DLog();
        _animations = CFArrayCreateMutable(kCFAllocatorDefault, 5, &kCFTypeArrayCallBacks);
        //_committed = NO;
    }
    return self;
}

- (void)dealloc
{
    [_animations release];
    [super dealloc];
}

#pragma mark - Accessors

- (NSString *)description
{
    //return [NSString stringWithFormat:@"<%@: %p; duration: %0.1f; fromValue: %@; toValue: %@>", [self className], self, duration, fromValue, toValue];
    //return [NSString stringWithFormat:@"<%@: %p; beginTime: %f>", [self className], self, _beginTime];
    return [NSString stringWithFormat:@"<%@: %p; committed: %d; animations: %@>", [self className], self, _committed, _animations];
    //return [super description];
}

@end

#pragma mark - Shared functions

#pragma mark - Life cycle

void _CAAnimationInitialize()
{
    _animationGroups = CFArrayCreateMutable(kCFAllocatorDefault, 3, &kCFTypeArrayCallBacks);
}

#pragma mark - Animation

void _CAAnimationApplyAnimationForLayer(CAAnimation *theAnimation, CALayer *layer, CFTimeInterval time)
{
    CABasicAnimation *animation = (CABasicAnimation *)theAnimation;
    CFTimeInterval progressTime = _CAAnimationGetProgressTime(animation, time);
    id result = nil;
    float progress = _CAAnimationGetProgress(animation, progressTime);
    if ([theAnimation isKindOfClass:[CABasicAnimation class]]) {
        id localValue = [layer valueForKeyPath:animation->keyPath];
        //DLog(@"localValue: %@", localValue);
        if ([localValue isKindOfClass:[NSNumber class]]) {
            result = _CAAnimationFloatProgressValue(animation, progress);
        } else if ([localValue isKindOfClass:[NSValue class]]) {
            //DLog(@"@encode(CGPoint): %s", @encode(CGPoint));
            if (strcmp([localValue objCType], @encode(CGPoint)) == 0) {
                result = _CAAnimationPointProgressValue(animation, progress);
            } else if (strcmp([localValue objCType], @encode(CGRect)) == 0) {
                result = _CAAnimationRectProgressValue(animation, progress);
            } else if (strcmp([localValue objCType], @encode(CATransform3D)) == 0) {
                result = _CAAnimationTransformProgressValue(animation, progress);
            }
        } else if ([localValue isKindOfClass:NSClassFromString(@"CGColor")]) {
            result = _CAAnimationColorProgressValue(animation, progress);
        }
        if (result) {
            [layer setValue:result forKeyPath:animation->keyPath];
        }
        DLog(@"animation: %@", animation);
        if ([animation->keyPath isEqualToString:@"contents"]) {
            DLog(@"[animation->keyPath isEqualToString:contents]");
            layer->_contentsTransitionProgress = progress;
            if (animation->_remove) {
                layer->_contentsTransitionProgress = 1.0;
            }
        }
    } else if ([theAnimation isKindOfClass:[CAKeyframeAnimation class]]) {
        //DLog(@"[theAnimation isKindOfClass:[CAKeyframeAnimation class]]");
        if ([animation->keyPath isEqualToString:@"contents"]) {
            layer->_keyframesProgress = progress;
            //DLog(@"layer->_keyframesProgress: %0.2f", layer->_keyframesProgress);
            if (animation->_remove) {
                layer->_keyframesProgress = -1;
            }
        }
    }
    if (animation->_remove) {
        //DLog(@"animation: %@", animation);
        //[animation performSelector:@selector(removeFromLayer:) withObject:layer waitUntilDone:YES];
        [animation performSelectorOnMainThread:@selector(removeFromLayer:) withObject:layer waitUntilDone:YES];
        //[animation removeFromLayer:layer];
        
        //_CAAnimationRemove(animation, layer);
        //[layer removeAnimationForKey:animation->keyPath];
        //DLog(@"animation2: %@", animation);
    }
}

#pragma mark - Animation groups

CAAnimationGroup *_CAAnimationGroupNew()
{
    //DLog();
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    CFArrayAppendValue(_animationGroups, animationGroup);
    return animationGroup;
}

CAAnimationGroup *_CAAnimationGroupGetCurrent()
{
    //DLog(@"_animationGroups: %@", _animationGroups);
    for (CAAnimationGroup *animationGroup in [_animationGroups reverseObjectEnumerator]) {
        if (!animationGroup->_committed) {
            //DLog(@"animationGroup: %@", animationGroup);
            return animationGroup;
        }
    }
    return nil;
}

void _CAAnimationGroupAddAnimation(CAAnimationGroup *animationGroup, CAAnimation *animation)
{
    //DLog(@"animation: %@", animation);
    //CAAnimationGroup *animationGroup = _CAAnimationCurrentActiveAnimationGroup();
    CFArrayAppendValue((CFMutableArrayRef)animationGroup->_animations, animation);
    animation->_animationGroup = animationGroup;
    //DLog(@"animationGroup: %@", animationGroup);
}

void _CAAnimationGroupCommit()
{
    //DLog();
    CAAnimationGroup *animationGroup = _CAAnimationGroupGetCurrent();
    if (animationGroup) {
        //[_animationGroups removeObject:animationGroup];
        animationGroup->_committed = YES;
        //DLog(@"animationGroup: %@", animationGroup);
    }
}

void _CAAnimationGroupRemoveAnimation(CAAnimationGroup *animationGroup, CAAnimation *animation)
{
    //DLog(@"animation: %@", animation);
    //CAAnimationGroup *animationGroup = _CAAnimationCurrentActiveAnimationGroup();
    animation->_animationGroup = nil;
    _CFArrayRemoveValue((CFMutableArrayRef)animationGroup->_animations, animation);
    //DLog(@"animationGroup: %@", animationGroup);
    if (CFArrayGetCount(animationGroup->_animations) == 0) {
        if ([animationGroup->_delegate respondsToSelector:@selector(animationDidStop:finished:)]) {
            [animationGroup->_delegate animationDidStop:animationGroup finished:YES];
        }
        //DLog(@"_animationGroups: %@", _animationGroups);
        _CFArrayRemoveValue(_animationGroups, animationGroup);
        //DLog(@"_animationGroups2: %@", _animationGroups);
    }
}

#pragma mark - Public methods

void _CAAnimationCopy(CAAnimation *toAnimation, CAAnimation *fromAnimation)
{
    //DLog();
    toAnimation->_beginTime = fromAnimation->_beginTime;
    toAnimation.timingFunction = fromAnimation.timingFunction;
    //DLog(@"toAnimation.timingFunction: %@", toAnimation.timingFunction);
    toAnimation->_duration = fromAnimation->_duration;
    toAnimation->_repeatCount = fromAnimation->_repeatCount;
    //DLog(@"fromAnimation->_repeatCount: %f", fromAnimation->_repeatCount);
    //DLog(@"fromAnimation->_autoreverses: %d", fromAnimation->_autoreverses);
    toAnimation->_autoreverses = fromAnimation->_autoreverses;
    toAnimation->_fillMode = fromAnimation->_fillMode;
    //DLog(@"fromAnimation: %@", fromAnimation);
    toAnimation->_beginFromCurrentState = fromAnimation->_beginFromCurrentState;
}
