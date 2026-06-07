#import <AppKit/AppKit.h>
#import "UXNavigationController.h"
#import "UXViewController.h"
#import "UXViewControllerProtocol.h"
#import "UXKitDefines.h"
#import "UXBase.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXNavigationController, UXTransitionController, UXView, UXViewController;
@protocol UXNavigationControllerDelegate, UXNavigationDestination, UXSourceList;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXSourceController : NSSplitViewController <UXNavigationControllerDelegate, UXViewController>

@property (nonatomic, weak, nullable) NSWindow *observedWindow;
@property (nonatomic, strong, nullable) UXNavigationController *observedNavigationController;
@property (nonatomic, strong, nullable) UXViewController *selectedViewController;
@property (nonatomic, strong, nullable) UXViewController *selectedNavigationTopViewController;
@property (nonatomic, strong, nullable) NSArray *selectedNavigationViewConstraints;
@property (nonatomic, readonly) NSSplitViewItem *sidebarSplitViewItem;
@property (nonatomic, readonly) NSSplitViewItem *detailSplitViewItem;
@property (nonatomic, readonly) NSSplitViewItem *inspectorSplitViewItem;
@property (nonatomic, readonly) NSTitlebarAccessoryViewController *detailSplitViewItemTopAccessoryViewController;
@property (nonatomic, readonly) CGFloat sourceListWidth;
@property (nonatomic, getter=isSourceListAutoCollapsed, readonly) BOOL sourceListAutoCollapsed;
@property (nonatomic, readonly) NSSearchToolbarItem *searchToolbarItem;
@property (nonatomic) BOOL wantsDetachedNavigationBars;
@property (nonatomic) BOOL wantsDetachedToolbars;
@property (nonatomic, readonly) BOOL wantsSourceListHidden;
@property (nonatomic, readonly) BOOL wantsSourceListCollapsed;
@property (nonatomic, getter=isSourceListCollapsed, readonly) BOOL sourceListCollapsed;
@property (nonatomic, strong, nullable) UXViewController<UXSourceList> *sourceListViewController;
@property (nonatomic, copy, nullable) NSString *sourceListAutosaveName;
@property (nonatomic, readonly) BOOL wantsInspectorCollapsed;
@property (nonatomic, readonly) NSArray<__kindof UXViewController *> *rootViewControllers;
@property (nonatomic, readonly, nullable) UXNavigationController *selectedNavigationController;
@property (nonatomic, readonly, nullable) id<UXNavigationDestination> currentNavigationDestination;
@property (nonatomic, readonly) BOOL isNavigating;

- (nullable UXNavigationController *)navigationController;
- (void)presentViewController:(UXViewController *)viewController animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;

- (void)didChangeSelectedViewController;
- (void)willSelectViewController:(UXViewController *)viewController;
- (void)willChangeTopViewController:(UXViewController *)viewController;
- (void)didChangeTopViewControllerForNavigationController:(UXNavigationController *)navigationController;
- (void)willAddNavigationController:(UXNavigationController *)navigationController;
- (void)willUpdateToolbarForNavigationController:(UXNavigationController *)navigationController;

- (void)setSelectedViewController:(UXViewController *)selectedViewController animated:(BOOL)animated;

- (nullable id<UXNavigationDestination>)fallbackNavigationDestination;
- (nullable UXViewController *)makeRootViewControllerForDestination:(id<UXNavigationDestination>)destination;
- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated useFallbackDestinationIfNeeded:(BOOL)useFallbackDestinationIfNeeded completion:(nullable UXCompletionHandler)completion;
- (void)removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;

- (void)addRootViewController:(UXViewController *)rootViewController;

- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed;

- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass;
- (void)registerTranistionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)viewControllerClass;

- (void)windowDidUpdateFirstResponder;
- (void)windowWillEnterFullScreen;
- (void)windowWillExitFullScreen;
- (void)didUpdateLayoutGuides;

- (void)viewController:(UXViewController *)viewController changedSourceListCollapsed:(BOOL)changedSourceListCollapsed;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
