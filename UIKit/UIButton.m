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
#import <QuartzCore/QuartzCore-private.h>

static NSString *const UIButtonContentTypeTitle = @"UIButtonContentTypeTitle";
static NSString *const UIButtonContentTypeTitleColor = @"UIButtonContentTypeTitleColor";
static NSString *const UIButtonContentTypeTitleShadowColor = @"UIButtonContentTypeTitleShadowColor";
static NSString *const UIButtonContentTypeBackgroundImage = @"UIButtonContentTypeBackgroundImage";
static NSString *const UIButtonContentTypeImage = @"UIButtonContentTypeImage";

#define kButtonMargin   4

#pragma mark - Static functions

static UIColor *_UIButtonDefaultTitleColor(UIButton *button, UIControlState state)
{
    switch (button->_buttonType) {
        case UIButtonTypeCustom:
            return button->_titleLabel.textColor;
        case UIButtonTypeSystem:
            switch (state) {
                case UIControlStateNormal:
                    //return [UIColor blueColor];
                    return [UIColor colorWithRed:0.0 green:117.0/255.0 blue:225.0/255.0 alpha:1.0];
                case UIControlStateHighlighted:
                    return [UIColor colorWithRed:0.0 green:117.0/255.0 blue:225.0/255.0 alpha:0.2];
                default:
                    return [UIColor blueColor];
            }
        case UIButtonTypeDetailDisclosure:
        case UIButtonTypeInfoLight:
        case UIButtonTypeInfoDark:
        case UIButtonTypeContactAdd:
            return button->_titleLabel.textColor;
        default:
            return button->_titleLabel.textColor;
    }
}

static UIColor *_UIButtonDefaultTitleShadowColor(UIButton *button)
{
    return [UIColor blackColor];
}

static id _UIButtonContentForState(UIButton *button, UIControlState state, NSString *type)
{
    //DLog(@"type: %@", type);
    return [[button->_content objectForKey:type] objectForKey:[NSNumber numberWithInt:state]];
}

static id _UIButtonNormalContentForState(UIButton *button, UIControlState state, NSString *type)
{
    return _UIButtonContentForState(button, state, type) ?: _UIButtonContentForState(button, UIControlStateNormal, type);
}

static void _UIButtonSetContent(UIButton *button, id value, UIControlState state, NSString *type)
{
    //DLog(@"type: %@", type);
    NSMutableDictionary *typeContent = [button->_content objectForKey:type];
    
    //DLog(@"typeContent: %@", typeContent);
    if (!typeContent) {
        typeContent = [[[NSMutableDictionary alloc] init] autorelease];
        [button->_content setObject:typeContent forKey:type];
    }
    NSNumber *key = [NSNumber numberWithInt:state];
    if (value) {
        [typeContent setObject:value forKey:key];
    } else {
        [typeContent removeObjectForKey:key];
    }
    [button _updateContent];

    //_UIButtonUpdateContent(button);
}

static CGSize _UIButtonBackgroundSizeForState(UIButton *button, UIControlState state)
{
    UIImage *backgroundImage = [button backgroundImageForState:state];
    return backgroundImage ? backgroundImage.size : CGSizeZero;
}

static CGSize _UIButtonTitleSizeForState(UIButton *button, UIControlState state)
{
    NSString *title = [button titleForState:state];
    //DLog(@"button: %@", button);
    
    CGSize maxSize = button->_layer->_bounds.size;
    //DLog(@"maxSize: %@", NSStringFromCGSize(maxSize));
    UILabel *titleLabel = button->_titleLabel;
    //DLog(@"titleLabel: %@", titleLabel);
    maxSize.height = titleLabel.font.lineHeight;
    //DLog(@"maxSize: %@", NSStringFromCGSize(maxSize));
    //DLog(@"titleLabel.font: %@", titleLabel.font);
    CGSize resultSize = [title sizeWithFont:titleLabel.font constrainedToSize:maxSize lineBreakMode:titleLabel.lineBreakMode];
    //DLog(@"resultSize: %@", NSStringFromCGSize(resultSize));
    //CGSize result = [title sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(CGFLOAT_MAX,CGFLOAT_MAX)];
    //if (resultSize.width == 0) {
    //    resultSize.width = 10;
    //}
    //DLog(@"resultSize 2: %@", NSStringFromCGSize(resultSize));
    return ([title length] > 0) ? resultSize : CGSizeZero;
}

