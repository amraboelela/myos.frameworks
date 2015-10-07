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
#import <OpenGLES/EAGL-private.h>
#import <IOKit/IOKit.h>
#import <UIKit/UIScreen-private.h>

static BOOL _foundOpaqueLayer = NO;

#pragma mark - Static functions

static void setNeedsCompositeIfIntersects(CARenderLayer *layer, CARenderLayer *opaqueLayer, CGRect r)
{
    //if (layer->_opacity > 0) {
    CGRect rectInLayer = [opaqueLayer convertRect:r toLayer:layer];
    if (CGRectIntersectsRect(layer->_bounds, rectInLayer)) {
        CGRect intersection = CGRectIntersection(layer->_bounds, rectInLayer);
        intersection = _CARenderLayerApplyMasksToBoundsToRect(layer, layer->_superlayer, intersection);
        layer->_rectNeedsComposite = CGRectUnion(layer->_rectNeedsComposite, intersection);
        for (CARenderLayer *sublayer in layer->_sublayers) {
            setNeedsCompositeIfIntersects(sublayer, opaqueLayer, r);
        }
    }
    //}
}

static void setNeedsCompositeInRect(CARenderLayer *layer, CARenderLayer *opaqueLayer, CGRect r)
{
    for (CARenderLayer *sublayer in layer->_sublayers) {
        if (!sublayer->_hidden) {
            if (sublayer==opaqueLayer) {
                _foundOpaqueLayer = YES;
            }
            if (_foundOpaqueLayer) {
                setNeedsCompositeIfIntersects(sublayer,opaqueLayer,r);
            }
            setNeedsCompositeInRect(sublayer, opaqueLayer, r);
        }
    }
}

static CGPoint _CARenderLayerGetOrigin(CARenderLayer *layer)
{
    if (layer->_superlayer) {
        CGPoint result;
        CGPoint superlayerOrigin = _CARenderLayerGetOrigin((CARenderLayer *)layer->_superlayer);
        CGPoint position = layer->_position;
        CGRect bounds = layer->_bounds;
        CGPoint anchorPoint = layer->_anchorPoint;
        result.x = superlayerOrigin.x + position.x - bounds.size.width * anchorPoint.x + bounds.origin.x;
        result.y = superlayerOrigin.y + position.y - bounds.size.height * (1 - anchorPoint.y) + bounds.origin.y;
        return result;
    } else {
        return layer->_bounds.origin; //CGPointZero;
    }
}

static CATransform3D _CARenderLayerTransform(CARenderLayer *layer)
{
    //DLog(@"layer: %@", layer);
    CATransform3D result = layer->_transform;
    //DLog(@"result: %@", CATransform3DDescription(result));
    while (layer->_superlayer) {
        layer = layer->_superlayer;
        //DLog(@"layer: %@", layer);
        CATransform3D transform = layer->_sublayerTransform;
        if (!CATransform3DIsIdentity(transform)) {
            result = CATransform3DConcat(result, transform);
            //DLog(@"result: %@", CATransform3DDescription(result));
        }
    }
    return result;
}

