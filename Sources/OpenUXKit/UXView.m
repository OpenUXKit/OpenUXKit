#import "UXView.h"
#import "NSView-UXKit.h"
#import "UXViewController.h"
#import "UXImageView.h"
#import "UXViewAnimationContext.h"
#import <QuartzCore/QuartzCore.h>

@interface CASpringAnimation (PrivateSPI)
@property CGFloat velocity;
@end

@interface NSView (PrivateSPI)
- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event;
- (void)setBackgroundColor:(NSColor *)backgroundColor;
- (void)setFrameTransform:(CGAffineTransform)transform;
- (CGAffineTransform)frameTransform;
@end


@interface UXView ()
{
    BOOL _blurEnabled;    // 108 = 0x6c
    NSColor *_backgroundColor;    // 112 = 0x70
    NSColor *_borderColor;    // 120 = 0x78
    NSVisualEffectView *_contentBackgroundVisualEffectsView;    // 128 = 0x80
    BOOL _opaque;    // 136 = 0x88
    BOOL _exclusiveTouch;    // 137 = 0x89
    BOOL _userInteractionEnabled;    // 138 = 0x8a
    BOOL _needsContentBackgroundVisualEffect;    // 139 = 0x8b
    BOOL _accessibilityChildrenHidden;    // 140 = 0x8c
    __weak UXViewController *_viewControllerProxy;    // 144 = 0x90
    NSVisualEffectView *__visualEffectsView;    // 152 = 0x98
}
@end

@implementation UXView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        commonInit(self);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        commonInit(self);
    }
    return self;
}

void commonInit(UXView *view) {
    view.wantsLayer = YES;
    view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    [view setContentCompressionResistancePriority:NSLayoutPriorityWindowSizeStayPut forOrientation:(NSLayoutConstraintOrientationHorizontal)];
    [view setContentCompressionResistancePriority:NSLayoutPriorityWindowSizeStayPut forOrientation:(NSLayoutConstraintOrientationVertical)];
    view.userInteractionEnabled = YES;
}

- (CALayer *)makeBackingLayer {
    Class layerClass = [[self class] layerClass];
    if (layerClass) {
        return [[layerClass alloc] init];
    } else {
        return [super makeBackingLayer];
    }
}

+ (Class)layerClass {
    return nil;
}

- (BOOL)wantsUpdateLayer {
    return YES;
}

- (void)addSubview:(NSView *)view {
    [self _applyTintColorIfNotUXView:view];
    [super addSubview:view];
}

