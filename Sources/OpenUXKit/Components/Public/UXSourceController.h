#import <AppKit/AppKit.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXViewControllerProtocol.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXBase.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXNavigationController, UXTransitionController, UXView, UXViewController, _UXDetailViewController, _UXInspectorViewController, _UXViewControllerOneToOneTransitionContext;
@protocol UXNavigationControllerDelegate, UXNavigationDestination, UXSourceList;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXSourceController : NSSplitViewController <UXNavigationControllerDelegate, UXViewController>

+ (Class)_defaultTransitionControllerClass;

@property (nonatomic, weak, nullable) NSWindow *observedWindow;
@property (nonatomic, strong, nullable) UXNavigationController *observedNavigationController;
@property (nonatomic, strong, nullable) UXViewController *selectedViewController;
@property (nonatomic, strong, nullable) UXViewController *selectedNavigationTopViewController;
@property (nonatomic, strong, nullable) NSArray *selectedNavigationViewConstraints;
@property (nonatomic, readonly) _UXDetailViewController *detailViewController;
@property (nonatomic, readonly) _UXInspectorViewController *inspectorViewController;
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
@property (nonatomic, readonly) NSArray *rootViewControllers;
@property (nonatomic, readonly, nullable) UXNavigationController *selectedNavigationController;
@property (nonatomic, readonly, nullable) id<UXNavigationDestination> currentNavigationDestination;
@property (nonatomic, readonly) BOOL isNavigating;

- (nullable id)navigationController;
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
- (void)_didChangeToolbarVisibilityForNavigationController:(UXNavigationController *)navigationController;

// Internal hooks / transition plumbing (kept on the public interface to match UXKit's layout).
- (void)_addRootViewController:(UXViewController *)rootViewController;
- (void)_removeRootViewController:(UXViewController *)rootViewController;
- (void)_configureManagedNavigationController:(UXNavigationController *)navigationController;
- (void)_prepareTransitionToRootViewController:(UXViewController *)rootViewController;
- (nullable UXViewController *)_rootViewControllerForNavigationDestination:(id<UXNavigationDestination>)navigationDestination;
- (void)_navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (void)_removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (void)_setSelectedViewController:(nullable UXViewController *)selectedViewController animated:(BOOL)animated sender:(nullable id)sender;
- (void)_didChangeSelectedViewControllerFromSender:(nullable id)sender;
- (id)_contextForTransitionOperation:(NSInteger)operation fromViewController:(nullable UXViewController *)fromViewController toViewController:(nullable UXViewController *)toViewController transition:(NSUInteger)transition;
- (void)_beginTransitionWithContext:(id)context operation:(NSInteger)operation;
- (void)_prepareViewController:(nullable UXViewController *)viewController forAnimationInContext:(id)context completion:(nullable UXCompletionHandler)completion;
- (void)_setupDelegateForNavigationController:(UXNavigationController *)navigationController operation:(UXNavigationControllerOperation)operation fromViewController:(nullable UXViewController *)fromViewController toViewController:(nullable UXViewController *)toViewController;
- (void)_updateInspectorViewController;
- (void)_updateDetailSplitViewItemAccessories;
- (void)_updateSplitViewAutosaveName;
- (void)_setWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed;
- (void)_setWantsInspectorCollapsed:(BOOL)wantsInspectorCollapsed;
- (void)_setWantsSourceListCollapsed:(BOOL)wantsSourceListCollapsed wantsInspectorCollapsed:(BOOL)wantsInspectorCollapsed animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)_didChangeCollapsed;
- (CGFloat)_preferredSourceListWidth;
- (void)_setLeadingContentInset:(CGFloat)leadingContentInset;
- (CGFloat)_leadingContentInsetForWantsCollapsed:(BOOL)wantsCollapsed;
- (BOOL)_wantsSourceListCollapsedForViewController:(UXViewController *)viewController;
- (BOOL)_wantsInspectorCollapsedForViewController:(UXViewController *)viewController;
- (void)_detailViewWidthDidChange;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