static CGSize _UIButtonImageSizeForState(UIButton *button, UIControlState state)
{
    UIImage *image = [button imageForState:state];
    return image ? image.size : CGSizeZero;
}

static CGRect _UIButtonComponentRectForSize(UIButton *button, CGSize size, CGRect contentRect, UIControlState state)
{
    CGRect rect;
    
    //DLog(@"contentRect: %@", NSStringFromCGRect(contentRect));
    rect.origin = contentRect.origin;
    rect.size = size;
    
    //DLog(@"rect: %@", NSStringFromCGRect(rect));
    // clamp the right edge of the rect to the contentRect - this is what the real UIButton appears to do.
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(contentRect)) {
        rect.size.width -= CGRectGetMaxX(rect) - CGRectGetMaxX(contentRect);
    }
    switch (button.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentCenter:
            rect.origin.x += floorf((contentRect.size.width/2.f) - (rect.size.width/2.f));
            break;
        case UIControlContentHorizontalAlignmentRight:
            rect.origin.x += contentRect.size.width - rect.size.width;
            break;
        case UIControlContentHorizontalAlignmentFill:
            rect.size.width = contentRect.size.width;
            break;
        case UIControlContentHorizontalAlignmentLeft:
            // don't do anything - it's already left aligned
            break;
    }
    switch (button.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentCenter:
            //DLog(@"rect 2: %@", NSStringFromCGRect(rect));
            rect.origin.y += ceil((contentRect.size.height - rect.size.height) / 2.f);
            //DLog(@"rect 3: %@", NSStringFromCGRect(rect));
            break;
        case UIControlContentVerticalAlignmentBottom:
            rect.origin.y += contentRect.size.height - rect.size.height;
            break;
        case UIControlContentVerticalAlignmentFill:
            rect.size.height = contentRect.size.height;
            break;
        case UIControlContentVerticalAlignmentTop:
            // don't do anything - it's already top aligned
            break;
    }
    return rect;
}

@implementation UIButton

@synthesize buttonType=_buttonType;
@synthesize titleLabel=_titleLabel;
@synthesize reversesTitleShadowWhenHighlighted=_reversesTitleShadowWhenHighlighted;
@synthesize adjustsImageWhenHighlighted=_adjustsImageWhenHighlighted;
@synthesize adjustsImageWhenDisabled=_adjustsImageWhenDisabled;
@synthesize showsTouchWhenHighlighted=_showsTouchWhenHighlighted;
@synthesize imageView=_imageView;
@synthesize contentEdgeInsets=_contentEdgeInsets;
@synthesize titleEdgeInsets=_titleEdgeInsets;
@synthesize imageEdgeInsets=_imageEdgeInsets;

#pragma mark - Life cycle

+ (id)buttonWithType:(UIButtonType)buttonType
{
    UIButton *button = [[[self alloc] initWithFrame:CGRectZero] autorelease];
    button->_buttonType = buttonType;
   // button->_layer.backgroundColor = [[UIColor whiteColor] CGColor];
    /*if (buttonType==UIButtonTypeSystem) {
        button->_layer.borderColor = [[UIColor whiteColor] CGColor];
        button->_layer.borderWidth = 2;
        button->_layer.cornerRadius = 10;
        button->_layer.masksToBounds = YES;
        button->_gradientLayer = [[CAGradientLayer layer] retain];
        button->_gradientLayer.colors = [NSArray arrayWithObjects:(id)[_kStartBlueGradientColor CGColor],
                                                                 (id)[_kMiddleBlueGradientColor CGColor],
                                                                 (id)[_kEndBlueGradientColor CGColor], nil];
        button->_gradientLayer.cornerRadius = 10;
        button->_gradientLayer.borderWidth = 0;
    }*/

   switch (button->_buttonType) {
       case UIButtonTypeCustom:
           button->_titleLabel.textColor = [UIColor whiteColor];
           break;
        case UIButtonTypeSystem:
           button->_titleLabel.textColor = [UIColor blueColor];
           break;
        case UIButtonTypeDetailDisclosure:
        case UIButtonTypeInfoLight:
        case UIButtonTypeInfoDark:
        case UIButtonTypeContactAdd:
            //return [[[UIRoundedRectButton alloc] init] autorelease];
           break;
        default:
        //return [[[self alloc] init] autorelease];
           break;
    }
    return button;
}
 
- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        _buttonType = UIButtonTypeCustom;
        _content = [[NSMutableDictionary alloc] init];
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        //_imageView = [[UIImageView alloc] init];
        _backgroundImageView = [[UIImageView alloc] init];
        _adjustsImageWhenHighlighted = YES;
        _adjustsImageWhenDisabled = YES;
        _showsTouchWhenHighlighted = NO;
        
        self.opaque = NO;
        _titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.shadowOffset = CGSizeZero;
        //DLog(@"[UIFont buttonFontSize]: %0.1f", [UIFont buttonFontSize]);
        _titleLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];

        [self addSubview:_backgroundImageView];
        //[self addSubview:_imageView];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)dealloc
{
    [_content release];
    [_titleLabel release];
    [_imageView release];
    [_backgroundImageView release];
    [_adjustedHighlightImage release];
    [_adjustedDisabledImage release];
    [_gradientLayer release];
    [super dealloc];
}

#pragma mark - Accessors

- (void)setFrame:(CGRect)newFrame
{
    if (!CGRectEqualToRect(newFrame,_layer.frame)) {
        [super setFrame:newFrame];
    }
}

- (NSString *)currentTitle
{
    return _titleLabel.text;
}

- (UIColor *)currentTitleColor
{
    return _titleLabel.textColor;
}

- (UIColor *)currentTitleShadowColor
{
    return _titleLabel.shadowColor;
}

- (UIImage *)currentImage
{
    return _imageView.image;
}

- (UIImage *)currentBackgroundImage
{
    return _backgroundImageView.image;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    if (self.frame.size.width == 0) {
        UIFont *font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
        //CGSize size = [title sizeWithFont:font];
        CGRect frame = self.frame;
        frame.size = [title sizeWithFont:font];
        self.frame = frame;
    }
    _UIButtonSetContent(self, title, state, UIButtonContentTypeTitle);
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    _UIButtonSetContent(self, color, state, UIButtonContentTypeTitleColor);
}

- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state
{
    _UIButtonSetContent(self, color, state, UIButtonContentTypeTitleShadowColor);
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    _UIButtonSetContent(self, image, state, UIButtonContentTypeBackgroundImage);
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [_adjustedHighlightImage release];
    [_adjustedDisabledImage release];
    _adjustedDisabledImage = _adjustedHighlightImage = nil;
    _UIButtonSetContent(self, image, state, UIButtonContentTypeImage);
}

- (NSString *)titleForState:(UIControlState)state
{
    return _UIButtonNormalContentForState(self, state, UIButtonContentTypeTitle);
}

- (UIColor *)titleColorForState:(UIControlState)state
{
    return _UIButtonNormalContentForState(self, state, UIButtonContentTypeTitleColor);
}

- (UIColor *)titleShadowColorForState:(UIControlState)state
{
    return _UIButtonNormalContentForState(self, state, UIButtonContentTypeTitleShadowColor);
}

- (UIImage *)backgroundImageForState:(UIControlState)state
{
    return _UIButtonNormalContentForState(self, state, UIButtonContentTypeBackgroundImage);
}

- (UIImage *)imageForState:(UIControlState)state
{
    return _UIButtonNormalContentForState(self, state, UIButtonContentTypeImage);
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds
{
    return bounds;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds,_contentEdgeInsets);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    //DLog(@"contentRect: %@", NSStringFromCGRect(contentRect));
    const UIControlState state = self.state;
    UIEdgeInsets inset = _titleEdgeInsets;
    CGSize imageSize = _UIButtonImageSizeForState(self, state);
    inset.left += imageSize.width;
    //DLog(@"self: %@", self);
    //DLog(@"_UIButtonTitleSizeForState(self, state): %@", NSStringFromCGSize(_UIButtonTitleSizeForState(self, state)));
    //DLog(@"UIEdgeInsetsInsetRect(contentRect,inset): %@", NSStringFromCGRect(UIEdgeInsetsInsetRect(contentRect,inset)));
    return _UIButtonComponentRectForSize(self, _UIButtonTitleSizeForState(self, state), UIEdgeInsetsInsetRect(contentRect,inset), state);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    //DLog(@"contentRect: %@", NSStringFromCGRect(contentRect));
    const UIControlState state = self.state;
    
    UIEdgeInsets inset = _imageEdgeInsets;
    inset.right += [self titleRectForContentRect:contentRect].size.width;
    
    return _UIButtonComponentRectForSize(self, _UIButtonImageSizeForState(self, state), UIEdgeInsetsInsetRect(contentRect,inset), state);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; frame = %@; title: %@>", [self className], self, NSStringFromCGRect(self.frame), [_content objectForKey:UIButtonContentTypeTitle]];
    //return [NSString stringWithFormat:@"<%@: %p; frame = %@; affineTransform: %@; \ntransform: %@>", [self className], self, NSStringFromCGRect(self.frame), CGAffineTransformDescription(self.transform), CATransform3DDescription(self.layer.transform)];
}