- (void)_applyTintColorIfNotUXView:(NSView *)view {
    if (![view isKindOfClass:[UXView class]] && [view respondsToSelector:@selector(setTintColor:)]) {
        view.tintColor = self.tintColor;
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (backgroundColor != nil && self.wantsLayer) {
        self.wantsLayer = YES;
    }
    _backgroundColor = backgroundColor;
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
   CASpringAnimation *animation = [CATransaction valueForKey:@"__uxview_spring_animation"];
    if (animation) {
        return [[self class] defaultSpringAnimationForKey:event mass:animation.mass stiffness:animation.stiffness damping:animation.damping velocity:animation.velocity];
    } else {
        return [super actionForLayer:layer forKey:event];
    }
}

- (void)setBlurEnabled:(BOOL)blurEnabled {
    _blurEnabled = blurEnabled;
    if (blurEnabled) {
        [self _enableBlur];
    } else {
        [self _disableBlur];
    }
}

- (void)_enableBlur {
    if (__visualEffectsView == nil) {
        [self setBackgroundColor:NSColor.clearColor];
        __visualEffectsView = [[NSVisualEffectView alloc] initWithFrame:CGRectZero];
        __visualEffectsView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
        __visualEffectsView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        __visualEffectsView.frame = self.bounds;
        [self addSubview:__visualEffectsView positioned:NSWindowBelow relativeTo:nil];
    }
}

- (void)addSubview:(NSView *)view positioned:(NSWindowOrderingMode)place relativeTo:(NSView *)otherView {
    [self _applyTintColorIfNotUXView:view];
    [super addSubview:view positioned:place relativeTo:otherView];
}

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    [super viewWillMoveToSuperview:newSuperview];
    
    if (newSuperview && [newSuperview respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = newSuperview.tintColor;
    }
}

- (void)_disableBlur {
    [__visualEffectsView removeFromSuperview];
    __visualEffectsView = nil;
}

- (void)updateConstraintsForSubtreeIfNeeded {
    [self.viewControllerProxy updateViewConstraints];
    [super updateConstraintsForSubtreeIfNeeded];
}

- (void)layout {
    [self.viewControllerProxy viewWillLayoutSubviews];
    [super layout];
    [self layoutSubviews];
    [super layout];
    [self _updateContentBackgroundVisualEffectsView];
    [self.viewControllerProxy viewDidLayoutSubviews];
}

- (void)_updateContentBackgroundVisualEffectsView {
    
    if (_contentBackgroundVisualEffectsView) {
        [self removeContentBackgroundVisualEffectIfNeeded];
    } else {
        if (self.needsContentBackgroundVisualEffect) {
            _contentBackgroundVisualEffectsView = [self _makeContentBackgroundVisualEffectsView];
            [self addSubview:_contentBackgroundVisualEffectsView positioned:NSWindowBelow relativeTo:nil];
        } else {
            [self removeContentBackgroundVisualEffectIfNeeded];
        }
    }
}

- (void)removeContentBackgroundVisualEffectIfNeeded {
    if (!self.needsContentBackgroundVisualEffect) {
        [_contentBackgroundVisualEffectsView removeFromSuperview];
        _contentBackgroundVisualEffectsView = nil;
    }
}


- (void)updateLayer {
    [super updateLayer];
    [self.viewControllerProxy viewUpdateLayer];
    [super setBackgroundColor:_backgroundColor];
    NSColor *borderColor = self.borderColor;
    if (borderColor) {
        self.borderColor = borderColor;
    }
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    if (duration > 0.0) {
        CAMediaTimingFunctionName funtionName = kCAMediaTimingFunctionEaseInEaseOut;
        if (options & UXViewAnimationOptionCurveEaseIn) {
            funtionName = kCAMediaTimingFunctionEaseIn;
        } else if (options & UXViewAnimationOptionCurveEaseOut) {
            funtionName = kCAMediaTimingFunctionEaseOut;
        } else if (options & UXViewAnimationOptionCurveLinear) {
            funtionName = kCAMediaTimingFunctionLinear;
        }
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = duration;
            context.timingFunction = [CAMediaTimingFunction functionWithName:funtionName];
            if (animations) {
                animations();
            }
        } completionHandler:^{
            if (completion) {
                completion(YES);
            }
        }];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

- (NSView *)hitTest:(NSPoint)point {
    if (self.userInteractionEnabled) {
        return [super hitTest:point];
    } else {
        return nil;
    }
}

- (void)setNeedsContentBackgroundVisualEffect:(BOOL)needsContentBackgroundVisualEffect {
    _needsContentBackgroundVisualEffect = needsContentBackgroundVisualEffect;
    self.needsLayout = YES;
}

- (NSVisualEffectView *)_makeContentBackgroundVisualEffectsView {
    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.bounds];
    visualEffectView.blendingMode = NSVisualEffectBlendingModeWithinWindow;
    visualEffectView.material = NSVisualEffectMaterialContentBackground;
    visualEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    return visualEffectView;
}

- (void)setBorderColor:(NSColor *)borderColor {
    if (borderColor && !self.wantsLayer) {
        self.wantsLayer = YES;
    }
    self.layer.borderColor = borderColor.CGColor;
    _borderColor = borderColor;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return self.bounds.size;
}

- (void)viewWillStartLiveResize {
    [self.viewControllerProxy viewWillLiveResize];
}

- (void)viewDidEndLiveResize {
    [self.viewControllerProxy viewWillLiveResize];
}

- (void)insertSubview:(NSView *)insertSubview aboveSubview:(NSView *)aboveSubview {
    [self addSubview:insertSubview positioned:NSWindowAbove relativeTo:aboveSubview];
}

- (void)insertSubview:(NSView *)insertSubview belowSubview:(NSView *)belowSubview {
    [self addSubview:insertSubview positioned:NSWindowBelow relativeTo:belowSubview];
}

- (void)setContentMode:(UXViewContentMode)contentMode {
    CALayerContentsGravity contentGravity = kCAGravityResize;
    switch (contentMode) {
        case UXViewContentModeScaleAspectFit:
            contentGravity = kCAGravityResizeAspect;
            break;
        case UXViewContentModeScaleAspectFill:
            contentGravity = kCAGravityResizeAspectFill;
            break;
        case UXViewContentModeRedraw:
            self.layer.needsDisplayOnBoundsChange = YES;
            return;
        case UXViewContentModeCenter:
            contentGravity = kCAGravityCenter;
            break;
        case UXViewContentModeTop:
            contentGravity = kCAGravityTop;
            break;
        case UXViewContentModeBottom:
            contentGravity = kCAGravityBottom;
            break;
        case UXViewContentModeLeft:
            contentGravity = kCAGravityLeft;
            break;
        case UXViewContentModeRight:
            contentGravity = kCAGravityRight;
            break;
        case UXViewContentModeTopLeft:
            contentGravity = kCAGravityTopLeft;
            break;
        case UXViewContentModeTopRight:
            contentGravity = kCAGravityTopRight;
            break;
        case UXViewContentModeBottomLeft:
            contentGravity = kCAGravityBottomLeft;
            break;
        case UXViewContentModeBottomRight:
            contentGravity = kCAGravityBottomRight;
            break;
        default:
            break;
    }
    
    self.layer.contentsGravity = contentGravity;
}

