#import <AppKit/AppKit.h>
#import <OpenUXKit/UXNavigationController.h>
#import <OpenUXKit/UXViewController.h>
#import <OpenUXKit/UXKitDefines.h>
#import <OpenUXKit/UXBase.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class UXNavigationController, UXTransitionController, UXView, UXViewController, _UXSourceSplitView, _UXViewControllerOneToOneTransitionContext;
@protocol UXNavigationControllerDelegate, UXNavigationDestination, UXSourceList;

UXKIT_EXTERN NS_SWIFT_UI_ACTOR
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
@property (nonatomic) CGFloat preferredSourceListWidthFraction;
@property (nonatomic, strong) UXViewController<UXSourceList> *sourceListViewController;
@property (nonatomic) NSInteger style;
@property (nonatomic) NSInteger preferredStyle;
@property (nonatomic, readonly, getter = isSourceListCollapsed) BOOL sourceListCollapsed;
@property (nonatomic, readonly) BOOL wantsSourceListCollapsed;
@property (nonatomic) BOOL wantsDetachedNavigationBars;
@property (nonatomic, readonly) BOOL alternateTitleEnabled;
@property (nonatomic, readonly) BOOL isNavigating;
@property (nonatomic, readonly) id <UXNavigationDestination> currentNavigationDestination;
@property (nonatomic, readonly) UXNavigationController *selectedNavigationController;
@property (nonatomic) NSUInteger selectedIndex;

- (id)fallbackNavigationDestination;
- (void)_setupDelegateForNavigationController:(UXNavigationController *)navigationController operation:(UXNavigationControllerOperation)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController;
- (id)_contextForTransitionOperation:(NSInteger)operation fromViewController:(UXViewController *)fromViewController toViewController:(UXViewController *)toViewController transition:(NSUInteger)transition;
- (void)_beginTransitionWithContext:(id)context operation:(NSInteger)operation;
- (void)_prepareViewController:(UXViewController *)viewController forAnimationInContext:(id)context completion:(nullable UXCompletionHandler)completion;
- (void)removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)_removeDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)_navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (id)_rootViewControllerProvidingViewControllersForNavigationDestination:(id<UXNavigationDestination>)destination;
- (void)navigateToDestination:(id<UXNavigationDestination>)destination animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)windowDidUpdateFirstResponder;
- (void)didChangeTopViewControllerForNavigationController:(UXNavigationController *)navigationController;
- (void)didChangeSelectedViewController;
- (void)willSelectViewController:(UXViewController *)viewController;
- (void)willAddNavigationController:(UXNavigationController *)navigationController;
- (void)popUpChanged:(id)sender;
- (void)segmentChanged:(id)sender;
- (id)navigationController;
- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setSelectedViewController:(UXViewController *)selectedViewController animated:(BOOL)animated;
- (void)setRootViewControllers:(NSArray<UXViewController *> *)rootViewControllers destination:(id<UXNavigationDestination>)destination completion:(nullable UXCompletionHandler)completion;
- (void)_setRootViewControllers:(NSArray<UXViewController *> *)rootViewControllers destination:(id<UXNavigationDestination>)destination completion:(nullable UXCompletionHandler)completion;
- (void)_addRootViewController:(UXViewController *)rootViewController;
- (CGSize)contentSizeForWantsSourceListCollapsed:(BOOL)collapsed;
- (void)_setPreferredStyle:(NSInteger)style animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (void)_setStyle:(NSInteger)style animated:(BOOL)animated completion:(nullable UXParameterCompletionHandler)completion;
- (void)_didChangeCollapsed;
- (void)_setStyle:(NSInteger)style;
- (void)_setWantsSourceListCollapsed:(BOOL)collapsed animated:(BOOL)animated completion:(nullable UXCompletionHandler)completion;
- (void)_setWantsSourceListCollapsed:(BOOL)collapsed;
- (id)tabBarView;
- (BOOL)_reduceMotionEnabled;
- (BOOL)_wantsSourceListCollapsedForViewController:(UXViewController *)viewController;
- (NSInteger)_effectiveStyleForViewController:(UXViewController *)viewController;
- (void)_setSelectedIndex:(NSInteger)index animated:(BOOL)animated sender:(nullable id)sender;
- (void)_setSelectedViewController:(UXViewController *)selectedViewController animated:(BOOL)animated sender:(id)sender;
- (void)_didChangeSelectedViewControllerFromSender:(id)sender;
- (id)_popTransitoryViewControllersInNavigationController:(UXNavigationController *)navigationController animated:(BOOL)animated;
- (void)_setLeadingContentInset:(CGFloat)contentInset;
- (CGFloat)_preferredSourceListWidth;
- (void)_saveSourceListWidth:(CGFloat)width;
- (void)_updateSelectionControls;
- (void)_configureManagedNavigationController:(UXNavigationController *)navigationController;
- (void)unregisterTransitionControllerForTransitionToViewControllerClass:(Class)ViewControllerClass;
- (void)registerTranistionControllerClass:(Class)tranistionControllerClass forViewControllerClass:(Class)ViewControllerClass;
- (void)registerTransitionControllerClass:(Class)transitionControllerClass forViewControllerClass:(Class)viewControllerClass;
- (void)unregisterTransitoryViewController:(UXViewController *)viewController;
- (void)registerTransitoryViewController:(UXViewController *)viewController;
- (void)removeRootViewControllerAtIndex:(NSInteger)index;
- (void)insertRootViewController:(UXViewController *)rootViewController atIndex:(NSInteger)index;
- (void)addRootViewController:(UXViewController *)rootViewController;
- (void)_stopObservingFullscreenForWindow:(NSWindow *)window;
- (void)_startObservingFullscreenForWindow:(NSWindow *)window;
- (void)_didExitFullscreen:(id)sender;
- (void)_didEnterFullscreen:(id)sender;
- (BOOL)_hasItemToRevealOnEdgeHover;
- (void)_setHasItemToRevealOnEdgeHover:(BOOL)hasItemToRevealOnEdgeHover;
- (void)_stopObservingEdgeHover;
- (void)_startObservingEdgeHover;
- (void)_handleEdgeHoverEvent:(NSEvent *)event;
- (void)_cancelOrDismissUncollapsedItem;
- (void)_uncollapseEdgeRevealItem:(id)item;

@end


NS_HEADER_AUDIT_END(nullability, sendability)
