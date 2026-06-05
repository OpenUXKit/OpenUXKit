#import <OpenUXKit/UXBase.h>
#import <OpenUXKit/UXTabBarController.h>

@class NSLayoutConstraint, NSMapTable, NSPopUpButton, NSSegmentedControl, NSToolbarItemGroup;
@class UXNavigationItem, UXTabBarItemSegment, _UXViewControllerOneToOneTransitionContext;
@protocol UXNavigationDestination;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UXTabBarController ()

@property (nonatomic, strong, nullable) UXTabBarItemSegment *selectedItemSegment;
@property (nonatomic) BOOL viewControllerTransitionInProgress;
@property (nonatomic) BOOL segmentTransitionInProgress;
@property (nonatomic, strong, readonly) NSMapTable *transitionControllerClassByToViewControllerClass;

@property (nonatomic, strong, nullable) UXViewController *observedViewController;
@property (nonatomic, strong, nullable) UXNavigationItem *observedNavigationItem;
@property (nonatomic, strong, nullable) NSSet<UXTabBarItemSegment *> *observedItemSegments;
@property (nonatomic, strong, nullable) NSSet *observedTabBarItems;

@property (nonatomic, strong, nullable) NSArray<UXTabBarItemSegment *> *representedSegments;
@property (nonatomic, strong, nullable) NSMapTable *representedSegmentsToViewControllers;

@property (nonatomic, strong, readonly) NSLayoutConstraint *popUpButtonWidthConstraint;
@property (nonatomic, strong, readonly) NSPopUpButton *popUpButton;
@property (nonatomic, strong, readonly) NSSegmentedControl *segmentedControl;
@property (nonatomic, strong, readonly) NSToolbarItemGroup *toolbarItemGroup;

- (void)_updateControls;
- (void)_updateControlsProperties;
- (void)_updateControlsSelection;
- (void)_updateTitleProperties;
- (void)_updateToolbarProperties;
- (void)_updateLeftBarButtonItems;
- (void)_updateRightBarButtonItems;
- (void)_updateProgressBarButtonItem;
- (void)_recalculateSegmentedControlWidth;

- (void)_setSelectedIndex:(NSUInteger)selectedIndex;
- (void)_setObservedNavigationItem:(nullable UXNavigationItem *)observedNavigationItem updateBarButtonItems:(BOOL)updateBarButtonItems;
- (void)_notifyDelegateWithIndexSelection:(NSUInteger)indexSelection;

- (void)_setNeedsTransition;
- (BOOL)_canPerformTransition;
- (void)_performTransitionIfNeeded;
- (void)_transitionToTargetViewControllerWithCompletion:(nullable UXCompletionHandler)completion;
- (void)_transitionToViewController:(nullable UXViewController *)viewController animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (_UXViewControllerOneToOneTransitionContext *)_contextForTransitionOperation:(NSInteger)operation fromViewController:(nullable UXViewController *)fromViewController toViewController:(nullable UXViewController *)toViewController transition:(NSUInteger)transition;
- (void)_beginTransitionWithContext:(_UXViewControllerOneToOneTransitionContext *)context operation:(NSInteger)operation completion:(nullable UXCompletionHandler)completion;
- (void)_prepareViewController:(nullable UXViewController *)viewController forTransitionInContext:(_UXViewControllerOneToOneTransitionContext *)context completion:(nullable UXCompletionHandler)completion;

- (nullable UXViewController *)_targetViewController;
- (nullable UXViewController *)_childViewControllerAbleToNavigateToDestination:(id<UXNavigationDestination>)destination;
- (NSUInteger)_firstItemSegmentIndexForViewController:(nullable UXViewController *)viewController;
- (void)_invalidateIntrinsicLayoutInsetsForViewController:(nullable UXViewController *)viewController;
- (void)_removePopulatedMenuItems;

- (void)toolbarItemGroupSelectionDidChange:(nullable id)sender;
- (void)segmentChanged:(nullable id)sender;
- (void)popUpChanged:(nullable id)sender;
- (void)selectSegmentFromMenu:(nullable id)sender;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
