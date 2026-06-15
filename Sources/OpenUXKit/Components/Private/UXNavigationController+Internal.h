#import "UXNavigationController.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

UXKIT_EXTERN void *UXToolbarItemsObservationContext;
UXKIT_EXTERN void *UXSubtoolbarItemsObservationContext;
UXKIT_EXTERN void *UXToolbarPositionsObservationContext;
UXKIT_EXTERN void *UXToolbarAppearanceObservationContext;
UXKIT_EXTERN void *UXAccessoryViewControllerObservationContext;
UXKIT_EXTERN void *UXScopeBarItemsObservationContext;

@class UXNavigationBar, UXToolbar, UXTransitionController, UXView, UXViewController, _UXContainerView, _UXViewControllerOneToOneTransitionContext, _UXWindowState, _UXNavigationRequest, UXBarButtonItem;
@protocol UXNavigationControllerDelegate, _UXAccessoryBarContainer, UXViewControllerAnimatedTransitioning;

/// Built-in navigation transition styles.
///
/// Restored from the private UXKit framework, where this parameter is a bare
/// `unsigned long long`. Each value maps to a concrete transition controller via
/// `_transitionControllerClassForTransition`. The push/pop suffixes mirror the
/// default transition slots: `_defaultPushTransition` is Parallax push and
/// `_defaultPopTransition` is Parallax pop. The two Slide values are equivalent
/// aliases — `UXSlideTransitionController` derives its direction from the
/// navigation operation rather than from this value.
typedef NS_ENUM(NSUInteger, UXNavigationControllerTransition) {
    UXNavigationControllerTransitionSlidePush        = 1,
    UXNavigationControllerTransitionSlidePop         = 2,
    UXNavigationControllerTransitionParallaxPush     = 100,
    UXNavigationControllerTransitionParallaxPop      = 101,
    UXNavigationControllerTransitionNone             = 102,
    UXNavigationControllerTransitionZoomingCrossfade = 103,
};

Class _transitionControllerClassForTransition(UXNavigationControllerTransition transition);
UXKIT_EXTERN NSArray *_toolbarItemsForViewController(UXViewController *viewController);
UXKIT_EXTERN NSArray *_subtoolbarItemsForViewController(UXViewController *viewController);
UXKIT_EXTERN NSArray *_scopeBarItemsForViewController(UXViewController *viewController);
UXKIT_EXTERN NSArray *_accessoryBarItemsForViewController(UXViewController *viewController);

typedef struct {
    unsigned int willShowViewController:1;
    unsigned int didShowViewController:1;
    unsigned int interactionControllerForAnimationController:1;
    unsigned int animationControllerForOperation:1;
    unsigned int shouldBeginInteractivePopFromViewControllerToViewController:1;
    unsigned int shouldPopFromViewControllerToViewController : 1;
} UXNavigationControllerDelegateFlags;

typedef struct {
    BOOL toolbarItems;
    BOOL subtoolbarItems;
    BOOL scopeBarItems;
    BOOL positions;
    BOOL visibility;
    BOOL appearance;
} UXNavigationControllerToolbarsNeedUpdateFlags;

