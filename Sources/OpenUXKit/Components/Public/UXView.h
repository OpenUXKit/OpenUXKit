#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXUserInterfaceLayoutDirection) {
    UXUserInterfaceLayoutDirectionLeftToRight = 0,
    UXUserInterfaceLayoutDirectionRightToLeft = 1,
};

typedef NS_ENUM(NSInteger, UXViewAnimationCurve) {
    UXViewAnimationCurveEaseInOut = 0,     // slow at beginning and end
    UXViewAnimationCurveEaseIn    = 1,     // slow at beginning
    UXViewAnimationCurveEaseOut   = 2,     // slow at end
    UXViewAnimationCurveLinear    = 3,
} NS_SWIFT_NAME(UXView.AnimationCurve);

typedef NS_OPTIONS(NSUInteger, UXViewAnimationOptions) {
    UXViewAnimationOptionCurveEaseInOut = 0 << 16, // default
    UXViewAnimationOptionCurveEaseIn    = 1 << 16,
    UXViewAnimationOptionCurveEaseOut   = 2 << 16,
    UXViewAnimationOptionCurveLinear    = 3 << 16,
} NS_SWIFT_NAME(UXView.AnimationOptions);

typedef NS_ENUM(NSInteger, UXViewContentMode) {
    UXViewContentModeScaleToFill     = 0,
    UXViewContentModeScaleAspectFit  = 1,  // contents scaled to fit with fixed aspect. remainder is transparent
    UXViewContentModeScaleAspectFill = 2,  // contents scaled to fill with fixed aspect. some portion of content may be clipped.
    UXViewContentModeRedraw          = 3,  // redraw on bounds change (calls -setNeedsDisplay)
    UXViewContentModeCenter          = 4,  // contents remain same size. positioned adjusted.
    UXViewContentModeTop             = 5,
    UXViewContentModeBottom          = 6,
    UXViewContentModeLeft            = 7,
    UXViewContentModeRight           = 8,
    UXViewContentModeTopLeft         = 9,
    UXViewContentModeTopRight        = 10,
    UXViewContentModeBottomLeft      = 11,
    UXViewContentModeBottomRight     = 12,
} NS_SWIFT_NAME(UXView.ContentMode);

@class UXViewController, UXImageView;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXView : NSView
@property (nonatomic, class, readonly) Class layerClass;
@property (nonatomic) BOOL userInteractionEnabled;
@property (nonatomic, getter = isExclusiveTouch) BOOL exclusiveTouch;
@property (nonatomic, strong, nullable) NSColor *borderColor;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) NSUserInterfaceLayoutDirection effectiveUserInterfaceLayoutDirection;
@property (nonatomic) UXViewContentMode contentMode;
@property (nonatomic) BOOL blurEnabled;
@property (nonatomic) NSVisualEffectMaterial blurMaterial;
@property (nonatomic, strong, nullable) NSColor *backgroundColor;

+ (void)performWithoutAnimation:(void (NS_NOESCAPE ^)(void))actionsWithoutAnimation;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion NS_SWIFT_DISABLE_ASYNC;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations NS_SWIFT_DISABLE_ASYNC;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion NS_SWIFT_DISABLE_ASYNC;
+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UXViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion NS_SWIFT_DISABLE_ASYNC;

- (void)updateConstraintsForSubtreeIfNeeded;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)insertSubview:(NSView *)insertSubview aboveSubview:(NSView *)aboveSubview;
- (void)insertSubview:(NSView *)insertSubview belowSubview:(NSView *)belowSubview;
- (void)bringSubviewToFront:(NSView *)subview NS_SWIFT_NAME(bringSubviewToFront(_:));
- (void)sendSubviewToBack:(NSView *)subview NS_SWIFT_NAME(sendSubviewToBack(_:));
- (nullable UXImageView *)snapshotViewFromRect:(CGRect)rect;
- (nullable UXImageView *)snapshotView;
- (nullable NSImage *)snapshotForRect:(CGRect)rect;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
