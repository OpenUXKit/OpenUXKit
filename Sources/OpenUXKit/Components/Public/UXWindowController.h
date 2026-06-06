#import <AppKit/AppKit.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXToolbar, UXViewController, UXNavigationController;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXWindowController : NSWindowController <NSToolbarDelegate, NSWindowDelegate>

@property (nonatomic, strong, nullable) UXViewController *rootViewController;
@property (nonatomic, readonly, nullable) NSTitlebarAccessoryViewController *titlebarAccessoryViewController;
@property (nonatomic, readonly, nullable) UXNavigationController *rootNavigationController;

- (instancetype)initWithRootViewController:(UXViewController *)rootViewController;
- (instancetype)initWithWindow:(nullable NSWindow *)window;

- (void)teardownViewControllerHierarchy;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
