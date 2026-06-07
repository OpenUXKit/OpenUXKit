#import <AppKit/AppKit.h>

@class NSColor;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

/// `UXKitAppearance` and its companion `UXTintAdjustmentMode` were modelled
/// after the macOS 11.0 vintage of the private `UXKit.framework`. Apple has
/// since removed the protocol from the framework, so these declarations are
/// preserved purely for source compatibility with code that targets the older
/// header layout. New OpenUXKit code should style controls using
/// `NSAppearance`, asset catalog colors, and the per-class tint APIs (e.g.
/// `UXImageView.tintColor`) instead.

typedef NS_ENUM(NSInteger, UXTintAdjustmentMode) {
    UXTintAdjustmentModeAutomatic = 0,
    UXTintAdjustmentModeNormal = 1,
    UXTintAdjustmentModeDimmed = 2,
} API_DEPRECATED("UXKitAppearance has been removed from modern UXKit. Style controls via NSAppearance or per-class tint APIs.", macos(11.0, 11.0));

API_DEPRECATED("UXKitAppearance has been removed from modern UXKit. Style controls via NSAppearance or per-class tint APIs.", macos(11.0, 11.0))
@protocol UXKitAppearance <NSObject>
@property (nonatomic) UXTintAdjustmentMode tintAdjustmentMode;
@property (nonatomic, strong, nullable) NSColor *tintColor;
- (void)tintColorDidChange;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
