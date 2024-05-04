#import <AppKit/AppKit.h>

@class NSColor;

typedef NS_ENUM(NSInteger, UXTintAdjustmentMode) {
    UXTintAdjustmentModeAutomatic,
    UXTintAdjustmentModeNormal,
    UXTintAdjustmentModeDimmed,
};

@protocol UXKitAppearance <NSObject>
@property (nonatomic) UXTintAdjustmentMode tintAdjustmentMode;
@property (nonatomic, strong) NSColor *tintColor;
- (void)tintColorDidChange;
@end
