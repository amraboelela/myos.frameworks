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

#import <QuartzCore/QuartzCore-private.h>
#import <CoreFoundation/CFArray-private.h>
#import <CoreGraphics/CoreGraphics-private.h>

// Presentation Layer is a node in the Presentation Tree
@implementation CALayer (PresentationLayer)

#pragma mark - Life cycle

- (id)initWithModelLayer:(CALayer *)layer
{
    self = [self initWithLayer:layer];
    if (self) {
        _needsComposite = NO;
        _modelLayer = layer;
        //_modelLayer->_presentationLayer = self;
        //_renderLayer = nil;
        _CALayerCopyAnimations(self);
    }
    return self;
}

@end

#pragma mark - Shared functions

#pragma mark - CALayer

void _CALayerRemoveFromSuperlayer(CALayer *layer)
{
    if (layer->_superlayer) {
        _CFArrayRemoveValue(layer->_superlayer->_sublayers, layer);
        layer->_superlayer = nil;
    }
}

void _CALayerAddSublayer(CALayer *layer, CALayer *sublayer, CFIndex index)
{
    _CALayerRemoveFromSuperlayer(sublayer);

    if (index >= CFArrayGetCount(layer->_sublayers)) {
        CFArrayAppendValue(layer->_sublayers, sublayer);
    } else {
        CFArrayInsertValueAtIndex(layer->_sublayers, index, sublayer);
    }
    sublayer->_superlayer = layer;
}

void _CALayerCopyAnimations(CALayer *layer)
{
    //DLog();
    CALayer *modelLayer = layer->_modelLayer;
    if ([modelLayer->_animations count]) {
        //DLog(@"");
        if (!layer->_animations) {
            layer->_animations = [[NSMutableDictionary alloc] initWithDictionary:modelLayer->_animations];
        }
        for (NSString *key in [modelLayer animationKeys]) {
            CAAnimation *animation = CFDictionaryGetValue(layer->_animations, key);
            CAAnimation *modelAnimation = CFDictionaryGetValue(modelLayer->_animations, key);
            if (animation && animation != modelAnimation) {
                [animation removeFromLayer:layer];
            } //else {
            //animation = CFDictionaryGetValue(modelLayer->_animations, key);
            CFDictionarySetValue(layer->_animations, key, modelAnimation);
            if ([modelAnimation isKindOfClass:[CABasicAnimation class]]) {
                CABasicAnimation *basicAnimation = (CABasicAnimation *)modelAnimation;
                if (basicAnimation->_beginFromCurrentState) {
                    basicAnimation.fromValue = [layer valueForKey:basicAnimation->_keyPath];
                }
                if (!basicAnimation->toValue) {
                    basicAnimation.toValue = [modelLayer valueForKeyPath:basicAnimation->_keyPath];
                }
            } /*else if ([animation isKindOfClass:[CAKeyframeAnimation class]]) {
               //DLog(@"[theAnimation isKindOfClass:[CAKeyframeAnimation class]]");
               }*/
            //}
        }
    }
}

void _CALayerApplyAnimations(CALayer *layer)
{
    //DLog(@"layer: %@", layer);
    if ([layer->_animations count]) {
        CFTimeInterval time = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        //DLog(@"layer->_animations: %@", layer->_animations);
        CFArrayRef keys = [layer animationKeys];
        //DLog(@"keys: %@", keys);
        for (NSString *key in keys) {
            // Adjust animation begin time
            //DLog(@"key: %@", key);
            CAAnimation *animation = [layer animationForKey:key];
            _CAAnimationApplyAnimationForLayer(animation, layer, time);
        }
        //DLog(@"keys: %@", keys);
    }
}
