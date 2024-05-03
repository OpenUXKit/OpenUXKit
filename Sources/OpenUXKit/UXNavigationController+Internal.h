//
//  UXNavigationController+Internal.h
//  OpenUXKit
//
//  Created by JH on 2024/4/21.
//

#import "UXNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

UXKIT_EXTERN void *UXToolbarItemsObservationContext;
UXKIT_EXTERN void *UXSubtoolbarItemsObservationContext;
UXKIT_EXTERN void *UXToolbarPositionsObservationContext;
UXKIT_EXTERN void *UXToolbarAppearanceObservationContext;
UXKIT_EXTERN void *UXAccessoryViewControllerObservationContext;

@class UXNavigationBar, UXToolbar, UXTransitionController, UXView, UXViewController, _UXContainerView, _UXViewControllerOneToOneTransitionContext, _UXWindowState, _UXNavigationRequest, UXBarButtonItem;
@protocol UXNavigationControllerDelegate, _UXAccessoryBarContainer, UXViewControllerAnimatedTransitioning;

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
    BOOL _navigationBarHidden;    // 74 = 0x4a
    BOOL _navigationBarDetached;    // 75 = 0x4b
    BOOL _toolbarHidden;    // 76 = 0x4c
    BOOL _subtoolbarHidden;    // 77 = 0x4d
    BOOL _backButtonMenuEnabled;    // 78 = 0x4e
    BOOL _shouldAnimateToolbarUpdates;    // 79 = 0x4f
    BOOL __fullScreenMode;    // 80 = 0x50
    BOOL __locked;    // 81 = 0x51
    BOOL __hidesBackTitles;    // 82 = 0x52
    BOOL _isTransitioning;    // 83 = 0x53
    BOOL _isInteractive;    // 84 = 0x54
    UXToolbar *_subtoolbar;    // 88 = 0x58
    __weak id <UXNavigationControllerDelegate> _delegate;    // 96 = 0x60
    NSGestureRecognizer *_interactivePopGestureRecognizer;    // 104 = 0x68
    Class _navigationBarClass;    // 112 = 0x70
    Class _toolbarClass;    // 120 = 0x78
    _UXWindowState *_windowState;    // 128 = 0x80
    _UXContainerView *_containerView;    // 136 = 0x88
    NSMutableArray *_addedConstraints;    // 144 = 0x90
    NSLayoutConstraint *_topConstraint;    // 152 = 0x98
    NSLayoutConstraint *_bottomConstraint;    // 160 = 0xa0
    NSLayoutConstraint *_navigationBarTopConstraint;    // 168 = 0xa8
    NSArray *_navigationBarConstraints;    // 176 = 0xb0
    NSLayoutConstraint *_toolbarVerticalConstraint;    // 184 = 0xb8
    NSLayoutConstraint *_toolbarLeadingConstraint;    // 192 = 0xc0
    NSLayoutConstraint *_topViewControllerLeftConstraint;    // 200 = 0xc8
    NSArray *_topViewControllerOtherConstraints;    // 208 = 0xd0
    _UXViewControllerOneToOneTransitionContext *_currentTransitionContext;    // 216 = 0xd8
    UXNavigationControllerOperation _currentOperation;    // 224 = 0xe0
    UXTransitionController *_defaultTransitionController;    // 232 = 0xe8
    UXViewController *_observedViewController;    // 240 = 0xf0
    UXViewController *_provisionalPreviousViewController;    // 248 = 0xf8
    UXView *_toolbarExtendedBackgroundView;    // 256 = 0x100
    id _testingTransitionAnimationCompletionHandler;    // 264 = 0x108
    NSVisualEffectView *_toolbarVisualEffectsView;    // 272 = 0x110
    NSVisualEffectView *_subtoolbarVisualEffectsView;    // 280 = 0x118
    NSArray *_toolbarDefaultItemIdentifiers;
    NSArray *_toolbarAllowedItemIdentifiers;
    CGFloat __leadingContentInset;    // 288 = 0x120
    UXBarPosition __toolbarPosition;    // 296 = 0x128
    UXBarPosition __subtoolbarPosition;    // 304 = 0x130
    NSUInteger __defaultPushTransition;    // 312 = 0x138
    NSUInteger __defaultPopTransition;    // 320 = 0x140
    __weak id <_UXAccessoryBarContainer> _accessoryBarContainer;    // 328 = 0x148
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