static void _CARenderLayerCompositeWithOpacity(CARenderLayer *layer, float opacity, int textureID)
{
    int i;
    //DLog(@"textureID: %d", textureID);
    //DLog(@"layer: %@", layer);
    if (textureID == 0) {
        return;
    }
    glBindTexture(GL_TEXTURE_2D, textureID);
    //DLog(@"textureID: %d", textureID);
    //DLog(@"layer: %@", layer);
    float xr = layer->_rectNeedsComposite.origin.x;
    float yr = layer->_rectNeedsComposite.origin.y;
    float wr = layer->_rectNeedsComposite.size.width;
    float hr = layer->_rectNeedsComposite.size.height;
    CGRect bounds = layer->_bounds;
    float wl = bounds.size.width; // width of layer bounds
    float hl = bounds.size.height; // height of layer bounds
    //DLog(@"textureID: %d, wl: %0.1f, hl: %0.1f", textureID, wl, hl);
    CGPoint p1 = CGPointMake(xr/wl, 1.0-yr/hl);
    CGPoint p2 = CGPointMake((xr+wr)/wl, p1.y);
    CGPoint p3 = CGPointMake(p1.x, 1.0-(yr+hr)/hl);
    CGPoint p4 = CGPointMake(p2.x, p3.y);
    
    GLfloat texCoords[] = {
        p1.x, p1.y,
        p2.x, p2.y,
        p3.x, p3.y,
        p4.x, p4.y
    };
    
    //DLog(@"texCoords: %0.1f, %0.1f, %0.1f, %0.1f, %0.1f, %0.1f, %0.1f, %0.1f", texCoords[0], texCoords[1], texCoords[2], texCoords[3],
    //     texCoords[4], texCoords[5], texCoords[6], texCoords[7]);
    IOWindow *screenWindow = IOWindowGetSharedWindow();
    //CGRect screenBound = [UIScreen mainScreen].bounds;
    float ws = _kScreenWidth;//screenWindow->_rect.size.width; // width of screen // _kScreenWidth
    float hs = _kScreenHeight;//screenWindow->_rect.size.height; // height of screen // _kScreenHeight
    
    CGPoint layerOrigin = _CARenderLayerGetOrigin(layer);
    //DLog(@"ws: %0.1f, hs: %0.1f", ws, hs);

    float xo = layerOrigin.x + xr;
    float yo = layerOrigin.y + yr;
    
    CATransform3D transform = _CARenderLayerTransform(layer);
    if (CATransform3DIsIdentity(transform)) {
        p1 = CGPointMake(2.0*xo/ws-1, 1.0-2*yo/hs);
        p2 = CGPointMake(2.0*(xo+wr)/ws-1, p1.y);
        p3 = CGPointMake(p1.x, 1.0-2*(yo+hr)/hs);
        p4 = CGPointMake(p2.x, p3.y);
    } else {
        //CATransform3D transform = layer->_transform;
        //DLog(@"layer.transform: %@", CATransform3DDescription(transform));
        CAPoint anchorPoint = CAPointMake(layerOrigin.x + layer->_anchorPoint.x * bounds.size.width,
                                          layerOrigin.y + (1-layer->_anchorPoint.y) * bounds.size.height,
                                          0);
        CAPoint po1 = CAPointMake(xo, yo, 0);
        po1 = CAPointTransform(CAPointSubtract(po1, anchorPoint), transform);
        CAPoint po2 = CAPointMake(xo+wr, yo, 0);
        po2 = CAPointTransform(CAPointSubtract(po2, anchorPoint), transform);
        CAPoint po3 = CAPointMake(xo, yo+hr, 0);
        po3 = CAPointTransform(CAPointSubtract(po3, anchorPoint), transform);
        CAPoint po4 = CAPointMake(xo+wr, yo+hr, 0);
        po4 = CAPointTransform(CAPointSubtract(po4, anchorPoint), transform);
        if (transform.m34 != 0) { // Apply Prespective
            CGFloat zPosition = layer->_zPosition;
            //DLog(@"zPosition: %0.1f", zPosition);
            CGFloat eyePosition = -1.0/transform.m34;
            CGFloat viewingDistance = eyePosition;
            //DLog(@"eyePosition: %0.1f", eyePosition);
            CGFloat zPlusEye = zPosition + eyePosition;
            CGFloat depth = (po1.z + zPlusEye) / viewingDistance;
            po1.x /= depth;
            po1.y /= depth;
            depth = (po2.z + zPlusEye) / viewingDistance;
            po2.x /= depth;
            po2.y /= depth;
            depth = (po3.z + zPlusEye) / viewingDistance;
            po3.x /= depth;
            po3.y /= depth;
            depth = (po4.z + zPlusEye) / viewingDistance;
            po4.x /= depth;
            po4.y /= depth;
        }
        po1 = CAPointAdd(po1, anchorPoint);
        p1 = CGPointMake(2.0*po1.x/ws-1, 1.0-2*po1.y/hs);
        po2 = CAPointAdd(po2, anchorPoint);
        p2 = CGPointMake(2.0*po2.x/ws-1, 1.0-2*po2.y/hs);
        po3 = CAPointAdd(po3, anchorPoint);
        p3 = CGPointMake(2.0*po3.x/ws-1, 1.0-2*po3.y/hs);
        po4 = CAPointAdd(po4, anchorPoint);
        p4 = CGPointMake(2.0*po4.x/ws-1, 1.0-2*po4.y/hs);
    }
    
    GLfloat vertices[] = {
        p1.x, p1.y,
        p2.x, p2.y,
        p3.x, p3.y,
        p4.x, p4.y
    };
    
    EAGLContext *context = _EAGLGetCurrentContext();
    //DLog(@"context->_width: %0.1f, context->_height: %0.1f", context->_width, context->_height);
    glViewport(0, 0, context->_width, context->_height);
    
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    //DLog(@"glGetError: %d", glGetError());
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    //DLog(@"glGetError: %d", glGetError());
    
    glColor4f(opacity, opacity, opacity, opacity);
    //glColor4f(0.3, 0.3, 0.3, 0.3);
    //DLog(@"glGetError: %d", glGetError());
    //glColor4f(1.0, hs/ws, 0.0, 1.0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //DLog(@"glGetError: %d", glGetError());
    
    //glClearColor(0.0, 1.0, 0.0, 0.5);
    //glClear(GL_COLOR_BUFFER_BIT);
    //glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    //_EAGLSwapBuffers();
    //DLog(@"glGetError: %d", glGetError());
}

