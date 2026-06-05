#import <OpenUXKit/UXWindowController.h>

@class UXNavigationItem, UXToolbar, UXWindowToolbarController;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN void *UXWindowControllerContentLayoutRectContext;
UXKIT_EXTERN void *UXWindowControllerToolbarNavigationItemContext;

@interface UXWindowController () {
    UXToolbar *_currentAccessoryToolbar;
    UXWindowToolbarController *_toolbarController;
    UXNavigationItem *_toolbarNavigationItem;
    NSTitlebarAccessoryViewController *_titlebarAccessoryViewController;
}

@property (nonatomic, weak, nullable) NSToolbarItem *navigationBarToolbarItem;
@property (nonatomic, strong, nullable) UXNavigationItem *toolbarNavigationItem;

+ (nullable NSWindow *)defaultWindow;

- (void)_updateFirstResponder;
- (void)_updateAccessoryBar;
- (void)_updateToolbar;
- (void)_updateToolbarItems;
- (void)_updateToolbarNavigationItem;
- (void)_updateNavigationBarToolbarItem;
- (void)_updateWindowTitles;
- (void)_setupAccessoryBar;
- (void)_setupNavigationBarToolbarItem;
- (BOOL)_shouldUseToolbarViewForCentering;
- (CGFloat)_accessoryBarHeight;
- (void)_setAccessoryBarHidden:(BOOL)hidden;
- (void)_tearDownViewControllerHierarchyForViewController:(UXViewController *)viewController;

- (void)windowDidBecomeFirstResponder:(NSNotification *)notification;
- (void)windowDidRecalculateKeyViewLoop:(NSNotification *)notification;
- (void)windowWillRecalculateKeyViewLoop:(NSNotification *)notification;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
