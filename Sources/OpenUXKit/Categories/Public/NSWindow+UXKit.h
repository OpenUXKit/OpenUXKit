#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitAppearance.h>

@interface NSWindow (UXKit) <UXKitAppearance>

@property (nonatomic, setter = ux_setToolbarHiddenInFullScreen:) BOOL ux_toolbarHiddenInFullScreen;
@property (nonatomic, readonly) BOOL ux_inFullScreen;
@property (nonatomic, readonly, nullable) NSView *ux_clickedControl;
- (void)ux_forceEnableStandardWindowButton:(NSWindowButton)windowButton;

@end
