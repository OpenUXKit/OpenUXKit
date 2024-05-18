#import <AppKit/AppKit.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXViewController.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXNavigationController, UXTransitionController, UXView, UXViewController, _UXSourceSplitView, _UXViewControllerOneToOneTransitionContext;
@protocol UXNavigationControllerDelegate, UXNavigationDestination, UXSourceList;

@interface UXSourceController : UXViewController <UXNavigationControllerDelegate>

+ (Class)_defaultTransitionControllerClass;
+ (id)_widthDefaultsKeyForAutosaveName:(id)autosaveName;

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
- (void)_setupDelegateForNavigationController:(UXNavigationController *)navigationController operation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (id)_contextForTransitionOperation:(NSInteger)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition;
- (void)_beginTransitionWithContext:(id)context operation:(NSInteger)operation;
- (void)_prepareViewController:(UXViewController *)viewController forAnimationInContext:(id)context completion:(id)completion;
- (void)removeDestination:(id)destination animated:(BOOL)animated completion:(id)completion;
- (void)_removeDestination:(id)destination animated:(BOOL)animated completion:(id)completion;
- (void)_navigateToDestination:(id)destination animated:(BOOL)animated completion:(id)completion;
- (id)_rootViewControllerProvidingViewControllersForNavigationDestination:(id)destination;
- (void)navigateToDestination:(id)destination animated:(BOOL)animated completion:(id)completion;
- (void)windowDidUpdateFirstResponder;
- (void)didChangeTopViewControllerForNavigationController:(id)arg1;
- (void)didChangeSelectedViewController;
- (void)willSelectViewController:(id)viewController;
- (void)willAddNavigationController:(id)navigationController;
- (void)popUpChanged:(id)sender;
- (void)segmentChanged:(id)sender;
- (id)navigationController;
- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setSelectedViewController:(id)selectedViewController animated:(BOOL)animated;
- (void)setRootViewControllers:(id)rootViewController destination:(id)destination completion:(id)completion;
- (void)_setRootViewControllers:(id)rootViewController destination:(id)destination completion:(id)completion;
- (void)_addRootViewController:(id)rootViewController;
- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)collapsed;
- (void)_setPreferredStyle:(NSInteger)style animated:(BOOL)animated completion:(id)completion;
- (void)_setStyle:(NSInteger)style animated:(BOOL)animated completion:(id)completion;
- (void)_didChangeCollapsed;
- (void)_setStyle:(NSInteger)style;
- (void)_setWantsSourceListCollapsed:(BOOL)collapsed animated:(BOOL)animated completion:(id)completion;
- (void)_setWantsSourceListCollapsed:(BOOL)collapsed;
- (id)tabBarView;
- (BOOL)_reduceMotionEnabled;
- (BOOL)_wantsSourceListCollapsedForViewController:(id)viewController;
- (NSInteger)_effectiveStyleForViewController:(id)viewController;
- (void)_setSelectedIndex:(NSInteger)index animated:(BOOL)animated sender:(id)sender;
- (void)_setSelectedViewController:(id)selectedViewController animated:(BOOL)animated sender:(id)sender;
- (void)_didChangeSelectedViewControllerFromSender:(id)sender;
- (id)_popTransitoryViewControllersInNavigationController:(id)navigationController animated:(BOOL)animated;
- (void)_setLeadingContentInset:(CGFloat)contentInset;
- (CGFloat)_preferredSourceListWidth;
- (void)_saveSourceListWidth:(CGFloat)width;
- (void)_updateSelectionControls;
- (void)_configureManagedNavigationController:(id)navigationController;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)ViewControllerClass;
- (void)registerTranistionControllerClass:(Class)tranistionControllerClass forViewControllerClass:(Class)ViewControllerClass;
- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass;
- (void)unregisterTransitoryViewController:(id)viewController;
- (void)registerTransitoryViewController:(id)viewController;
- (void)removeRootViewControllerAtIndex:(NSInteger)index;
- (void)insertRootViewController:(id)rootViewController atIndex:(NSInteger)index;
- (void)addRootViewController:(id)rootViewController;
- (void)_stopObservingFullscreenForWindow:(id)window;
- (void)_startObservingFullscreenForWindow:(id)window;
- (void)_didExitFullscreen:(id)sender;
- (void)_didEnterFullscreen:(id)sender;
- (BOOL)_hasItemToRevealOnEdgeHover;
- (void)_setHasItemToRevealOnEdgeHover:(BOOL)hasItemToRevealOnEdgeHover;
- (void)_stopObservingEdgeHover;
- (void)_startObservingEdgeHover;
- (void)_handleEdgeHoverEvent:(id)event;
- (void)_cancelOrDismissUncollapsedItem;
- (void)_uncollapseEdgeRevealItem:(id)item;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