static void _CARenderLayerComposite(CARenderLayer *layer)
{
    //DLog();
    GLuint textureID;
    if (layer->_contentsTransitionProgress < 1.0) {
        GLuint oldTextureID = layer->_oldBackingStore->_texture->_textureIDs[0];
        textureID = layer->_backingStore->_texture->_textureIDs[0];
        //GLuint textureID2 = layer->_backingStore->_texture->_textureIDs[1];
        //DLog(@"oldBackingStore: %@", layer->_oldBackingStore);
        //DLog(@"backingStore: %@", layer->_backingStore);
        //DLog(@"textureID: %d", textureID);
        //DLog(@"oldTextureID: %d", oldTextureID);
        //DLog(@"layer->_contentsTransitionProgress: %0.1f", layer->_contentsTransitionProgress);
        _CARenderLayerCompositeWithOpacity(layer, layer->_opacity*(1.0-layer->_contentsTransitionProgress), oldTextureID);
        _CARenderLayerCompositeWithOpacity(layer, layer->_opacity*layer->_contentsTransitionProgress, textureID);
    } else if (layer->_keyframesProgress > -1) {
        int index = round(layer->_keyframesProgress * (layer->_backingStore->_texture->_numberOfTextures - 1));
        textureID = layer->_backingStore->_texture->_textureIDs[index];
        if (layer->_keyframesProgress < 0.1) {
            //DLog(@"index: %d, textureID: %d", index, textureID);
        }
        _CARenderLayerCompositeWithOpacity(layer, layer->_opacity, textureID);
    } else {
        if (layer->_backingStore->_texture->_numberOfTextures > 0) {
            textureID = layer->_backingStore->_texture->_textureIDs[0];
            //DLog(@"opacity: %0.1f", layer->_opacity);
            //DLog(@"textureID: %d", textureID);
            _CARenderLayerCompositeWithOpacity(layer, layer->_opacity, textureID);
        } else {
            DLog(@"layer->_backingStore->_texture->_numberOfTextures == 0");
        }
    }
}

@implementation CARenderLayer

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        //_presentationLayer = layer;
        //layer->_renderLayer = self;
        _bounds = CGRectZero;
        _position = CGPointZero;
        _anchorPoint = CGPointMake(0.5, 0.5);
        _opaque = NO;
        _oldBackingStore = [[CABackingStore alloc] init];
        _backingStore = [[CABackingStore alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_oldBackingStore release];
    [_backingStore release];
    [super dealloc];
}

