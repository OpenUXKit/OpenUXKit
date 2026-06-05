#import <AppKit/AppKit.h>

@class NSColor;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UXTintAdjustmentMode) {
    UXTintAdjustmentModeAutomatic,
    UXTintAdjustmentModeNormal,
    UXTintAdjustmentModeDimmed,
};

@protocol UXKitAppearance <NSObject>
@property (nonatomic) UXTintAdjustmentMode tintAdjustmentMode;
@property (nonatomic, strong, nullable) NSColor *tintColor;
- (void)tintColorDidChange;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
