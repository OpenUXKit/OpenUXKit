//
//  Header.h
//  
//
//  Created by JH on 2024/4/15.
//

#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/_UXLayoutSpacer.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXViewController () {
    UXNavigationItem *_navigationItem;
    UXTabBarItem *_tabBarItem;
    UXViewController *_accessoryViewController;
    NSArray *_accessoryBarItems;
    UXViewController *_toolbarViewController;
    NSArray *_toolbarItems;
    NSArray *_subtoolbarItems;
    BOOL _hidesBottomBarWhenPushed;
    CGSize _ux_preferredContentSize;
    BOOL _viewDidLoad;
    BOOL _ignoreViewController;
    _UXLayoutSpacer *_topLayoutGuide;
    _UXLayoutSpacer *_bottomLayoutGuide;
    BOOL _transitioningIntoFullScreen;
    BOOL _transitioningOutOfFullScreen;
    BOOL _isEditing;
}

@property (nonatomic, readonly, getter = isWindowInFullScreen) BOOL windowInFullScreen;
@property (nonatomic, readonly, getter = isWindowConsideredInFullScreen) BOOL windowConsideredInFullScreen;
@property (nonatomic, readonly, nullable) UXViewController *contentRepresentingViewController;
@property (nonatomic) UXRectEdge edgesForExtendedLayout;
@property (nonatomic, strong) UXView *presentedViewControllerContainerView;
@property (nonatomic, class, readonly) NSArray *toolbarPropertyNames;
@property (nonatomic, class, readonly) CGFloat defaultToolbarHeight;
@property (nonatomic) NSEdgeInsets preferredToolbarDecorationInsets;
@property (nonatomic) NSInteger preferredToolbarStyle;
@property (nonatomic) CGFloat preferredToolbarHeight;
@property (nonatomic) CGFloat preferredToolbarBaselineOffsetFromBottom;
@property (nonatomic) CGFloat preferredSubtoolbarHeight;
@property (nonatomic) UXBarPosition preferredSubtoolbarPosition;
@property (nonatomic) CGFloat preferredSubtoolbarBaselineOffsetFromBottom;
@property (nonatomic) CGRect preferredInitialFrame;
@property (nonatomic, readonly, nullable) NSResponder *preferredFirstResponder;

- (void)didUpdateLayoutGuides;
- (void)_animateView:(UXView *)view fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;
- (void)_setupLayoutGuidesForView:(UXView *)view;
- (BOOL)_requiresWindowForTransitionPreparation;
- (id)_ancestorViewControllerOfClass:(Class)cls;
- (CGRect)_defaultInitialFrame;
- (void)_loadViewIfNotLoaded;
- (void)_prepareForAnimationInContext:(id)context completion:(void (^)(void))completion;
- (void)_startObservingFullScreenNotifications;
- (void)_stopObservingFullScreenNotifications;
- (void)_willEnterFullScreenNotification:(NSNotification *)notification;
- (void)_willExitFullScreenNotification:(NSNotification *)notification;
- (void)_didExitFullScreenNotification:(NSNotification *)notification;
- (void)_didEnterFullScreenNotification:(NSNotification *)notification;
- (nullable NSMenu *)menuForEvent:(NSEvent *)event;
- (BOOL)delegatesSidebarAndToolbarFullscreenVisibilityManagement;
- (BOOL)prefersSidebarAndToolbarHiddenInFullscreenWindowMode;
- (void)windowDidEnterFullScreen;
- (void)windowDidExitFullScreen;
- (void)windowWillEnterFullScreen;
- (void)windowWillExitFullScreen;
- (void)viewUpdateLayer;
- (void)updateFirstResponderIfNeeded;
- (void)windowDidRecalculateKeyViewLoop;
- (void)windowWillRecalculateKeyViewLoop;
- (CGSize)preferredContentSizeCappedToSize:(CGSize)size;
- (void)contentRepresentingViewControllerDidChange;
@end

@interface UXViewController (UXNavigationControllerContextualToolbarItems_Private)

- (void)performToolbarsChanges:(void (^)(void))changesBlock;
- (void)setShouldAnimateToolbarsChanges;

@end

@interface UXViewController (UXTabBarController_Private)

- (nullable UXTabBarItemSegment *)preferredTabBarItemSegmentForNavigationDestination:(id<UXNavigationDestination>)navigationDestination;

@end

@interface UXViewController (UXViewControllerTransitioning)

- (void)prepareForTransitionWithContext:(id)context completion:(void (^)(void))completion;

@end

@interface UXViewController (UXSourceController)

@property (nonatomic, readonly, nullable) UXSourceController *sourceController;
@property (nonatomic, getter = isTransitory) BOOL transitory;
@property (nonatomic) BOOL hidesSourceListWhenPushed;
@property (nonatomic, readonly, nullable) id <UXNavigationDestination> navigationDestination;

- (void)updateForEqualNavigationDestination:(id<UXNavigationDestination>)navigationDestination;
- (void)requestViewControllersForNavigationDestination:(id<UXNavigationDestination>)navigationDestination completion:(void (^)(BOOL, NSArray<UXViewController *> *))completion;
- (BOOL)canProvideViewControllersForNavigationDestination:(id<UXNavigationDestination>)navigationDestination;
- (void)willEncodeNavigationDestination:(id<UXNavigationDestination>)navigationDestination;

@end

@interface UXViewController (UXTabBarController)

@property (nonatomic, strong) UXTabBarItem *tabBarItem;
@property (nonatomic, weak, readonly, nullable) UXTabBarController *tabBarController;

@end

@interface UXViewController (UXWindowController)

@property (nonatomic, readonly, nullable) UXWindowController *windowController;

@end


@interface UXViewController (UXTabBarItem)

- (void)performActionForSelectingCurrentTabBarItemSegment;
- (void)prepareForTransitionToSelectedTabBarItemSegmentWithCompletion:(void (^)(void))completion;

@end


@interface UXViewController (UXConstraintBasedLayoutCoreMethods)
@end

NS_HEADER_AUDIT_END(nullability, sendability)
