#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitAppearance.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NSWindow (UXKit) <UXKitAppearance>

@property (nonatomic, setter = ux_setToolbarHiddenInFullScreen:) BOOL ux_toolbarHiddenInFullScreen;
@property (nonatomic, readonly) BOOL ux_inFullScreen;
- (void)ux_forceEnableStandardWindowButton:(NSWindowButton)windowButton;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
