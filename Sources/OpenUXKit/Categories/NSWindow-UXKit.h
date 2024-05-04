#import <AppKit/NSWindow.h>
#import <OpenUXKit/UXKitAppearance.h>

@class NSColor, NSString;

@interface NSWindow (UXKit) <UXKitAppearance>
@property(nonatomic, setter=ux_setToolbarHiddenInFullScreen:) BOOL ux_toolbarHiddenInFullScreen;
@property(readonly, nonatomic) BOOL ux_inFullScreen;
- (void)tintColorDidChange;
@property(nonatomic) NSInteger tintAdjustmentMode;
@property(strong, nonatomic) NSColor *tintColor;
- (void)ux_forceEnableStandardWindowButton:(NSWindowButton)windowButton;
@end

