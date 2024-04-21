#import <AppKit/AppKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXUserInterfaceLayoutDirection) {
    UXUserInterfaceLayoutDirectionLeftToRight,
    UXUserInterfaceLayoutDirectionRightToLeft,
};

typedef NS_OPTIONS(NSUInteger, UXViewAnimationOptions) {
    UXViewAnimationOptionLayoutSubviews                  = 1 <<  0,
    UXViewAnimationOptionAllowUserInteraction            = 1 <<  1,// turn on user interaction while animating
    UXViewAnimationOptionBeginFromCurrentState           = 1 <<  2,// start all views from current value, not initial value
    UXViewAnimationOptionRepeat                          = 1 <<  3,// repeat animation indefinitely
    UXViewAnimationOptionAutoreverse                     = 1 <<  4,// if repeat, run animation back and forth
    UXViewAnimationOptionOverrideInheritedDuration       = 1 <<  5,// ignore nested duration
    UXViewAnimationOptionOverrideInheritedCurve          = 1 <<  6,// ignore nested curve
    UXViewAnimationOptionAllowAnimatedContent            = 1 <<  7,// animate contents (applies to transitions only)
    UXViewAnimationOptionShowHideTransitionViews         = 1 <<  8,// flip to/from hidden state instead of adding/removing
    UXViewAnimationOptionOverrideInheritedOptions        = 1 <<  9,// do not inherit any options or animation type

    UXViewAnimationOptionCurveEaseInOut                  = 0 << 16, // default
    UXViewAnimationOptionCurveEaseIn                     = 1 << 16,
    UXViewAnimationOptionCurveEaseOut                    = 2 << 16,
    UXViewAnimationOptionCurveLinear                     = 3 << 16,

    UXViewAnimationOptionTransitionNone                  = 0 << 20, // default
    UXViewAnimationOptionTransitionFlipFromLeft          = 1 << 20,
    UXViewAnimationOptionTransitionFlipFromRight         = 2 << 20,
    UXViewAnimationOptionTransitionCurlUp                = 3 << 20,
    UXViewAnimationOptionTransitionCurlDown              = 4 << 20,
    UXViewAnimationOptionTransitionCrossDissolve         = 5 << 20,
    UXViewAnimationOptionTransitionFlipFromTop           = 6 << 20,
    UXViewAnimationOptionTransitionFlipFromBottom        = 7 << 20,

    UXViewAnimationOptionPreferredFramesPerSecondDefault = 0 << 24,
    UXViewAnimationOptionPreferredFramesPerSecond60      = 3 << 24,
    UXViewAnimationOptionPreferredFramesPerSecond30      = 7 << 24,
};

typedef NS_ENUM(NSInteger, UXViewContentMode) {
    UXViewContentModeScaleToFill,
    UXViewContentModeScaleAspectFit,      // contents scaled to fit with fixed aspect. remainder is transparent
    UXViewContentModeScaleAspectFill,     // contents scaled to fill with fixed aspect. some portion of content may be clipped.
    UXViewContentModeRedraw,              // redraw on bounds change (calls -setNeedsDisplay)
    UXViewContentModeCenter,              // contents remain same size. positioned adjusted.
    UXViewContentModeTop,
    UXViewContentModeBottom,
    UXViewContentModeLeft,
    UXViewContentModeRight,
    UXViewContentModeTopLeft,
    UXViewContentModeTopRight,
    UXViewContentModeBottomLeft,
    UXViewContentModeBottomRight,
};

@class NSColor, NSVisualEffectView, UXViewController, UXImageView;

@interface UXView : NSView
@property (nonatomic) BOOL accessibilityChildrenHidden;
@property (readonly) NSVisualEffectView *_visualEffectsView;
@property (nonatomic, weak, nullable) UXViewController *viewControllerProxy;
@property (nonatomic) BOOL needsContentBackgroundVisualEffect;
@property (strong, nonatomic) NSColor *borderColor;
@property (nonatomic) BOOL userInteractionEnabled;
@property (nonatomic, getter = isExclusiveTouch) BOOL exclusiveTouch;
@property (nonatomic) CGAffineTransform transform;
@property (readonly, nonatomic) CGPoint center;
@property (readonly, nonatomic) UXUserInterfaceLayoutDirection effectiveUserInterfaceLayoutDirection;
@property (nonatomic) UXViewContentMode contentMode;
@property (nonatomic) BOOL blurEnabled;
@property (nonatomic) NSVisualEffectMaterial blurMaterial;
+ (void)performWithoutAnimation:(void (NS_NOESCAPE ^)(void))actionsWithoutAnimation;

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion NS_SWIFT_DISABLE_ASYNC;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations NS_SWIFT_DISABLE_ASYNC;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion NS_SWIFT_DISABLE_ASYNC;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion NS_SWIFT_DISABLE_ASYNC;

+ (Class)layerClass;
- (void)updateConstraintsForSubtreeIfNeeded;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)setBackgroundColor:(NSColor *)backgroundColor;
- (UXImageView *)snapshotViewFromRect:(CGRect)rect;
- (UXImageView *)snapshotView;
- (NSImage *)snapshotForRect:(CGRect)rect;
- (void)insertSubview:(NSView *)insertSubview aboveSubview:(NSView *)aboveSubview;
- (void)insertSubview:(NSView *)insertSubview belowSubview:(NSView *)belowSubview;
- (void)bringSubviewToFront:(NSView *)subview;
- (void)sendSubviewToBack:(NSView *)subview;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
