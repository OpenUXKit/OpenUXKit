#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitAppearance.h>

@class NSColor, NSString;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXLayoutConstraintAxis) {
    UXLayoutConstraintAxisHorizontal = 0,
    UXLayoutConstraintAxisVertical   = 1
};

@interface NSView (UXKit) <UXKitAppearance>

@property (nonatomic) CGFloat alpha;
@property (copy, nullable) NSColor *backgroundColor;

- (CGFloat)ux_backingScaleFactor;
- (nullable id)enclosingViewOfClass:(Class)cls;
- (void)tintColorDidChange;
- (void)setContentCompressionResistancePriority:(NSLayoutPriority)priority forAxis:(UXLayoutConstraintAxis)axis NS_SWIFT_UNAVAILABLE("use AppKit setContentCompressionResistancePriority(_:for:) instead");
- (NSLayoutPriority)contentCompressionResistancePriorityForAxis:(UXLayoutConstraintAxis)axis NS_SWIFT_UNAVAILABLE("use AppKit contentCompressionResistancePriority(for:) instead");
- (void)setContentHuggingPriority:(NSLayoutPriority)priority forAxis:(UXLayoutConstraintAxis)axis NS_SWIFT_UNAVAILABLE("use AppKit setContentHuggingPriority(_:for:) instead");
- (NSLayoutPriority)contentHuggingPriorityForAxis:(UXLayoutConstraintAxis)axis NS_SWIFT_UNAVAILABLE("use AppKit contentHuggingPriority(for:) instead");
- (BOOL)pointInside:(CGPoint)point withEvent:(NSEvent *)event;
- (void)layoutIfNeeded;
- (void)layoutSubviews;
- (void)setNeedsUpdateConstraints;
- (void)updateConstraintsIfNeeded;
- (void)setNeedsDisplay;
- (void)setNeedsLayout;
- (void)didMoveToWindow;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