- (UXViewContentMode)contentMode {
    if (self.layer.needsDisplayOnBoundsChange) {
        return UXViewContentModeRedraw;
    } else {
        return [UXView _contentModeForLayerContentsGravity:self.layer.contentsGravity];
    }
}

+ (UXViewContentMode)_contentModeForLayerContentsGravity:(CALayerContentsGravity)contentsGravity {
    static dispatch_once_t onceToken;
    static NSDictionary *contentModeDictionary = nil;
    dispatch_once(&onceToken, ^{
        contentModeDictionary = @{
            kCAGravityCenter: @(UXViewContentModeCenter),
            kCAGravityTop: @(UXViewContentModeTop),
            kCAGravityBottom: @(UXViewContentModeBottom),
            kCAGravityLeft: @(UXViewContentModeLeft),
            kCAGravityRight: @(UXViewContentModeRight),
            kCAGravityTopLeft: @(UXViewContentModeTopLeft),
            kCAGravityTopRight: @(UXViewContentModeTopRight),
            kCAGravityBottomLeft: @(UXViewContentModeBottomLeft),
            kCAGravityBottomRight: @(UXViewContentModeBottomRight),
            kCAGravityResize: @(UXViewContentModeScaleToFill),
            kCAGravityResizeAspect: @(UXViewContentModeScaleAspectFit),
            kCAGravityResizeAspectFill: @(UXViewContentModeScaleAspectFill),
        };
    });
    return [contentModeDictionary[contentsGravity] integerValue];
}

- (CGPoint)center {
    return CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
}

- (void)setTransform:(CGAffineTransform)transform {
    self.frameTransform = transform;
}

- (CGAffineTransform)transform {
    return self.frameTransform;
}

- (void)bringSubviewToFront:(NSView *)subview {
    [self addSubview:subview positioned:NSWindowAbove relativeTo:nil];
}

- (void)sendSubviewToBack:(NSView *)subview {
    [self addSubview:subview positioned:NSWindowBelow relativeTo:nil];
}

- (NSImage *)snapshotForRect:(CGRect)rect {
    NSBitmapImageRep *bitmapImageRep = [self bitmapImageRepForCachingDisplayInRect:rect];
    [self cacheDisplayInRect:rect toBitmapImageRep:bitmapImageRep];
    NSImage *snapshot = [[NSImage alloc] initWithSize:bitmapImageRep.size];
    [snapshot addRepresentation:bitmapImageRep];
    return snapshot;
}

- (UXImageView *)snapshotView {
    return [self snapshotViewFromRect:self.bounds];
}

- (UXImageView *)snapshotViewFromRect:(CGRect)rect {
    NSImage *snapshot = [self snapshotForRect:rect];
    UXImageView *snapshotView = [[UXImageView alloc] initWithImage:snapshot];
    return snapshotView;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    return [self.viewControllerProxy menuForEvent:event];
}

- (NSArray *)accessibilityChildren {
    if (self.accessibilityChildrenHidden) {
        return nil;
    } else {
        return [super accessibilityChildren];
    }
}

+ (CASpringAnimation *)defaultSpringAnimationForKey:(NSString *)key mass:(CGFloat)mass stiffness:(CGFloat)stiffness damping:(CGFloat)damping velocity:(CGFloat)velocity {
    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:key];
    springAnimation.mass = mass;
    springAnimation.stiffness = stiffness;
    springAnimation.damping = damping;
    springAnimation.initialVelocity = velocity;
    return springAnimation;
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    [self animateWithDuration:duration delay:0.0 options:0 animations:animations completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    [self animateWithDuration:duration delay:0.0 options:0 animations:animations completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    UXViewAnimationContext *context = [UXViewAnimationContext new];
    [context generateSpringPropertiesForDuration:duration damping:dampingRatio velocity:velocity];
    [CATransaction setValue:context forKey:@"__uxview_spring_animation"];
    [self animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
}

+ (void)performWithoutAnimation:(void (NS_NOESCAPE ^)(void))actionsWithoutAnimation {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = NO;
        context.duration = 0.0;
        if (actionsWithoutAnimation) {
            actionsWithoutAnimation();
        }
    }];
}

+ (void)_animateUsingDefaultTimingWithOptions:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    [self animateWithDuration:0.33 delay:0.0 usingSpringWithDamping:500.0 initialSpringVelocity:0.0 options:options animations:animations completion:completion];
}


- (void)setBlurMaterial:(NSVisualEffectMaterial)blurMaterial {
    _blurMaterial = blurMaterial;
    __visualEffectsView.material = blurMaterial;
}

@end
