#import <OpenUXKit/UXNavigationController.h>

NS_ASSUME_NONNULL_BEGIN

UXKIT_EXTERN void *UXToolbarItemsObservationContext;
UXKIT_EXTERN void *UXSubtoolbarItemsObservationContext;
UXKIT_EXTERN void *UXToolbarPositionsObservationContext;
UXKIT_EXTERN void *UXToolbarAppearanceObservationContext;
UXKIT_EXTERN void *UXAccessoryViewControllerObservationContext;

@class UXNavigationBar, UXToolbar, UXTransitionController, UXView, UXViewController, _UXContainerView, _UXViewControllerOneToOneTransitionContext, _UXWindowState, _UXNavigationRequest, UXBarButtonItem;
@protocol UXNavigationControllerDelegate, _UXAccessoryBarContainer, UXViewControllerAnimatedTransitioning;

Class _transitionControllerClassForTransition(NSUInteger transition);

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
    UXNavigationControllerDelegateFlags _delegateFlags;    // 64 = 0x40
    BOOL _isPerformingToolbarsChanges;    // 68 = 0x44
    UXNavigationControllerToolbarsNeedUpdateFlags _toolbarsNeedUpdateFlags;    // 69 = 0x45
    NSArray *_toolbarDefaultItemIdentifiers;
    NSArray *_toolbarAllowedItemIdentifiers;
}
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
@property (nonatomic, setter = _setDefaultPopTransition:) NSUInteger _defaultPopTransition;
@property (nonatomic, setter = _setDefaultPushTransition:) NSUInteger _defaultPushTransition;
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
- (UXBarButtonItem *)_backItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (void)_addBackBarItemFromNavigationItem:(UXNavigationItem *)fromNavigationItem toNavigationItem:(UXNavigationItem *)toNavigationItem;
- (void)_setupLayoutGuidesForViewController:(UXViewController *)viewController;
- (id)_customInteractionControllerForAnimationController:(id<UXViewControllerAnimatedTransitioning>)animationController transition:(NSUInteger)transition;
- (id)_customAnimationControllerForOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition;
- (id)_contextForTransitionOperation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition;
- (void)_handleInteractiveUpdateWithEvent:(NSEvent *)event;
- (void)_beginTransitionWithContext:(id)context operation:(UXNavigationControllerOperation)operation;
- (void)_removeConstraintsForContainedView:(UXView *)containedView;
- (void)_addConstraintsForContainedView:(UXView *)containedView leftInset:(CGFloat)leftInset;
- (void)_prepareViewController:(nullable UXViewController *)viewController forAnimationInContext:(id)context completion:(void (^)(void))completion;
- (void)_setViewControllers:(NSArray<UXViewController *> *)viewControllers animated:(BOOL)animated;
- (NSArray *)_popToViewController:(UXViewController *)viewController transition:(NSUInteger)transition;
- (void)_pushViewController:(UXViewController *)viewController transition:(NSUInteger)transition;
- (NSArray *)_dequeueNavigationRequest;
- (id)_performOrEnqueueNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (BOOL)_hasNoNavigationRequests;
- (void)_removeAllNavigationRequests;
- (id)_checkinPopNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (void)_checkinPushNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (void)_checkinSetNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (NSArray *)_performNavigationRequest:(_UXNavigationRequest *)navigationRequest;
- (void)__back:(id)sender;
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
- (void)_setToolbarHidden:(BOOL)toolbarHidden subtoolbarHidden:(BOOL)subtoolbarHidden animated:(BOOL)animated duration:(NSTimeInterval)duration animateSubtree:(BOOL)animateSubtree;
- (BOOL)_toolbarNeedsVerticalOffsetUpdate;
- (BOOL)_requiresWindowForTransitionPreparation;
- (NSEdgeInsets)_intrinsicLayoutInsetsForChildViewController:(UXViewController *)childViewController;
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
@end

NS_ASSUME_NONNULL_END
