//
//  Header.h
//  
//
//  Created by JH on 2024/4/15.
//

#import "UXViewController.h"
#import "_UXLayoutSpacer.h"

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
    BOOL _automaticallyAdjustsScrollViewInsets;
    UXModalPresentationStyle _modalPresentationStyle;
    UXRectEdge _edgesForExtendedLayout;
    UXView *_presentedViewControllerContainerView;
    CGFloat _preferredToolbarHeight;
    CGFloat _preferredToolbarBaselineOffsetFromBottom;
    UXBarPosition _preferredSubtoolbarPosition;
    CGFloat _preferredSubtoolbarHeight;
    CGFloat _preferredSubtoolbarBaselineOffsetFromBottom;
    NSInteger _preferredToolbarStyle;
    NSEdgeInsets _preferredToolbarDecorationInsets;
}
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
@end

@interface UXViewController (UXNavigationControllerContextualToolbarItems_Private)
- (void)performToolbarsChanges:(void (^)(void))changesBlock;
- (void)setShouldAnimateToolbarsChanges;
@end

@interface UXViewController (UXTabBarController_Private)
- (nullable UXTabBarItemSegment *)preferredTabBarItemSegmentForNavigationDestination:(id<UXNavigationDestination>)navigationDestination;
@end


NS_HEADER_AUDIT_END(nullability, sendability)
