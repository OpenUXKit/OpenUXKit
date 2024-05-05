#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitAppearance.h>

@interface NSWindow (UXKit) <UXKitAppearance>

@property (nonatomic, setter = ux_setToolbarHiddenInFullScreen:) BOOL ux_toolbarHiddenInFullScreen;
@property (nonatomic, readonly) BOOL ux_inFullScreen;
@property (nonatomic, strong) NSColor *tintColor;
@property (nonatomic) UXTintAdjustmentMode tintAdjustmentMode;
- (void)tintColorDidChange;
- (void)ux_forceEnableStandardWindowButton:(NSWindowButton)windowButton;

@end
