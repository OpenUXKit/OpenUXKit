#import <AppKit/AppKit.h>
#import "UXSourceController.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXNavigationController, UXViewController, UXTransitionController, _UXDetailViewController, _UXInspectorViewController, _UXViewControllerOneToOneTransitionContext;
@protocol UXNavigationDestination, UXNavigationControllerDelegate, UXLayoutSupport, UXSourceList;

// Returns -[NSObject _UXSolariumEnabled] equivalent (os_feature_enabled(SwiftUI, Solarium)).
UXKIT_EXTERN BOOL UXSourceControllerSolariumEnabled(void);
UXKIT_EXTERN BOOL UXSourceControllerShouldForceSelectionForNavigationDestination(id<UXNavigationDestination> destination);

@interface UXSourceController () <NSSplitViewDelegate> {
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
    UXViewController *_selectedViewController;
    UXViewController<UXSourceList> *_sourceListViewController;
    NSArray *_rootViewControllers;
}

@property (nonatomic, strong, readwrite, nullable) _UXDetailViewController *detailViewController;
@property (nonatomic, strong, readwrite, nullable) _UXInspectorViewController *inspectorViewController;
@property (nonatomic, strong, readwrite) NSSplitViewItem *sidebarSplitViewItem;
@property (nonatomic, strong, readwrite) NSSplitViewItem *detailSplitViewItem;
@property (nonatomic, strong, readwrite) NSSplitViewItem *inspectorSplitViewItem;
@property (nonatomic, strong, readwrite) NSTitlebarAccessoryViewController *detailSplitViewItemTopAccessoryViewController;
@property (nonatomic, strong, readwrite) NSSearchToolbarItem *searchToolbarItem;
@property (nonatomic, readwrite) BOOL wantsSourceListHidden;
@property (nonatomic, copy, readwrite) NSArray *rootViewControllers;

+ (Class)_defaultTransitionControllerClass;

- (void)_didChangeToolbarVisibilityForNavigationController:(UXNavigationController *)navigationController;

#pragma mark - Internal hooks / transition plumbing

- (void)_addRootViewController:(UXViewController *)rootViewController;
- (void)_removeRootViewController:(UXViewController *)rootViewController;
- (void)_configureManagedNavigationController:(UXNavigationController *)navigationController;
- (void)_prepareTransitionToRootViewController:(UXViewController *)rootViewController;
- (nullable UXViewController *)_rootViewControllerForNavigationDestination:(id<UXNavigationDestination>)navigationDestination;
- (void)_navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (void)_removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (void)_setSelectedViewController:(nullable UXViewController *)selectedViewController animated:(BOOL)animated sender:(nullable id)sender;
- (void)_didChangeSelectedViewControllerFromSender:(nullable id)sender;
- (_UXViewControllerOneToOneTransitionContext *)_contextForTransitionOperation:(NSInteger)operation fromViewController:(nullable UXViewController *)fromViewController toViewController:(nullable UXViewController *)toViewController transition:(NSUInteger)transition;
- (void)_beginTransitionWithContext:(_UXViewControllerOneToOneTransitionContext *)context operation:(NSInteger)operation;
- (void)_prepareViewController:(nullable UXViewController *)viewController forAnimationInContext:(_UXViewControllerOneToOneTransitionContext *)context completion:(nullable UXCompletionHandler)completion;
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