@end

#pragma mark - Public functions

void _CARenderLayerCopy(CARenderLayer *renderLayer, CALayer *presentationLayer)
{
    //DLog(@"renderLayer: %@", renderLayer);
    //DLog(@"presentationLayer: %@", presentationLayer);
    renderLayer->_position = presentationLayer->_position;
    renderLayer->_zPosition = presentationLayer->_zPosition;
    renderLayer->_bounds = presentationLayer->_bounds;
    renderLayer->_anchorPoint = presentationLayer->_anchorPoint;
    renderLayer->_transform = presentationLayer->_transform;
    renderLayer->_sublayerTransform = presentationLayer->_sublayerTransform;
    renderLayer->_masksToBounds = presentationLayer->_masksToBounds;
    renderLayer->_contentsTransitionProgress = presentationLayer->_contentsTransitionProgress;
    renderLayer->_keyframesProgress = presentationLayer->_keyframesProgress;
    renderLayer->_contentsRect = presentationLayer->_contentsRect;
    renderLayer->_contentsScale = presentationLayer->_contentsScale;
    renderLayer->_contentsCenter = presentationLayer->_contentsCenter;
    renderLayer->_opaque = presentationLayer->_opaque;
    renderLayer->_opacity = presentationLayer->_opacity;
    renderLayer->_hidden = presentationLayer->_hidden;
    renderLayer->_masksToBounds = presentationLayer->_masksToBounds;
    //DLog(@"renderLayer->_displayContents: %@", renderLayer->_displayContents);
    CGImageRelease(renderLayer->_displayContents);
    renderLayer->_displayContents = CGImageRetain(presentationLayer->_displayContents);
}

CARenderLayer *_CARenderLayerClosestOpaqueLayerFromLayer(CARenderLayer *layer)
{
    if ((layer->_opaque && !layer->_hidden) || !layer->_superlayer) {
        return layer;
    } else {
        return _CARenderLayerClosestOpaqueLayerFromLayer((CARenderLayer *)layer->_superlayer);
    }
}

CGRect _CARenderLayerApplyMasksToBoundsToRect(CALayer *layer, CALayer *ancestorLayer, CGRect rect)
{
    CGRect resultRect = rect;
    if (ancestorLayer) {
        if (ancestorLayer->_masksToBounds) {
            CGRect ancestorRect = [ancestorLayer convertRect:ancestorLayer->_bounds toLayer:layer];
            resultRect = CGRectIntersection(rect, ancestorRect);
        }
        return _CARenderLayerApplyMasksToBoundsToRect(layer, ancestorLayer->_superlayer, resultRect);
    }
    return resultRect;
}

void _CARenderLayerSetNeedsCompositeInRect(CARenderLayer *rootLayer, CARenderLayer *opaqueLayer, CGRect r)
{
    _foundOpaqueLayer = NO;
    if (rootLayer==opaqueLayer) {
        _foundOpaqueLayer = YES;
        setNeedsCompositeIfIntersects(rootLayer, opaqueLayer, r);
    }
    setNeedsCompositeInRect(rootLayer, opaqueLayer, r);
}

void _CARenderLayerCompositeIfNeeded(CARenderLayer *layer)
{
    //DLog(@"layer: %@", layer);
    if (!CGRectEqualToRect(layer->_rectNeedsComposite, CGRectZero)) {
        _CARenderLayerComposite(layer);
    } else {
        //DLog(@"layer with zero rect: %@", layer);
    }
}

void _CARenderLayerUnload(CARenderLayer *layer)
{
    //DLog(@"layer: %@", layer);
    _CABackingStoreUnload(layer->_backingStore);
    for (CARenderLayer *sublayer in layer->_sublayers) {
        _CARenderLayerUnload(sublayer);
    }
}
