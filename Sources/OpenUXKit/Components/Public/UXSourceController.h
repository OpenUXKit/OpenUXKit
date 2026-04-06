#import <AppKit/AppKit.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXViewController-Protocol.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXBase.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXNavigationController, UXTransitionController, UXView, UXViewController, _UXDetailViewController, _UXInspectorViewController, _UXViewControllerOneToOneTransitionContext;
@protocol UXNavigationControllerDelegate, UXNavigationDestination, UXSourceList;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXSourceController : NSSplitViewController <UXNavigationControllerDelegate, UXViewController> {
    BOOL _needsToSetInitialSourceListWidth;
    BOOL _wantsSourceListCollapsed;
    BOOL _isTogglingSidebar;
    BOOL _hasAddedInspector;
    BOOL _isTransitioning;
    _UXViewControllerOneToOneTransitionContext *_transitionCtx;
    UXTransitionController *_transitionController;
    NSMapTable<UXViewController *, UXNavigationController *> *_navigationControllerByRootViewController;
    NSMapTable *_transitionControllerClassByToViewControllerClass;
    NSOperationQueue *_viewControllerOperations;
    BOOL _navigatingToDestination;
    id<UXNavigationControllerDelegate> _currentNavigationDelegate;
    id<UXLayoutSupport> _topLayoutGuide;
    id<UXLayoutSupport> _bottomLayoutGuide;
}

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
@property (nonatomic, readonly) NSSplitViewItemAccessoryViewController *detailSplitViewItemTopAccessoryViewController;
@property (nonatomic, readonly) CGFloat sourceListWidth;
@property (nonatomic, getter=isSourceListAutoCollapsed, readonly) BOOL sourceListAutoCollapsed;
@property (nonatomic, readonly, nullable) NSSearchToolbarItem *searchToolbarItem;
@property (nonatomic) BOOL wantsDetachedNavigationBars;
@property (nonatomic) BOOL wantsDetachedToolbars;
@property (nonatomic, readonly) BOOL wantsSourceListHidden;
@property (nonatomic, readonly) BOOL wantsSourceListCollapsed;
@property (nonatomic, getter=isSourceListCollapsed, readonly) BOOL sourceListCollapsed;
@property (nonatomic, strong, nullable) UXViewController<UXSourceList> *sourceListViewController;
@property (nonatomic, copy, nullable) NSString *sourceListAutosaveName;
@property (nonatomic, readonly) BOOL wantsInspectorCollapsed;
@property (nonatomic, readonly, nullable) NSArray<UXViewController *> *rootViewControllers;
@property (nonatomic, readonly, nullable) UXNavigationController *selectedNavigationController;
@property (nonatomic, readonly, nullable) id<UXNavigationDestination> currentNavigationDestination;
@property (nonatomic, readonly) BOOL isNavigating;

- (nullable id)fallbackNavigationDestination;
- (nullable id)makeRootViewControllerForDestination:(id<UXNavigationDestination>)destination;
- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated useFallbackDestinationIfNeeded:(BOOL)useFallbackDestinationIfNeeded completion:(nullable UXCompletionHandler)completion;
- (void)removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)setSelectedViewController:(nullable UXViewController *)selectedViewController animated:(BOOL)animated;
- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass;
- (void)registerTranistionControllerClass:(Class)tranistionControllerClass forViewControllerClass:(Class)viewControllerClass;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)viewControllerClass;
- (void)windowDidUpdateFirstResponder;
- (void)didChangeTopViewControllerForNavigationController:(UXNavigationController *)navigationController;
- (void)didChangeSelectedViewController;
- (void)willSelectViewController:(nullable UXViewController *)viewController;
- (void)willAddNavigationController:(UXNavigationController *)navigationController;
- (void)willChangeTopViewController:(nullable UXViewController *)viewController;
- (void)willUpdateToolbarForNavigationController:(UXNavigationController *)navigationController;
- (nullable UXNavigationController *)navigationController;
- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)collapsed;
- (void)didUpdateLayoutGuides;
- (void)viewController:(UXViewController *)viewController changedSourceListCollapsed:(BOOL)collapsed;
- (void)_setupDelegateForNavigationController:(UXNavigationController *)navigationController operation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (nullable id)_contextForTransitionOperation:(NSInteger)operation fromViewController:(nullable UXViewController *)fromViewController toViewController:(nullable UXViewController *)toViewController transition:(NSUInteger)transition;
- (void)_beginTransitionWithContext:(id)context operation:(NSInteger)operation;
- (void)_prepareViewController:(UXViewController *)viewController forAnimationInContext:(id)context completion:(nullable UXCompletionHandler)completion;
- (void)_navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (void)_removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (nullable id)_rootViewControllerForNavigationDestination:(id<UXNavigationDestination>)destination;
- (void)_addRootViewController:(UXViewController *)rootViewController;
- (void)_removeRootViewController:(UXViewController *)rootViewController;
- (void)_prepareTransitionToRootViewController:(UXViewController *)rootViewController;
- (void)_configureManagedNavigationController:(UXNavigationController *)navigationController;
- (void)_setSelectedViewController:(nullable UXViewController *)selectedViewController animated:(BOOL)animated sender:(nullable id)sender;
- (void)_didChangeSelectedViewControllerFromSender:(nullable id)sender;
- (void)_setWantsSourceListCollapsed:(BOOL)collapsed;
- (void)_setWantsInspectorCollapsed:(BOOL)collapsed;
- (void)_setWantsSourceListCollapsed:(BOOL)sourceListCollapsed wantsInspectorCollapsed:(BOOL)inspectorCollapsed animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)_didChangeCollapsed;
- (void)_setLeadingContentInset:(CGFloat)contentInset;
- (CGFloat)_leadingContentInsetForWantsCollapsed:(BOOL)wantsCollapsed;
- (CGFloat)_preferredSourceListWidth;
- (BOOL)_wantsSourceListCollapsedForViewController:(UXViewController *)viewController;
- (BOOL)_wantsInspectorCollapsedForViewController:(UXViewController *)viewController;
- (void)_updateDetailSplitViewItemAccessories;
- (void)_updateInspectorViewController;
- (void)_updateSplitViewAutosaveName;
- (void)_detailViewWidthDidChange;
- (void)_didChangeToolbarVisibilityForNavigationController:(UXNavigationController *)navigationController;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
