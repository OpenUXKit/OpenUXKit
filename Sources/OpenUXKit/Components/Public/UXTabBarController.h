

#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXViewController.h>

@class NSArray, NSLayoutConstraint, NSMapTable, NSPopUpButton, NSSegmentedControl, NSSet, UXNavigationItem, UXTabBarItemSegment, UXTransitionController, UXViewController, _UXViewControllerTransitionContext;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
@interface UXTabBarController: UXViewController


@property(strong, nonatomic) UXViewController *transientViewController; // @synthesize transientViewController=_transientViewController;
@property(strong, nonatomic) UXTabBarItemSegment *selectedItemSegment; // @synthesize selectedItemSegment=_selectedItemSegment;
@property(nonatomic) BOOL viewControllerTransitionInProgress; // @synthesize viewControllerTransitionInProgress=_viewControllerTransitionInProgress;
@property(nonatomic) BOOL segmentTransitionInProgress; // @synthesize segmentTransitionInProgress=_segmentTransitionInProgress;
@property(readonly, nonatomic) NSMapTable *transitionControllerClassByToViewControllerClass; // @synthesize transitionControllerClassByToViewControllerClass=_transitionControllerClassByToViewControllerClass;
@property(strong, nonatomic) NSArray *shortcutMenuItems; // @synthesize shortcutMenuItems=_shortcutMenuItems;
@property(strong, nonatomic) UXViewController *observedViewController; // @synthesize observedViewController=_observedViewController;
@property(strong, nonatomic) UXNavigationItem *observedNavigationItem; // @synthesize observedNavigationItem=_observedNavigationItem;
@property(strong, nonatomic) NSSet *observedItemSegments; // @synthesize observedItemSegments=_observedItemSegments;
@property(strong, nonatomic) NSArray *representedSegments; // @synthesize representedSegments=_representedSegments;
@property(strong, nonatomic) NSMapTable *representedSegmentsToViewControllers; // @synthesize representedSegmentsToViewControllers=_representedSegmentsToViewControllers;
@property(readonly, nonatomic) NSLayoutConstraint *popUpButtonWidthConstraint; // @synthesize popUpButtonWidthConstraint=_popUpButtonWidthConstraint;
@property(readonly, nonatomic) NSPopUpButton *popUpButton; // @synthesize popUpButton=_popUpButton;
@property(readonly, nonatomic) NSSegmentedControl *segmentedControl; // @synthesize segmentedControl=_segmentedControl;
@property(nonatomic) __weak UXViewController *selectedViewController; // @synthesize selectedViewController=_selectedViewController;
@property(copy, nonatomic) NSArray *viewControllers; // @synthesize viewControllers=_viewControllers;
- (void)populateShortcutMenuItemsStartingAtIndex:(NSUInteger)arg1 ofMenu:(id)arg2 useSeparators:(BOOL)arg3;
- (id)contentRepresentingViewController;
- (id)_childViewControllerAbleToNavigateToDestination:(id)arg1;
- (void)updateForEqualNavigationDestination:(id)arg1;
- (void)requestViewControllersForNavigationDestination:(id)arg1 completion:(id)arg2;
- (BOOL)canProvideViewControllersForNavigationDestination:(id)arg1;
- (id)navigationDestination;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)_updateRightBarButtonItems;
- (void)_updateLeftBarButtonItems;
- (void)_setObservedNavigationItem:(id)arg1 updateBarButtonItems:(BOOL)arg2;
- (id)transitionCoordinator;
- (void)_prepareForAnimationInContext:(id)arg1 completion:(id)arg2;
- (BOOL)_requiresWindowForTransitionPreparation;
- (void)_prepareViewController:(id)arg1 forTransitionInContext:(id)arg2 completion:(id)arg3;
- (void)_beginTransitionWithContext:(id)arg1 operation:(NSInteger)arg2 completion:(id)arg3;
- (id)_contextForTransitionOperation:(NSInteger)arg1 fromViewController:(id)arg2 toViewController:(id)arg3 transition:(NSUInteger)arg4;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)arg1;
- (void)registerTransitionControllerClass:(Class)arg1 forViewControllerClass:(Class)arg2;
- (void)_performTransitionIfNeeded;
- (BOOL)_canPerformTransition;
- (void)_setNeedsTransition;
- (void)_removePopulatedMenuItems;
- (void)_recalculateSegmentedControlWidth;
- (void)_transitionToViewController:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)setTransientViewController:(id)arg1 animated:(BOOL)arg2;
@property(nonatomic) NSUInteger selectedIndex;
- (void)setSelectedIndex:(NSUInteger)arg1 allowsCurrentTabReselectionCallback:(BOOL)arg2;
- (void)keyDown:(id)arg1;
- (BOOL)validateMenuItem:(id)arg1;
- (void)selectSegmentFromMenu:(id)arg1;
- (void)popUpChanged:(id)arg1;
- (void)segmentChanged:(id)arg1;
- (void)invalidateIntrinsicLayoutInsets;
- (id)preferredFirstResponder;
- (void)viewWillDisappear;
- (void)viewDidLayout;
- (void)viewDidLoad;
- (id)_targetViewController;
- (void)_updateToolbarProperties;
- (void)_transitionToTargetViewControllerWithCompletion:(id)arg1;
- (void)_invalidateIntrinsicLayoutInsetsForViewController:(id)arg1;
- (void)_updateControlsProperties;
- (void)_updateControlsSelection;
- (void)_setSelectedIndex:(NSUInteger)arg1;
- (NSUInteger)_firstItemSegmentIndexForViewController:(id)arg1;
- (void)dealloc;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;

@end