#pragma mark - Overridden methods

- (void)_updateContent
{
    //_UIButtonUpdateContent(self);
    //[super _updateContent];
    UIControlState state = self.state;
    _titleLabel.text = [self titleForState:state];
    _titleLabel.textColor = [self titleColorForState:state] ?: _UIButtonDefaultTitleColor(self, state);
    _titleLabel.shadowColor = [self titleShadowColorForState:state] ?: _UIButtonDefaultTitleShadowColor(self);
    
    UIImage *image = _UIButtonContentForState(self, state, UIButtonContentTypeImage);
    UIImage *backgroundImage = _UIButtonContentForState(self, state, UIButtonContentTypeBackgroundImage);
    if (!image) {
        image = [self imageForState:state];	// find the correct default image to show
        if (_adjustsImageWhenDisabled && state & UIControlStateDisabled) {
            _UIImageViewSetDrawMode(_imageView, _UIImageViewDrawModeDisabled);
        } else if (_adjustsImageWhenHighlighted && state & UIControlStateHighlighted) {
            _UIImageViewSetDrawMode(_imageView, _UIImageViewDrawModeHighlighted);
        } else {
            _UIImageViewSetDrawMode(_imageView, _UIImageViewDrawModeNormal);
        }
    } else {
        _UIImageViewSetDrawMode(_imageView, _UIImageViewDrawModeNormal);
    }
    if (!backgroundImage) {
        backgroundImage = [self backgroundImageForState:state];
        if (_adjustsImageWhenDisabled && state & UIControlStateDisabled) {
            _UIImageViewSetDrawMode(_backgroundImageView, _UIImageViewDrawModeDisabled);
        } else if (_adjustsImageWhenHighlighted && state & UIControlStateHighlighted) {
            _UIImageViewSetDrawMode(_backgroundImageView, _UIImageViewDrawModeHighlighted);
        } else {
            _UIImageViewSetDrawMode(_backgroundImageView, _UIImageViewDrawModeNormal);
        }
    } else {
        _UIImageViewSetDrawMode(_backgroundImageView, _UIImageViewDrawModeNormal);
    }
    //DLog(@"backgroundImage: %@", backgroundImage); 
    _imageView.image = image;
    _backgroundImageView.image = backgroundImage;
    if (_highlighted) {
        DLog(@"[_registeredActions count]: %d", [_registeredActions count]);
        //if ([_registeredActions count]==0) {
        //_gradientLayer.frame = button.bounds;
        //[_layer insertSublayer:_gradientLayer atIndex:0];
        //}
    } else {
        //if ([_registeredActions count]==0) {
        //[_gradientLayer removeFromSuperlayer];
        //}
    }
    //[self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
   
    const CGRect bounds = self.bounds;
    _gradientLayer.frame = self.bounds;
    const CGRect contentRect = [self contentRectForBounds:bounds];

    _backgroundImageView.frame = [self backgroundRectForBounds:bounds];
    //DLog(@"contentRect: %@", NSStringFromCGRect(contentRect));
    _titleLabel.frame = [self titleRectForContentRect:contentRect];
    //DLog(@"_titleLabel: %@", _titleLabel);
    _imageView.frame = [self imageRectForContentRect:contentRect];
}

#pragma mark - Public methods

- (CGSize)sizeThatFits:(CGSize)size
{
    const UIControlState state = self.state;
    
    const CGSize imageSize = _UIButtonImageSizeForState(self, state);
    const CGSize titleSize = _UIButtonTitleSizeForState(self, state);
    
    CGSize fitSize;
    fitSize.width = _contentEdgeInsets.left + _contentEdgeInsets.right + titleSize.width + imageSize.width;
    fitSize.height = _contentEdgeInsets.top + _contentEdgeInsets.bottom + MAX(titleSize.height,imageSize.height);
    
    UIImage *background = [self currentBackgroundImage];
    if (background) {
        CGSize backgroundSize = background.size;
        fitSize.width = MAX(fitSize.width, backgroundSize.width);
        fitSize.height = MAX(fitSize.height, backgroundSize.height);
    }
    //DLog(@"fitSize: %@", NSStringFromCGSize(fitSize));
    return fitSize;
}

@end