@interface UXNavigationController () {
    NSMutableArray *_navigationRequests;    // 16 = 0x10
    NSMutableArray *_targetViewControllers;    // 24 = 0x18
    NSMutableArray *_currentViewControllers;    // 32 = 0x20
    UXNavigationBar *_navigationBar;    // 40 = 0x28
    UXToolbar *_accessoryBar;    // 48 = 0x30
    UXToolbar *_toolbar;    // 56 = 0x38
    UXToolbar *_subtoolbar;
    UXToolbar *_scopeBar;
    NSView *_detachedBarsContainer;
    UXNavigationControllerDelegateFlags _delegateFlags;    // 64 = 0x40
    BOOL _isPerformingToolbarsChanges;    // 68 = 0x44
    UXNavigationControllerToolbarsNeedUpdateFlags _toolbarsNeedUpdateFlags;    // 69 = 0x45
    // Backing ivars for synthesized properties accessed directly across subsystem categories.
    BOOL _navigationBarHidden;
    BOOL _toolbarHidden;
    BOOL _subtoolbarHidden;
    BOOL _scopeBarHidden;
    BOOL _isTransitioning;
    BOOL _isInteractive;
    BOOL __fullScreenMode;
    UXBarPosition __toolbarPosition;
    UXBarPosition __subtoolbarPosition;
    UXNavigationControllerTransition __defaultPushTransition;
    UXNavigationControllerTransition __defaultPopTransition;
    CGFloat __leadingContentInset;
    UXTransitionController *_defaultTransitionController;
    UXViewController *_observedViewController;
    NSGestureRecognizer *_interactivePopGestureRecognizer;
    NSLayoutConstraint *_topViewControllerLeftConstraint;
    NSArray *_topViewControllerOtherConstraints;
    _UXContainerView *_containerView;
    UXView *_toolbarExtendedBackgroundView;
}
@property (nonatomic, copy, nullable) NSArray<NSToolbarItemIdentifier> *toolbarDefaultItemIdentifiers;
@property (nonatomic, copy, nullable) NSArray<NSToolbarItemIdentifier> *toolbarAllowedItemIdentifiers;
@property (nonatomic, copy, nullable) NSDictionary<NSToolbarItemIdentifier, NSToolbarItem *> *toolbarItemByIdentifier;
@property (nonatomic, class) BOOL useIndividualNSToolbarItems;
@property (nonatomic, class) BOOL useNSSearchToolbarItem;
@property (nonatomic, class) BOOL allowToolbarCustomization;
@property (nonatomic, strong) Class toolbarClass;
@property (nonatomic, strong) Class navigationBarClass;
@property (nonatomic, readonly) BOOL isInteractive;
@property (nonatomic, readonly) BOOL isTransitioning;
@property (nonatomic, weak, nullable) id <_UXAccessoryBarContainer> accessoryBarContainer;
@property (nonatomic, strong) NSVisualEffectView *subtoolbarVisualEffectsView;
@property (nonatomic, strong) NSVisualEffectView *toolbarVisualEffectsView;
@property (nonatomic, strong) NSVisualEffectView *scopeBarVisualEffectsView;
@property (nonatomic, strong) NSLayoutConstraint *scopeBarVerticalConstraint;
@property (nonatomic, strong) NSLayoutConstraint *detachedSubtoolbarTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *detachedScopeBarTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *detachedBarsContainerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *containerTopConstraint;
@property (nonatomic, getter=areToolbarsDetached) BOOL toolbarsDetached;
@property (nonatomic, readonly) NSView *detachedBarsContainer;
@property (nonatomic) BOOL shouldAnimateToolbarUpdates;
@property (nonatomic, readonly) UXView *toolbarExtendedBackgroundView;
@property (nonatomic, getter = isBackButtonMenuEnabled) BOOL backButtonMenuEnabled;
@property (nonatomic, strong, nullable) UXViewController *provisionalPreviousViewController;
@property (nonatomic, strong) UXViewController *observedViewController;
@property (nonatomic, strong, nullable) UXTransitionController *defaultTransitionController;
@property (nonatomic) UXNavigationControllerOperation currentOperation;
@property (nonatomic, strong, nullable) _UXViewControllerOneToOneTransitionContext *currentTransitionContext;
@property (nonatomic, strong) NSArray *topViewControllerOtherConstraints;
@property (nonatomic, strong) NSLayoutConstraint *topViewControllerLeftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *toolbarLeadingConstraint;
@property (nonatomic, strong, nullable) NSLayoutConstraint *toolbarVerticalConstraint;
@property (nonatomic, strong, nullable) NSArray *navigationBarConstraints;
@property (nonatomic, strong, nullable) NSLayoutConstraint *navigationBarTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSMutableArray *addedConstraints;
@property (nonatomic, strong) _UXContainerView *containerView;
@property (nonatomic, strong, nullable) _UXWindowState *windowState;
@property (nonatomic, readonly) NSGestureRecognizer *interactivePopEventTracker;
@property (nonatomic, readonly) UXViewController *currentTopViewController;
@property (nonatomic, setter = _setHidesBackTitles:) BOOL _hidesBackTitles;
@property (nonatomic, setter = _setDefaultPopTransition:) UXNavigationControllerTransition _defaultPopTransition;
@property (nonatomic, setter = _setDefaultPushTransition:) UXNavigationControllerTransition _defaultPushTransition;
@property (nonatomic, readonly) UXBarPosition _subtoolbarPosition;
@property (nonatomic, readonly) UXBarPosition _toolbarPosition;
@property (nonatomic, readonly) CGFloat _leadingContentInset;
@property (nonatomic, setter = _setLocked:, getter = _isLocked) BOOL _locked;
@property (nonatomic, setter = _setFullScreenMode:, getter = _isFullScreenMode) BOOL _fullScreenMode;
@property (nonatomic, copy, nullable) void(^testingTransitionAnimationCompletionHandler)(void);
@property (nonatomic, readonly) id<UXViewControllerTransitionCoordinator> currentTransitionCoordinator;
+ (NSDictionary<NSValue *, NSArray<NSString *> *> *)topViewControllerObservationKeyPathsByContext;
+ (NSSet<NSString *> *)keyPathsForValuesAffectingPreferredContentSize;
- (void)_endObservingCurrentTopViewController;
- (void)_beginObservingCurrentTopViewController;
- (UXBarButtonItem *)_backItemWithTitle:(NSString *)title target:(nullable id)target action:(nullable SEL)action;
- (void)_addBackBarItemFromNavigationItem:(UXNavigationItem *)fromNavigationItem toNavigationItem:(UXNavigationItem *)toNavigationItem;
- (void)_setupLayoutGuidesForViewController:(UXViewController *)viewController;
- (nullable id<UXViewControllerInteractiveTransitioning>)_customInteractionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController transition:(UXNavigationControllerTransition)transition;
- (nullable id<UXViewControllerAnimatedTransitioning>)_customAnimationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(UXNavigationControllerTransition)transition;
- (_UXViewControllerOneToOneTransitionContext *)_contextForTransitionOperation:(UXNavigationControllerOperation)operation fromViewController:(nullable UXViewController *)fromViewController toViewController:(nullable UXViewController *)toViewController transition:(UXNavigationControllerTransition)transition;
- (void)_handleInteractiveUpdateWithEvent:(NSEvent *)event;
- (void)_beginTransitionWithContext:(_UXViewControllerOneToOneTransitionContext *)context operation:(UXNavigationControllerOperation)operation;
- (void)_removeConstraintsForContainedView:(UXView *)containedView;
- (void)_addConstraintsForContainedView:(UXView *)containedView leftInset:(CGFloat)leftInset;
- (void)_prepareViewController:(nullable UXViewController *)viewController forAnimationInContext:(_UXViewControllerOneToOneTransitionContext *)context completion:(void (^)(void))completion;
- (void)_setViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated;
- (nullable NSArray<__kindof UXViewController *> *)_popToViewController:(UXViewController *)viewController transition:(UXNavigationControllerTransition)transition;
- (void)_pushViewController:(UXViewController *)viewController transition:(UXNavigationControllerTransition)transition;
- (nullable NSArray<__kindof UXViewController *> *)_dequeueNavigationRequest;
- (nullable NSArray<__kindof UXViewController *> *)_performOrEnqueueNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (BOOL)_hasNoNavigationRequests;
- (void)_removeAllNavigationRequests;
- (nullable NSArray<__kindof UXViewController *> *)_checkinPopNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (void)_checkinPushNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (void)_checkinSetNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (nullable NSArray<__kindof UXViewController *> *)_performNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (void)__back:(nullable id)sender;
- (void)_updateToolbarAppearanceUsingTopViewController:(UXViewController *)topViewController animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)_updateToolbarVisibilityUsingTopViewController:(UXViewController *)topViewController animated:(BOOL)animated duration:(NSTimeInterval)duration animateSubtree:(BOOL)animateSubtree;
- (void)_updateToolbarsPositionsUsingTopViewController:(UXViewController *)topViewController;
- (void)_setToolbarPosition:(UXBarPosition)toolbarPosition subtoolbarPosition:(UXBarPosition)subtoolbarPosition;
- (void)_updateToolbarsIfNeeded;
- (void)_invalidateToolbarsAppearance;
- (void)_invalidateToolbarsVisibility;
- (void)_invalidateToolbarsPositions;
- (void)_invalidateSubtoolbarItems;
- (void)_invalidateToolbarItems;
- (void)_setToolbarsNeedUpdate;
- (BOOL)_toolbarsNeedUpdate;
- (CGFloat)_leftContentInset;
- (void)_setLeadingContentInset:(CGFloat)contentInset forViewController:(UXViewController *)viewController;
- (CGFloat)_visibleToolbarOffset;
- (CGFloat)_hiddenToolbarOffset;
- (void)_setToolbarHidden:(BOOL)toolbarHidden subtoolbarHidden:(BOOL)subtoolbarHidden scopeBarHidden:(BOOL)scopeBarHidden animated:(BOOL)animated duration:(NSTimeInterval)duration animateSubtree:(BOOL)animateSubtree;
- (BOOL)_toolbarNeedsVerticalOffsetUpdate;
- (BOOL)_requiresWindowForTransitionPreparation;
- (NSEdgeInsets)_intrinsicLayoutInsetsForChildViewController:(UXViewController *)childViewController;
- (NSEdgeInsets)_toolbarLayoutInsetsForChildViewController:(UXViewController *)childViewController;
- (NSLayoutConstraint *)_verticalToolbarLayoutConstraint;
- (CGFloat)_toolbarVerticalOffset;
- (CGFloat)_navigationBarVerticalOffset;
- (void)_invalidateIntrinsicLayoutInsetsForViewController:(UXViewController *)viewController;
- (void)_setAccessoryBarHidden:(BOOL)hidden;
- (void)testing_notifyTransitionAnimationDidComplete;
- (void)testing_installTransitionAnimationCompletionHandler:(void(^)(void))handler;
- (NSResponder *)nextResponderForToolbar:(UXToolbar *)toolbar;
- (void)goBackWithMenuItem:(NSMenuItem *)menuItem;
- (UXBarPosition)positionForBar:(id<UXBarPositioning>)bar;
- (void)_invalidateScopeBarItems;
- (CGFloat)_scopeBarVerticalOffset;
- (void)_updateToolbarContainerConstraints;
- (NSLayoutConstraint *)_verticalLayoutConstraintForToolbar:(UXToolbar *)toolbar;
- (void)detachToolbars;
- (void)_popTransitoryViewControllersAnimated:(BOOL)animated;
@property (nonatomic, readonly, nullable) UXViewController *inspectorViewController;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
