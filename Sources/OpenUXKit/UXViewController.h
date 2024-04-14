#import <AppKit/AppKit.h>
#import "UXBarCommon.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_OPTIONS(NSUInteger, UXRectEdge) {
    UXRectEdgeNone   = 0,
    UXRectEdgeTop    = 1 << 0,
    UXRectEdgeLeft   = 1 << 1,
    UXRectEdgeBottom = 1 << 2,
    UXRectEdgeRight  = 1 << 3,
    UXRectEdgeAll    = UXRectEdgeTop | UXRectEdgeLeft | UXRectEdgeBottom | UXRectEdgeRight
};


@class NSArray, NSResponder, NSView, UXNavigationController, UXNavigationItem, UXSourceController, UXTabBarController, UXTabBarItem, UXView, UXWindowController, UXTabBarItemSegment, UXPopoverController;
@protocol UXLayoutSupport, UXNavigationDestination, UXViewControllerTransitionCoordinator;

@interface UXViewController : NSViewController

@property (nonatomic, class, readonly) CGFloat defaultToolbarHeight;
@property (nonatomic, class, readonly) NSArray *toolbarPropertyNames;
@property (nonatomic) NSEdgeInsets preferredToolbarDecorationInsets;
@property (nonatomic) NSInteger preferredToolbarStyle;
@property (nonatomic) CGFloat preferredSubtoolbarBaselineOffsetFromBottom;
@property (nonatomic) CGFloat preferredSubtoolbarHeight;
@property (nonatomic) UXBarPosition preferredSubtoolbarPosition;
@property (nonatomic) CGFloat preferredToolbarBaselineOffsetFromBottom;
@property (nonatomic) CGFloat preferredToolbarHeight;
@property (nonatomic, strong) UXView *presentedViewControllerContainerView;
@property (nonatomic) BOOL automaticallyAdjustsScrollViewInsets;
@property (nonatomic) UXRectEdge edgesForExtendedLayout;
@property (nonatomic) NSInteger modalPresentationStyle;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) CGRect preferredInitialFrame;
@property (nonatomic, readonly, nullable) UXViewController *ux_presentingViewController;
@property (nonatomic, readonly, nullable) UXViewController *ux_parentViewController;
@property (nonatomic, readonly, nullable) UXViewController *presentedViewController;
@property (nonatomic, readonly, nullable) UXViewController *contentRepresentingViewController;
@property (nonatomic, readonly, nullable) id<UXViewControllerTransitionCoordinator> transitionCoordinator;
@property (nonatomic, readonly) NSResponder *preferredFirstResponder;
@property (nonatomic, readonly) UXView *uxView;
@property (nonatomic, readonly) id<UXLayoutSupport> topLayoutGuide;
@property (nonatomic, readonly) id<UXLayoutSupport> bottomLayoutGuide;
@property (nonatomic, readonly, getter = isWindowInFullScreen) BOOL windowInFullScreen;
@property (nonatomic, readonly, getter = isWindowConsideredInFullScreen) BOOL windowConsideredInFullScreen;
@property (nonatomic, readonly, strong, nullable) NSView *viewIfLoaded;

+ (Class)viewClass;
- (void)didUpdateLayoutGuides;
- (void)invalidateIntrinsicLayoutInsets;
- (NSEdgeInsets)intrinsicLayoutInsets;
- (CGSize)preferredContentSizeCappedToSize:(CGSize)size;
- (void)contentRepresentingViewControllerDidChange;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(id)completion;
- (void)presentViewController:(id)viewController animated:(BOOL)animated completion:(id)completion;
- (void)didMoveToParentViewController:(UXViewController *)parent;
- (void)willMoveToParentViewController:(UXViewController *)parent;
- (void)removeChildViewControllerAtIndex:(NSInteger)index;
- (void)windowDidRecalculateKeyViewLoop;
- (void)windowWillRecalculateKeyViewLoop;
- (void)viewDidLiveResize;
- (void)viewWillLiveResize;
- (void)viewDidLayoutSubviews;
- (void)viewWillLayoutSubviews;
- (void)viewUpdateLayer;
- (void)updateFirstResponderIfNeeded;
- (nullable NSMenu *)menuForEvent:(NSEvent *)event;
- (void)windowDidEnterFullScreen;
- (void)windowDidExitFullScreen;
- (void)windowWillEnterFullScreen;
- (void)windowWillExitFullScreen;
- (BOOL)delegatesSidebarAndToolbarFullscreenVisibilityManagement;
- (BOOL)prefersSidebarAndToolbarHiddenInFullscreenWindowMode;
@end

@interface UXViewController (UXNavigationControllerItem)
@property (nonatomic) BOOL hidesBottomBarWhenPushed;
@property (nonatomic, strong, nullable) UXViewController *toolbarViewController;
@property (nonatomic, strong, nullable) NSArray *toolbarItems;
@property (nonatomic, strong, nullable) NSArray *subtoolbarItems;
@property (nonatomic, readonly, strong, nullable) UXNavigationItem *navigationItem;
@property (nonatomic, readonly, strong, nullable) UXNavigationController *navigationController;
@property (nonatomic, strong, nullable) UXViewController *accessoryViewController;
@property (nonatomic, strong, nullable) NSArray *accessoryBarItems;
@property (nonatomic, readonly) UXBarPosition preferredToolbarPosition;
- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated;
@end

@interface UXViewController (UXNavigationControllerContextualToolbarItems_Private)
- (void)performToolbarsChanges:(void (^)(void))changesBlock;
- (void)setShouldAnimateToolbarsChanges;
@end

@interface UXViewController (UXConstraintBasedLayoutCoreMethods)
- (void)updateViewConstraints;
@end

@interface UXViewController (Compatibility)
- (void)viewDidDisappear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillAppear:(BOOL)animated;
@property (nonatomic, readonly) NSInteger interfaceOrientation;
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
@property (nonatomic, readonly, weak, nullable) UXTabBarController *tabBarController;
@end

@interface UXViewController (UXWindowController)
@property (nonatomic, readonly, nullable) UXWindowController *windowController;
@end


@interface UXViewController (UXTabBarItem)
- (void)performActionForSelectingCurrentTabBarItemSegment;
- (void)prepareForTransitionToSelectedTabBarItemSegmentWithCompletion:(void (^)(void))completion;
@end

@interface UXViewController (UXTabBarController_Private)
- (nullable UXTabBarItemSegment *)preferredTabBarItemSegmentForNavigationDestination:(id<UXNavigationDestination>)navigationDestination;
@end

@interface UXViewController (UXPopoverController)
@property (nonatomic, readonly, nullable) UXPopoverController *popoverController;
@end

@interface UXViewController (UXViewControllerTransitioning)
- (void)prepareForTransitionWithContext:(id)context completion:(void (^)(void))completion;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
