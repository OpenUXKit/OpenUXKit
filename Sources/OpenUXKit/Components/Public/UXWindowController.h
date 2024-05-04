

#import <AppKit/AppKit.h>
#import <OpenUXKit/_UXAccessoryBarContainer-Protocol.h>

@class NSString, NSTitlebarAccessoryViewController, NSToolbarItem, UXToolbar, UXViewController;

@interface UXWindowController : NSWindowController <NSToolbarDelegate, _UXAccessoryBarContainer, NSWindowDelegate>


+ (id)defaultWindow;

@property __weak NSToolbarItem *navigationBarToolbarItem; // @synthesize navigationBarToolbarItem=_navigationBarToolbarItem;
- (void)windowDidBecomeFirstResponder:(id)arg1;
- (void)windowDidRecalculateKeyViewLoop:(id)arg1;
- (void)windowWillRecalculateKeyViewLoop:(id)arg1;
- (void)windowWillExitFullScreen:(id)arg1;
- (void)windowWillEnterFullScreen:(id)arg1;
- (CGRect)window:(id)arg1 willPositionSheet:(id)arg2 usingRect:(CGRect)arg3;
- (void)_updateFirstResponder;
- (void)_updateAccessoryBar;
- (void)_updateToolbarItems;
- (void)_popoverWillShow:(id)arg1;
- (void)_setupAccessoryBar;
- (void)_setupNavigationBarToolbarItem;
- (void)_setAccessoryBarHidden:(BOOL)arg1;
@property(readonly, nonatomic) CGFloat _accessoryBarHeight;
- (id)toolbar:(id)arg1 itemForItemIdentifier:(id)arg2 willBeInsertedIntoToolbar:(BOOL)arg3;
- (id)toolbarDefaultItemIdentifiers:(id)arg1;
- (id)toolbarAllowedItemIdentifiers:(id)arg1;
- (void)setWindow:(id)arg1;
- (id)rootNavigationController;
@property(strong, nonatomic) UXViewController *rootViewController;
@property(readonly, nonatomic) NSTitlebarAccessoryViewController *titlebarAccessoryViewController;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)_tearDownViewControllerHierarchyForViewController:(id)arg1;
- (void)teardownViewControllerHierarchy;
- (void)dealloc;
- (id)initWithWindow:(id)arg1;
- (id)initWithRootViewController:(id)arg1;

@end

