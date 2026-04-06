#import <AppKit/AppKit.h>
#import <OpenUXKit/_UXAccessoryBarContainer-Protocol.h>
#import <OpenUXKit/UXKitDefines.h>

@class UXToolbar, UXNavigationItem;

@protocol UXViewController;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXWindowController : NSWindowController <NSToolbarDelegate, _UXAccessoryBarContainer, NSWindowDelegate>


+ (id)defaultWindow;

@property (nonatomic, weak) NSToolbarItem *navigationBarToolbarItem;
@property (nonatomic, strong) UXNavigationItem *toolbarNavigationItem;
@property (nonatomic, strong) NSViewController<UXViewController> *rootViewController;
@property (nonatomic, readonly) NSTitlebarAccessoryViewController *titlebarAccessoryViewController;

- (id)initWithRootViewController:(id)arg1;
- (id)rootNavigationController;
- (void)windowDidBecomeFirstResponder:(id)arg1;
- (void)windowDidRecalculateKeyViewLoop:(id)arg1;
- (void)windowWillRecalculateKeyViewLoop:(id)arg1;
- (void)windowWillExitFullScreen:(id)arg1;
- (void)windowWillEnterFullScreen:(id)arg1;
- (void)windowDidChangeTitle:(id)arg1;
- (void)windowDidChangeSubtitle:(id)arg1;
- (CGRect)window:(id)arg1 willPositionSheet:(id)arg2 usingRect:(CGRect)arg3;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)_updateFirstResponder;
- (void)_updateAccessoryBar;
- (void)_updateToolbar;
- (void)_updateToolbarItems;
- (void)_updateNavigationBarToolbarItem;
- (void)_updateToolbarNavigationItem;
- (void)_updateWindowTitles;
- (BOOL)_shouldUseToolbarViewForCentering;
- (void)_setupAccessoryBar;
- (void)_setupNavigationBarToolbarItem;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (void)_tearDownViewControllerHierarchyForViewController:(id)arg1;
- (void)teardownViewControllerHierarchy;

@end
