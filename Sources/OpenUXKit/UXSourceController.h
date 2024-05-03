#import <AppKit/AppKit.h>
#import "_UXSourceSplitViewDelegate-Protocol.h"
#import "UXNavigationControllerDelegate-Protocol.h"
#import "UXViewController.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXNavigationController, UXTransitionController, UXView, UXViewController, _UXSourceSplitView, _UXViewControllerOneToOneTransitionContext;
@protocol UXNavigationControllerDelegate, UXNavigationDestination, UXSourceList;

@interface UXSourceController : UXViewController <UXNavigationControllerDelegate, _UXSourceSplitViewDelegate>

+ (Class)_defaultTransitionControllerClass;
+ (id)_widthDefaultsKeyForAutosaveName:(id)arg1;

@property (nonatomic, weak, nullable) NSWindow *observedWindow;
@property (nonatomic, readonly) NSPopUpButton *popUpButton;
@property (nonatomic, readonly) NSSegmentedControl *segmentedControl;
@property (nonatomic, strong) UXViewController *selectedViewController;
@property (nonatomic, copy) NSArray *rootViewControllers;
@property (nonatomic, copy) NSString *sourceListAutosaveName;
@property (nonatomic) CGFloat minimumWidthForInlineSourceList;
@property (nonatomic, strong) UXViewController<UXSourceList> *sourceListViewController;
@property (nonatomic) NSInteger style;
@property (nonatomic) NSInteger preferredStyle;
@property (nonatomic, readonly, getter = isSourceListCollapsed) BOOL sourceListCollapsed;
@property (nonatomic, readonly) BOOL wantsSourceListCollapsed;
@property (nonatomic, readonly) BOOL alternateTitleEnabled;
@property (nonatomic, readonly) BOOL isNavigating;
@property (nonatomic, readonly) id <UXNavigationDestination> currentNavigationDestination;
@property (nonatomic, readonly) UXNavigationController *selectedNavigationController;
@property (nonatomic) NSUInteger selectedIndex;

- (id)fallbackNavigationDestination;
- (void)_setupDelegateForNavigationController:(id)arg1 operation:(NSInteger)arg2 fromViewController:(id)arg3 toViewController:(id)arg4;
- (BOOL)navigationController:(id)arg1 shouldBeginInteractivePopFromViewController:(id)arg2 toViewController:(id)arg3;
- (id)navigationController:(id)arg1 animationControllerForOperation:(NSInteger)arg2 fromViewController:(id)arg3 toViewController:(id)arg4;
- (id)navigationController:(id)arg1 interactionControllerForAnimationController:(id)arg2;
- (void)navigationController:(id)arg1 didShowViewController:(id)arg2;
- (void)navigationController:(id)arg1 willShowViewController:(id)arg2;
- (BOOL)sourceSplitView:(id)arg1 canSpringLoadRevealSubview:(id)arg2;
- (void)sourceSplitView:(id)arg1 didChangeAutoCollapsedValue:(BOOL)arg2;
- (void)sourceSplitView:(id)arg1 didResizeMasterWidth:(CGFloat)arg2;
- (id)_contextForTransitionOperation:(NSInteger)arg1 fromViewController:(id)arg2 toViewController:(id)arg3 transition:(NSUInteger)arg4;
- (void)_beginTransitionWithContext:(id)arg1 operation:(NSInteger)arg2;
- (void)_prepareViewController:(id)arg1 forAnimationInContext:(id)arg2 completion:(id)arg3;
- (id)transitionCoordinator;
- (void)dismissViewControllerAnimated:(BOOL)arg1 completion:(id)arg2;
- (void)presentViewController:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)removeDestination:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)_removeDestination:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)_navigateToDestination:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (id)_rootViewControllerProvidingViewControllersForNavigationDestination:(id)arg1;
- (void)navigateToDestination:(id)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)windowDidUpdateFirstResponder;
- (void)didChangeTopViewControllerForNavigationController:(id)arg1;
- (void)didChangeSelectedViewController;
- (void)willSelectViewController:(id)arg1;
- (void)willAddNavigationController:(id)arg1;
- (void)popUpChanged:(id)arg1;
- (void)segmentChanged:(id)arg1;
- (id)navigationController;
- (void)setSelectedIndex:(NSUInteger)arg1 animated:(BOOL)arg2;
- (void)setSelectedViewController:(id)arg1 animated:(BOOL)arg2;
- (void)setRootViewControllers:(id)arg1 destination:(id)arg2 completion:(id)arg3;
- (void)_setRootViewControllers:(id)arg1 destination:(id)arg2 completion:(id)arg3;
- (void)_addRootViewController:(id)arg1;
- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)arg1;
- (void)_setPreferredStyle:(NSInteger)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)_setStyle:(NSInteger)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)_didChangeCollapsed;
- (void)_setStyle:(NSInteger)arg1;
- (void)_setWantsSourceListCollapsed:(BOOL)arg1 animated:(BOOL)arg2 completion:(id)arg3;
- (void)_setWantsSourceListCollapsed:(BOOL)arg1;
- (id)tabBarView;
- (BOOL)_reduceMotionEnabled;
- (BOOL)_wantsSourceListCollapsedForViewController:(id)arg1;
- (NSInteger)_effectiveStyleForViewController:(id)arg1;
- (void)_setSelectedIndex:(NSInteger)arg1 animated:(BOOL)arg2 sender:(id)arg3;
- (void)_setSelectedViewController:(id)arg1 animated:(BOOL)arg2 sender:(id)arg3;
- (void)_didChangeSelectedViewControllerFromSender:(id)arg1;
- (id)_popTransitoryViewControllersInNavigationController:(id)arg1 animated:(BOOL)arg2;
- (void)_setLeadingContentInset:(CGFloat)arg1;
- (CGFloat)_preferredSourceListWidth;
- (void)_saveSourceListWidth:(CGFloat)arg1;
- (void)_updateSelectionControls;
- (void)_configureManagedNavigationController:(id)arg1;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)arg1;
- (void)registerTranistionControllerClass:(Class)arg1 forViewControllerClass:(Class)arg2;
- (void)registerTransitionControllerClass:(Class)arg1 forViewControllerClass:(Class)arg2;
- (void)unregisterTransitoryViewController:(id)arg1;
- (void)registerTransitoryViewController:(id)arg1;
- (void)removeRootViewControllerAtIndex:(NSInteger)arg1;
- (void)insertRootViewController:(id)arg1 atIndex:(NSInteger)arg2;
- (void)addRootViewController:(id)arg1;
- (void)_stopObservingFullscreenForWindow:(id)arg1;
- (void)_startObservingFullscreenForWindow:(id)arg1;
- (void)_didExitFullscreen:(id)arg1;
- (void)_didEnterFullscreen:(id)arg1;
- (BOOL)_hasItemToRevealOnEdgeHover;
- (void)_setHasItemToRevealOnEdgeHover:(BOOL)arg1;
- (void)_stopObservingEdgeHover;
- (void)_startObservingEdgeHover;
- (void)_handleEdgeHoverEvent:(id)arg1;
- (void)_cancelOrDismissUncollapsedItem;
- (void)_uncollapseEdgeRevealItem:(id)arg1;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
